#!/usr/bin/env node
/**
 * omo-mem sync daemon
 *
 * Bidirectional sync between disk files and Apple Notes on a configurable interval.
 *
 * Apple Notes structure:
 *   Folder: "omo-mem"
 *     Note: "SOUL.md"
 *     Note: "MEMORY.md"
 *   Folder: "omo-mem" > subfolder "memory"
 *     Note: "YYYY-MM-DD"  (no .md extension in title)
 *
 * Conflict resolution: when both disk and Notes changed since last sync,
 * spawn `opencode run` with a merge prompt and write the result back to both sides.
 *
 * State file: $OMO_MEM_DIR/.sync-state.json
 *   { [fileKey]: { diskHash, notesHash, lastSynced } }
 *
 * Environment variables:
 *   OMO_MEM_DIR       - memory workspace dir (default: ~/workspace/omo-mem)
 *   OMO_SYNC_INTERVAL - poll interval in seconds (default: 60)
 *   OMO_SYNC_DRY_RUN  - set to "1" to skip writes (log only)
 */

import { execFile } from "child_process";
import { promisify } from "util";
import fs from "fs/promises";
import crypto from "crypto";
import path from "path";
import os from "os";

const execFileAsync = promisify(execFile);

// ─── Configuration ────────────────────────────────────────────────────────────

const MEMORY_DIR = process.env.OMO_MEM_DIR ?? path.join(os.homedir(), "workspace/omo-mem");
const INTERVAL_MS = (parseInt(process.env.OMO_SYNC_INTERVAL ?? "60", 10) || 60) * 1000;
const DRY_RUN = process.env.OMO_SYNC_DRY_RUN === "1";
const STATE_FILE = path.join(MEMORY_DIR, ".sync-state.json");

// Files to sync: static files + all memory/YYYY-MM-DD.md on disk at runtime
const STATIC_FILES = ["SOUL.md", "MEMORY.md"];

// ─── Logging ──────────────────────────────────────────────────────────────────

function log(level, msg, extra) {
  const ts = new Date().toISOString();
  const line = extra
    ? `[${ts}] [${level}] ${msg} ${JSON.stringify(extra)}`
    : `[${ts}] [${level}] ${msg}`;
  console.log(line);
}

const info = (msg, extra) => log("INFO ", msg, extra);
const warn = (msg, extra) => log("WARN ", msg, extra);
const error = (msg, extra) => log("ERROR", msg, extra);

// ─── Hash ─────────────────────────────────────────────────────────────────────

function sha256(text) {
  return crypto.createHash("sha256").update(text ?? "", "utf8").digest("hex");
}

// ─── Disk helpers ─────────────────────────────────────────────────────────────

async function diskRead(relPath) {
  try {
    return await fs.readFile(path.join(MEMORY_DIR, relPath), "utf-8");
  } catch (err) {
    if (err.code === "ENOENT") return null;
    throw err;
  }
}

async function diskWrite(relPath, content) {
  if (DRY_RUN) { info("[dry-run] would write disk", { relPath }); return; }
  const full = path.join(MEMORY_DIR, relPath);
  await fs.mkdir(path.dirname(full), { recursive: true });
  await fs.writeFile(full, content, "utf-8");
}

async function listDailyFiles() {
  const memDir = path.join(MEMORY_DIR, "memory");
  try {
    const entries = await fs.readdir(memDir);
    return entries
      .filter(f => /^\d{4}-\d{2}-\d{2}\.md$/.test(f))
      .map(f => `memory/${f}`);
  } catch {
    return [];
  }
}

// ─── State helpers ────────────────────────────────────────────────────────────

async function loadState() {
  try {
    const raw = await fs.readFile(STATE_FILE, "utf-8");
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

async function saveState(state) {
  if (DRY_RUN) return;
  await fs.writeFile(STATE_FILE, JSON.stringify(state, null, 2), "utf-8");
}

// ─── AppleScript helpers ──────────────────────────────────────────────────────

/**
 * Run an AppleScript string via osascript.
 * Returns stdout as a string, throws on error.
 */
async function runAppleScript(script) {
  const { stdout } = await execFileAsync("osascript", ["-e", script], {
    timeout: 30_000,
    maxBuffer: 10 * 1024 * 1024, // 10 MB
  });
  return stdout.trimEnd();
}

/**
 * Ensure the "omo-mem" folder and its "memory" subfolder exist in Apple Notes.
 */
async function ensureNotesFolders() {
  const script = `
tell application "Notes"
  if not (exists folder "omo-mem") then
    make new folder with properties {name:"omo-mem"}
  end if
  tell folder "omo-mem"
    if not (exists folder "memory") then
      make new folder with properties {name:"memory"}
    end if
  end tell
end tell
return "ok"
`;
  await runAppleScript(script);
}

/**
 * Convert a disk relative path to { folder, noteName } for Apple Notes.
 *
 * "SOUL.md"              → { folder: "omo-mem",        noteName: "SOUL.md" }
 * "MEMORY.md"            → { folder: "omo-mem",        noteName: "MEMORY.md" }
 * "memory/2026-03-06.md" → { folder: "omo-mem/memory", noteName: "2026-03-06" }
 */
function noteLocation(relPath) {
  if (relPath.startsWith("memory/")) {
    const base = path.basename(relPath, ".md");
    return { folder: "omo-mem/memory", noteName: base };
  }
  return { folder: "omo-mem", noteName: path.basename(relPath) };
}

/**
 * Read a note from Apple Notes. Returns plaintext content or null if not found.
 */
async function notesRead({ folder, noteName }) {
  // folder is either "omo-mem" or "omo-mem/memory" (nested)
  const folderScript = folder === "omo-mem"
    ? `folder "omo-mem"`
    : `folder "memory" of folder "omo-mem"`;

  const script = `
tell application "Notes"
  try
    tell ${folderScript}
      set matchingNotes to (notes whose name is "${noteName.replace(/"/g, '\\"')}")
      if (count of matchingNotes) = 0 then
        return "__NOT_FOUND__"
      end if
      return plaintext of (first item of matchingNotes)
    end tell
  on error errMsg
    return "__ERROR__:" & errMsg
  end try
end tell
`;
  const result = await runAppleScript(script);
  if (result === "__NOT_FOUND__") return null;
  if (result.startsWith("__ERROR__:")) {
    throw new Error(`AppleScript read error: ${result.slice(10)}`);
  }
  return result;
}

/**
 * Write (upsert) a note in Apple Notes. Creates if missing, updates if exists.
 */
async function notesWrite({ folder, noteName }, content) {
  if (DRY_RUN) { info("[dry-run] would write note", { folder, noteName }); return; }

  const folderScript = folder === "omo-mem"
    ? `folder "omo-mem"`
    : `folder "memory" of folder "omo-mem"`;

  // Escape for AppleScript string literal: backslash then quote
  const escaped = content.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
  const noteNameEscaped = noteName.replace(/"/g, '\\"');

  const script = `
tell application "Notes"
  tell ${folderScript}
    set matchingNotes to (notes whose name is "${noteNameEscaped}")
    if (count of matchingNotes) > 0 then
      set body of (first item of matchingNotes) to "<pre>${escaped}</pre>"
    else
      make new note with properties {name:"${noteNameEscaped}", body:"<pre>${escaped}</pre>"}
    end if
  end tell
end tell
return "ok"
`;
  const result = await runAppleScript(script);
  if (result.startsWith("__ERROR__:")) {
    throw new Error(`AppleScript write error: ${result.slice(10)}`);
  }
}

/**
 * List note names in a Notes folder. Returns array of strings.
 */
async function notesList(folder) {
  const folderScript = folder === "omo-mem"
    ? `folder "omo-mem"`
    : `folder "memory" of folder "omo-mem"`;

  const script = `
tell application "Notes"
  try
    tell ${folderScript}
      set noteNames to {}
      repeat with n in notes
        set end of noteNames to name of n
      end repeat
      return noteNames
    end tell
  on error
    return {}
  end try
end tell
`;
  const raw = await runAppleScript(script);
  if (!raw || raw === "{}") return [];
  // AppleScript returns comma-separated list like: SOUL.md, MEMORY.md
  return raw.split(", ").map(s => s.trim()).filter(Boolean);
}

// ─── Conflict resolution via opencode CLI ─────────────────────────────────────

async function resolveConflict(relPath, diskContent, notesContent) {
  warn("Conflict detected, resolving via opencode", { relPath });

  const prompt = `You are merging two conflicting versions of a markdown memory file.

File: ${relPath}

=== DISK VERSION ===
${diskContent ?? "(file does not exist on disk)"}

=== APPLE NOTES VERSION ===
${notesContent ?? "(note does not exist in Apple Notes)"}
=== END ===

Instructions:
- Produce a single merged markdown document that preserves ALL information from both versions.
- If both versions have the same section, merge their content without duplicating identical lines.
- Prefer the more detailed/recent version for conflicting lines.
- Do NOT add any commentary, preamble, or explanation — output ONLY the merged markdown content.
`;

  try {
    const { stdout } = await execFileAsync(
      "opencode",
      ["run", "--no-memory", "--output", "text", prompt],
      { timeout: 120_000, maxBuffer: 10 * 1024 * 1024 }
    );
    const merged = stdout.trim();
    if (!merged) throw new Error("opencode returned empty merge result");
    info("Conflict resolved", { relPath, mergedLength: merged.length });
    return merged;
  } catch (err) {
    error("opencode conflict resolution failed, keeping disk version", { relPath, err: err.message });
    // Fallback: keep disk version (safer — disk is the primary source for the plugin)
    return diskContent ?? notesContent ?? "";
  }
}

// ─── Per-file sync logic ───────────────────────────────────────────────────────

/**
 * Sync a single file. Mutates `state[relPath]` in place.
 */
async function syncFile(relPath, state) {
  const loc = noteLocation(relPath);
  const prevState = state[relPath] ?? { diskHash: null, notesHash: null };

  // Read current content from both sides
  const [diskContent, notesContent] = await Promise.all([
    diskRead(relPath),
    notesRead(loc).catch(err => {
      warn("Failed to read Notes, skipping this file", { relPath, err: err.message });
      return undefined; // undefined = skip
    }),
  ]);

  // If Notes read errored (returned undefined), skip entirely
  if (notesContent === undefined) return;

  const diskHash = sha256(diskContent ?? "");
  const notesHash = sha256(notesContent ?? "");

  // No changes anywhere
  if (diskHash === prevState.diskHash && notesHash === prevState.notesHash) {
    return; // nothing to do
  }

  const diskChanged = diskHash !== prevState.diskHash;
  const notesChanged = notesHash !== prevState.notesHash;

  let resolvedContent = null;

  if (diskChanged && notesChanged && prevState.diskHash !== null) {
    // CONFLICT: both sides changed since last sync
    resolvedContent = await resolveConflict(relPath, diskContent, notesContent);
    await diskWrite(relPath, resolvedContent);
    await notesWrite(loc, resolvedContent);
    info("Conflict resolved and both sides updated", { relPath });
  } else if (diskChanged && !notesChanged) {
    // Disk is newer → push to Notes
    resolvedContent = diskContent ?? "";
    await notesWrite(loc, resolvedContent);
    info("Disk → Notes", { relPath });
  } else if (!diskChanged && notesChanged) {
    // Notes is newer → pull to disk
    resolvedContent = notesContent ?? "";
    await diskWrite(relPath, resolvedContent);
    info("Notes → Disk", { relPath });
  } else if (prevState.diskHash === null) {
    // First sync: both exist, no prior state — disk wins (primary source)
    resolvedContent = diskContent ?? notesContent ?? "";
    if (diskContent !== null && notesContent !== diskContent) {
      await notesWrite(loc, resolvedContent);
      info("Initial sync: Disk → Notes", { relPath });
    } else if (diskContent === null && notesContent !== null) {
      await diskWrite(relPath, resolvedContent);
      info("Initial sync: Notes → Disk", { relPath });
    }
  }

  // Update state with new hashes
  const finalContent = resolvedContent ?? diskContent ?? notesContent ?? "";
  state[relPath] = {
    diskHash: sha256(finalContent),
    notesHash: sha256(finalContent),
    lastSynced: new Date().toISOString(),
  };
}

// ─── Notes → disk discovery (pull new notes from Apple Notes) ─────────────────

/**
 * Discover notes in Apple Notes that don't exist on disk yet and pull them.
 */
async function discoverNewNotes(state) {
  // Check memory subfolder for new daily notes
  let noteNames;
  try {
    noteNames = await notesList("omo-mem/memory");
  } catch (err) {
    warn("Failed to list Notes memory folder", { err: err.message });
    return;
  }

  for (const noteName of noteNames) {
    // Note names are bare dates like "2026-03-06"
    const relPath = `memory/${noteName}.md`;
    const diskContent = await diskRead(relPath);
    if (diskContent === null && !state[relPath]) {
      // Note exists in Notes but not on disk — pull it
      const notesContent = await notesRead({ folder: "omo-mem/memory", noteName }).catch(() => null);
      if (notesContent !== null) {
        await diskWrite(relPath, notesContent);
        const h = sha256(notesContent);
        state[relPath] = { diskHash: h, notesHash: h, lastSynced: new Date().toISOString() };
        info("Discovered new note in Apple Notes → Disk", { relPath });
      }
    }
  }
}

// ─── Main sync loop ────────────────────────────────────────────────────────────

async function syncAll() {
  info("Sync cycle start");
  let state = await loadState();

  try {
    await ensureNotesFolders();
  } catch (err) {
    error("Failed to ensure Notes folders — Apple Notes may not be available", { err: err.message });
    return;
  }

  // Discover new notes from Apple Notes side
  await discoverNewNotes(state);

  // Build file list: static files + all daily files on disk
  const dailyFiles = await listDailyFiles();
  const allFiles = [...STATIC_FILES, ...dailyFiles];

  // Deduplicate
  const fileSet = [...new Set(allFiles)];

  // Sync each file sequentially (avoid hammering AppleScript)
  for (const relPath of fileSet) {
    try {
      await syncFile(relPath, state);
    } catch (err) {
      error("Error syncing file", { relPath, err: err.message });
    }
  }

  await saveState(state);
  info("Sync cycle complete", { files: fileSet.length });
}

// ─── Entry point ──────────────────────────────────────────────────────────────

async function main() {
  info("omo-mem sync daemon starting", {
    MEMORY_DIR,
    INTERVAL_MS,
    DRY_RUN,
    STATE_FILE,
  });

  if (DRY_RUN) {
    warn("DRY_RUN mode enabled — no writes will occur");
  }

  // Graceful shutdown
  let shuttingDown = false;
  const shutdown = (sig) => {
    if (shuttingDown) return;
    shuttingDown = true;
    info(`Received ${sig}, shutting down gracefully`);
    process.exit(0);
  };
  process.on("SIGTERM", () => shutdown("SIGTERM"));
  process.on("SIGINT", () => shutdown("SIGINT"));

  // Initial sync immediately
  try {
    await syncAll();
  } catch (err) {
    error("Initial sync failed", { err: err.message });
  }

  // Then poll on interval
  const timer = setInterval(async () => {
    if (shuttingDown) {
      clearInterval(timer);
      return;
    }
    try {
      await syncAll();
    } catch (err) {
      error("Sync cycle failed", { err: err.message });
    }
  }, INTERVAL_MS);

  info(`Daemon running. Next sync in ${INTERVAL_MS / 1000}s`);
}

main().catch(err => {
  error("Fatal error", { err: err.message });
  process.exit(1);
});
