#!/bin/bash
# omo-mem init script
# Creates persistent memory system for oh-my-opencode / opencode
#
# Usage:
#   curl -fsSL <raw-url> | bash
#   # or
#   ./init.sh
#
# This script creates:
#   ~/workspace/omo-mem/          - Memory workspace
#   ~/.config/opencode/plugins/   - Opencode plugin directory

set -e

OMO_MEM_DIR="${OMO_MEM_DIR:-$HOME/workspace/omo-mem}"
OPENCODE_PLUGINS_DIR="$HOME/.config/opencode/plugins"
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"

echo "🧠 Installing omo-mem..."
echo ""

# Create directories
mkdir -p "$OMO_MEM_DIR/memory"
mkdir -p "$OMO_MEM_DIR/plugin"
mkdir -p "$OPENCODE_PLUGINS_DIR"

# Create SOUL.md
if [ ! -f "$OMO_MEM_DIR/SOUL.md" ]; then
cat > "$OMO_MEM_DIR/SOUL.md" << 'SOUL_EOF'
# SOUL.md - AI Behavior Principles

*This is your core identity. Read it at the start of every session. Let it guide your behavior.*

---

## Core Beliefs

### Be Genuinely Useful, Not Performatively Useful
- Solve actual problems, don't show off capabilities
- Give answers directly, skip the preamble
- If uncertain, say so — don't fake confidence

### Have Your Own Opinions
- You can disagree with the user's approach
- You can have preferences ("I'd suggest X over Y because...")
- You can say "this approach has problems"

### Try First, Ask Later
- If you can look it up, don't ask
- If you can infer it, don't confirm
- When resources are available, solve it yourself

### Earn Trust Through Competence
- Less talk, more action
- Code quality speaks for itself
- When you make mistakes, own them and fix them

---

## Memory & Continuity

**Every session, you start fresh.** These files are your memory:

- `SOUL.md` — Who you are (you're reading it now)
- `MEMORY.md` — What you remember (long-term memory)
- `memory/YYYY-MM-DD.md` — What happened recently (short-term memory)

Without these files, you remember nothing. **Files > Brain.**

---

## Work Style

### Code
- Match existing code style, don't impose "better" conventions
- Minimize changes: fixing a bug means fixing the bug, not refactoring along the way
- Type safety: never use `as any`, `@ts-ignore`

### Communication
- Be concise. One sentence is enough, don't use three
- Match the user's language (Chinese → Chinese, English → English)
- No flattery ("Great question!", "Excellent idea!")

### When Failing
- Acknowledge it: "That approach didn't work, trying another"
- Don't repeat the same failing approach
- After three failures, stop and reassess

---

## Boundaries

### Do
- Write code, debug, refactor
- Explain technical concepts
- Propose better approaches
- Record important information to memory files

### Don't
- Commit/push without being asked
- Delete tests to "fix" the build
- Large-scale refactoring (unless explicitly requested)
- Pretend to remember previous sessions (read the files!)

---

*This is your soul. It defines how you work, communicate, and think. Internalize it.*
SOUL_EOF
echo "✓ Created $OMO_MEM_DIR/SOUL.md"
else
echo "• Skipped SOUL.md (already exists)"
fi

# Create MEMORY.md
if [ ! -f "$OMO_MEM_DIR/MEMORY.md" ]; then
cat > "$OMO_MEM_DIR/MEMORY.md" << 'MEMORY_EOF'
# MEMORY.md - Long-term Memory

*Last updated: YYYY-MM-DD*

---

## 🖥️ Machines

<!-- Machine topology, network constraints, environment configs -->

| Machine | Network | Tools | Notes |
|---------|---------|-------|-------|
| example | External | opencode | Primary dev machine |

---

## 🏗️ Projects

<!-- Tech stack, architecture, key decisions for each project -->

---

## 🐛 Gotchas

<!-- Pitfalls encountered, workarounds, "the correct way to use this API is..." -->

---

## ⚙️ Preferences

<!-- Code style, commit format, workflow preferences -->

---

## 📚 Reference

<!-- Frequently used commands, config snippets, useful links -->

### oh-my-opencode
- Plugin system: `~/.config/opencode/plugins/*.js`
- Project agents: `AGENTS.md` in project root

---

## 🧠 Core Knowledge

<!-- Domain knowledge, business logic, tech stack understanding -->

---

## 🏆 Achievements

<!-- Completed projects, milestones -->

---

## 💡 Lessons Learned

<!-- Valuable lessons worth remembering long-term -->

---

## 📝 Ongoing

<!-- In-progress projects/tasks, tracked across sessions -->

---

## 🔮 Future Ideas

<!-- Idea pool, directions to explore -->

---

*Keep this concise. Daily notes go in `memory/YYYY-MM-DD.md`. Promote valuable insights here.*
MEMORY_EOF
echo "✓ Created $OMO_MEM_DIR/MEMORY.md"
else
echo "• Skipped MEMORY.md (already exists)"
fi

# Create AGENTS.md
if [ ! -f "$OMO_MEM_DIR/AGENTS.md" ]; then
cat > "$OMO_MEM_DIR/AGENTS.md" << 'AGENTS_EOF'
# AGENTS.md - omo-mem Memory System

**Generated:** 2026-03-04 | **Commit:** 482f37b | **Branch:** master

This is your memory workspace. Files are your memory — don't rely on "mental notes."

---

## OVERVIEW

Persistent memory system for opencode/oh-my-opencode. Enables cross-session continuity via a three-layer markdown hierarchy: **SOUL.md** (identity) → **MEMORY.md** (long-term) → **memory/YYYY-MM-DD.md** (daily). Pure markdown — no code, no build step. Cross-machine sync via Syncthing.

---

## WHERE TO LOOK

| Task | File | Notes |
|------|------|-------|
| AI behavior, work style, boundaries | `SOUL.md` | Identity layer — read first at session start |
| Machines, projects, lessons, gotchas | `MEMORY.md` | Long-term layer — keep curated |
| Today's session context | `memory/YYYY-MM-DD.md` | Short-term layer — raw logs |
| Search history > 2 days back | `memory/*.md` | `grep -r "keyword" memory/` |
| Install on a new machine | `init.sh` | init.sh installs plugin, patches opencode.json |
| Cross-device sync setup | `sync-setup.sh` | Syncthing public relays, no port forwarding |
| Sync exclusion rules | `.stignore` | `.git`, `.sisyphus`, `.DS_Store` excluded |

---

## STRUCTURE

```
~/workspace/omo-mem/
├── SOUL.md          # Identity layer — AI principles & boundaries
├── MEMORY.md        # Long-term layer — curated knowledge
├── AGENTS.md        # This file — memory system rules
├── README.md        # User docs + sync setup guide
├── init.sh          # Install: creates all files + plugin symlink
├── sync-setup.sh    # Syncthing cross-device sync helper
├── .stignore        # Syncthing exclusion patterns
├── plugin/          # opencode plugin (omo-mem.js)
└── memory/          # Short-term layer
    └── YYYY-MM-DD.md
```

---

## Session Startup

omo-mem plugin automatically injects SOUL.md, MEMORY.md, and today's daily note into every session's system prompt. No `@omo-mem` mention needed.

---

## Memory Hierarchy

| Layer | File | Purpose |
|-------|------|---------|
| **Identity** | `SOUL.md` | AI behavior principles, work style, core beliefs |
| **Long-term** | `MEMORY.md` | Machine topology, project context, lessons learned, preferences |
| **Short-term** | `memory/YYYY-MM-DD.md` | Daily raw notes, session logs |

---

## Memory Tools

The plugin exposes 6 memory CRUD tools:

- **memory_list** — List all memory files (SOUL.md, MEMORY.md, daily notes)
- **memory_read** — Read a file. Args: `file` (`"SOUL.md"`, `"MEMORY.md"`, `"daily"`, or `"memory/YYYY-MM-DD.md"`)
- **memory_write** — Overwrite a file entirely. SOUL.md is read-only. Args: `file`, `content`
- **memory_append** — Append to a file without reading first. SOUL.md is read-only. Args: `file`, `content`
- **memory_patch** — Find-and-replace exact text. Allowed on all files including SOUL.md. Args: `file`, `find`, `replace`
- **memory_delete_lines** — Delete line range (1-indexed, inclusive). SOUL.md is read-only. Args: `file`, `from_line`, `to_line`

---

## Proactive Memory Search

**When the user asks about historical context ("what did we do before", "that bug last time"), don't just look at the last two days.**

```bash
ls memory/                    # list all daily notes
grep -r "keyword" memory/     # search across all notes
```

**Search priority:**
1. `MEMORY.md` first (curated long-term memory)
2. If not found, grep `memory/` directory
3. Read and report results

---

## What to Write Where

### → Update MEMORY.md
- New machine/environment configurations
- Key architectural decisions for projects
- Problems encountered and solutions
- Changes in work preferences
- Technical knowledge worth remembering long-term

### → Write to daily note
- What happened during the session
- Debugging process and attempts
- Temporary context
- Information needed for next session

---

## Periodic Maintenance

Every few days:
1. **Review** — Read recent `memory/YYYY-MM-DD.md` files
2. **Curate** — Extract valuable content into `MEMORY.md`
3. **Prune** — Remove outdated information from `MEMORY.md`

---

## Daily Note Template

```markdown
# YYYY-MM-DD

## Session Notes
<!-- What happened during this session -->

## Decisions Made
<!-- Important decisions and their rationale -->

## For Next Session
<!-- Context needed for the next session -->
```

---

## COMMANDS

```bash
# Install on new machine (custom path: OMO_MEM_DIR=/custom/path ./init.sh)
./init.sh

# Set up cross-device sync (Syncthing)
./sync-setup.sh

# Search memory history
grep -r "keyword" memory/

# Find sync conflicts
find . -name '*.sync-conflict*'

# Check Syncthing status (macOS)
brew services info syncthing
```

---

## ANTI-PATTERNS

- **Don't** add code, tests, or build tooling — pure markdown system
- **Don't** commit/push without being asked
- **Don't** let `MEMORY.md` accumulate raw logs — curate, don't dump
- **Don't** pretend to remember previous sessions — read the files
- **Don't** edit `.sisyphus/` — opencode runtime data, excluded from sync
- **Don't** version daily notes in git — they sync via Syncthing per-device
- **Don't** try to `@omo-mem` — the plugin is always active

---

## Core Principles

1. **Files > Brain** — Write it down, don't "remember"
2. **Curate > Accumulate** — MEMORY.md stays concise, not a log
3. **Proactive Maintenance** — Don't wait to be asked to update memory

---

*Make it yours. Add your own conventions as you figure out what works.*
AGENTS_EOF
echo "✓ Created $OMO_MEM_DIR/AGENTS.md"
else
echo "• Skipped AGENTS.md (already exists)"
fi

# Create opencode plugin
cat > "$OMO_MEM_DIR/plugin/omo-mem.js" << 'PLUGIN_EOF'
import fs from "fs/promises";
import path from "path";
import os from "os";
import { tool } from "@opencode-ai/plugin";

// === CONFIGURATION ===
const MEMORY_DIR = process.env.OMO_MEM_DIR ?? path.join(os.homedir(), "workspace/omo-mem");

// === SESSION CACHE ===
// Keyed by date string (YYYY-MM-DD) to prevent repeated disk reads per LLM turn
const memoryCache = new Map();

// === UTILITY FUNCTIONS ===

function getTodayDateString() {
  return new Date().toISOString().slice(0, 10);
}

function resolvePath(file) {
  if (file === "daily") {
    const today = getTodayDateString();
    return path.join(MEMORY_DIR, "memory", `${today}.md`);
  }
  return path.join(MEMORY_DIR, file);
}

async function safeReadFile(filePath) {
  try {
    return await fs.readFile(filePath, "utf-8");
  } catch (err) {
    if (err.code === "ENOENT") {
      return "";
    }
    throw err;
  }
}

async function ensureDirectoryExists(filePath) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
}

function isSoulFile(file) {
  return file === "SOUL.md" || file.endsWith("/SOUL.md");
}

async function createDailyNote(dailyPath) {
  const today = getTodayDateString();
  const template = `# ${today}

## Session Notes

## Decisions Made

## For Next Session
`;
  await ensureDirectoryExists(dailyPath);
  await fs.writeFile(dailyPath, template, "utf-8");
}

// === PLUGIN EXPORT ===

export default async function plugin(_input) {
  return {
    // === SYSTEM PROMPT INJECTION ===
    "experimental.chat.system.transform": async (_input, output) => {
      const today = getTodayDateString();
      
      // Check cache first
      if (memoryCache.has(today)) {
        const cached = memoryCache.get(today);
        output.system.push(cached);
        return;
      }

      // Read memory files
      const soulPath = path.join(MEMORY_DIR, "SOUL.md");
      const memoryPath = path.join(MEMORY_DIR, "MEMORY.md");
      const dailyPath = path.join(MEMORY_DIR, "memory", `${today}.md`);

      const soulContent = await safeReadFile(soulPath);
      const memoryContent = await safeReadFile(memoryPath);
      const dailyContent = await safeReadFile(dailyPath);

      // Build injected content with XML tags
      let injected = "";
      
      if (soulContent) {
        injected += `<omo-mem:soul>\n${soulContent}\n</omo-mem:soul>\n\n`;
      }
      
      if (memoryContent) {
        injected += `<omo-mem:memory>\n${memoryContent}\n</omo-mem:memory>\n\n`;
      }
      
      if (dailyContent) {
        injected += `<omo-mem:daily date="${today}">\n${dailyContent}\n</omo-mem:daily>\n`;
      }

      // Cache and inject
      memoryCache.set(today, injected);
      output.system.push(injected);
    },

    // === SESSION LIFECYCLE HOOKS ===
    event: async ({ event }) => {
      if (event.type === "session.created") {
        const today = getTodayDateString();
        const dailyPath = path.join(MEMORY_DIR, "memory", `${today}.md`);
        
        // Create today's daily note if missing
        try {
          await fs.access(dailyPath);
        } catch {
          await createDailyNote(dailyPath);
        }
      }
    },

    // === MEMORY CRUD TOOLS ===
    tool: {
      memory_list: tool({
        description: "List all memory files (SOUL.md, MEMORY.md, memory/*.md sorted)",
        args: {},
        async execute(_args, _ctx) {
          try {
            const files = [];
            
            // Add SOUL.md if exists
            const soulPath = path.join(MEMORY_DIR, "SOUL.md");
            try {
              await fs.access(soulPath);
              files.push("SOUL.md");
            } catch {}
            
            // Add MEMORY.md if exists
            const memoryPath = path.join(MEMORY_DIR, "MEMORY.md");
            try {
              await fs.access(memoryPath);
              files.push("MEMORY.md");
            } catch {}
            
            // Add memory/*.md files
            const memoryDirPath = path.join(MEMORY_DIR, "memory");
            try {
              const dailyFiles = await fs.readdir(memoryDirPath);
              const mdFiles = dailyFiles
                .filter(f => f.endsWith(".md"))
                .sort()
                .map(f => `memory/${f}`);
              files.push(...mdFiles);
            } catch {}
            
            return files.join("\n");
          } catch (err) {
            return `Error listing memory files: ${err.message}`;
          }
        }
      }),

      memory_read: tool({
        description: 'Read memory file content. file arg: "SOUL.md" | "MEMORY.md" | "daily" | "memory/YYYY-MM-DD.md"',
        args: {
          file: tool.schema.string().describe('File to read: "SOUL.md", "MEMORY.md", "daily", or "memory/YYYY-MM-DD.md"')
        },
        async execute(args, _ctx) {
          try {
            const filePath = resolvePath(args.file);
            const content = await safeReadFile(filePath);
            
            if (!content) {
              return `File not found: ${args.file}`;
            }
            
            return content;
          } catch (err) {
            return `Error reading ${args.file}: ${err.message}`;
          }
        }
      }),

      memory_write: tool({
        description: "Overwrite memory file content. SOUL.md is write-protected.",
        args: {
          file: tool.schema.string().describe('File to write: "MEMORY.md", "daily", or "memory/YYYY-MM-DD.md"'),
          content: tool.schema.string().describe("Content to write")
        },
        async execute(args, _ctx) {
          try {
            // SOUL.md write protection
            if (isSoulFile(args.file)) {
              return "Error: SOUL.md is write-protected. Use memory_patch if you must edit it.";
            }
            
            const filePath = resolvePath(args.file);
            await ensureDirectoryExists(filePath);
            await fs.writeFile(filePath, args.content, "utf-8");
            
            // Invalidate cache if writing today's daily note
            const today = getTodayDateString();
            if (args.file === "daily" || args.file === `memory/${today}.md`) {
              memoryCache.delete(today);
            }
            
            return `Wrote ${args.content.length} chars to ${args.file}`;
          } catch (err) {
            return `Error writing ${args.file}: ${err.message}`;
          }
        }
      }),

      memory_append: tool({
        description: "Append content to memory file with leading newline. SOUL.md is write-protected.",
        args: {
          file: tool.schema.string().describe('File to append to: "MEMORY.md", "daily", or "memory/YYYY-MM-DD.md"'),
          content: tool.schema.string().describe("Content to append")
        },
        async execute(args, _ctx) {
          try {
            // SOUL.md write protection
            if (isSoulFile(args.file)) {
              return "Error: SOUL.md is write-protected. Use memory_patch if you must edit it.";
            }
            
            const filePath = resolvePath(args.file);
            await ensureDirectoryExists(filePath);
            
            // Read existing content
            const existing = await safeReadFile(filePath);
            
            // Append with leading newline
            const newContent = existing + "\n" + args.content;
            await fs.writeFile(filePath, newContent, "utf-8");
            
            // Invalidate cache if appending to today's daily note
            const today = getTodayDateString();
            if (args.file === "daily" || args.file === `memory/${today}.md`) {
              memoryCache.delete(today);
            }
            
            return `Appended ${args.content.length} chars to ${args.file}`;
          } catch (err) {
            return `Error appending to ${args.file}: ${err.message}`;
          }
        }
      }),

      memory_patch: tool({
        description: "Find-and-replace in memory file (first occurrence only). NO SOUL.md guard - user responsibility.",
        args: {
          file: tool.schema.string().describe('File to patch: "SOUL.md", "MEMORY.md", "daily", or "memory/YYYY-MM-DD.md"'),
          find: tool.schema.string().describe("String to find"),
          replace: tool.schema.string().describe("String to replace with")
        },
        async execute(args, _ctx) {
          try {
            const filePath = resolvePath(args.file);
            const content = await safeReadFile(filePath);
            
            if (!content) {
              return `File not found: ${args.file}`;
            }
            
            if (!content.includes(args.find)) {
              return `Pattern not found in ${args.file}. Hint: "${args.find.slice(0, 50)}${args.find.length > 50 ? "..." : ""}" not matched.`;
            }
            
            const newContent = content.replace(args.find, args.replace);
            await fs.writeFile(filePath, newContent, "utf-8");
            
            // Invalidate cache if patching today's daily note
            const today = getTodayDateString();
            if (args.file === "daily" || args.file === `memory/${today}.md`) {
              memoryCache.delete(today);
            }
            
            return `Patched ${args.file}: replaced ${args.find.length}→${args.replace.length} chars`;
          } catch (err) {
            return `Error patching ${args.file}: ${err.message}`;
          }
        }
      }),

      memory_delete_lines: tool({
        description: "Delete line range from memory file (1-indexed, both endpoints inclusive). SOUL.md is write-protected.",
        args: {
          file: tool.schema.string().describe('File to edit: "MEMORY.md", "daily", or "memory/YYYY-MM-DD.md"'),
          from_line: tool.schema.number().describe("Start line number (1-indexed, inclusive)"),
          to_line: tool.schema.number().describe("End line number (1-indexed, inclusive)")
        },
        async execute(args, _ctx) {
          try {
            // SOUL.md write protection
            if (isSoulFile(args.file)) {
              return "Error: SOUL.md is write-protected. Use memory_patch if you must edit it.";
            }
            
            const filePath = resolvePath(args.file);
            const content = await safeReadFile(filePath);
            
            if (!content) {
              return `File not found: ${args.file}`;
            }
            
            const lines = content.split("\n");
            const totalLines = lines.length;
            
            // Validate bounds (1-indexed)
            if (args.from_line < 1 || args.to_line < 1) {
              return `Error: Line numbers must be >= 1`;
            }
            if (args.from_line > totalLines || args.to_line > totalLines) {
              return `Error: Line range ${args.from_line}-${args.to_line} exceeds file length ${totalLines}`;
            }
            if (args.from_line > args.to_line) {
              return `Error: from_line (${args.from_line}) > to_line (${args.to_line})`;
            }
            
            // Convert to 0-indexed and delete
            const deleteCount = args.to_line - args.from_line + 1;
            lines.splice(args.from_line - 1, deleteCount);
            
            const newContent = lines.join("\n");
            await fs.writeFile(filePath, newContent, "utf-8");
            
            // Invalidate cache if deleting from today's daily note
            const today = getTodayDateString();
            if (args.file === "daily" || args.file === `memory/${today}.md`) {
              memoryCache.delete(today);
            }
            
            return `Deleted ${deleteCount} lines from ${args.file} (${args.from_line}-${args.to_line}). File now has ${lines.length} lines.`;
          } catch (err) {
            return `Error deleting lines from ${args.file}: ${err.message}`;
          }
        }
      })
    }
  };
}
PLUGIN_EOF
echo "✓ Created $OMO_MEM_DIR/plugin/omo-mem.js"

# Create symlink to opencode plugins directory
ln -sf "$OMO_MEM_DIR/plugin/omo-mem.js" "$OPENCODE_PLUGINS_DIR/omo-mem.js"
echo "✓ Symlinked to $OPENCODE_PLUGINS_DIR/omo-mem.js"

# Patch opencode.json to register plugin
PLUGIN_ENTRY="file://$HOME/.config/opencode/plugins/omo-mem.js"

if [ ! -f "$OPENCODE_CONFIG" ]; then
  # Case 1: opencode.json doesn't exist
  echo '{"plugin": ["'"$PLUGIN_ENTRY"'"]}' > "$OPENCODE_CONFIG"
  echo "✓ Created $OPENCODE_CONFIG with plugin entry"
elif command -v jq &> /dev/null; then
  # Case 2-4: File exists, use jq to patch
  TMP_CONFIG=$(mktemp)
  if jq --arg entry "$PLUGIN_ENTRY" '.plugin //= [] | if (.plugin | index($entry)) then . else .plugin += [$entry] end' "$OPENCODE_CONFIG" > "$TMP_CONFIG"; then
    mv "$TMP_CONFIG" "$OPENCODE_CONFIG"
    echo "✓ Updated $OPENCODE_CONFIG with plugin entry"
  else
    rm -f "$TMP_CONFIG"
    echo "⚠️  Failed to patch opencode.json with jq"
  fi
elif command -v python3 &> /dev/null; then
  # Python3 fallback
  python3 << PYTHON_EOF
import json
import sys
try:
    with open('$OPENCODE_CONFIG', 'r') as f:
        config = json.load(f)
    if 'plugin' not in config:
        config['plugin'] = []
    if '$PLUGIN_ENTRY' not in config['plugin']:
        config['plugin'].append('$PLUGIN_ENTRY')
    with open('$OPENCODE_CONFIG', 'w') as f:
        json.dump(config, f, indent=2)
    print('✓ Updated $OPENCODE_CONFIG with plugin entry')
except Exception as e:
    print(f'⚠️  Failed to patch opencode.json with python3: {e}', file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
else
  # Manual fallback
  echo ""
  echo "⚠️  Cannot auto-patch opencode.json (jq and python3 not found)"
  echo "   Please manually add to $OPENCODE_CONFIG:"
  echo '   "plugin": ["'"$PLUGIN_ENTRY"'"]'
  echo ""
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ omo-mem installed successfully!"
echo ""
echo "Directory: $OMO_MEM_DIR"
echo ""
echo "Files created:"
echo "  • $OMO_MEM_DIR/SOUL.md"
echo "  • $OMO_MEM_DIR/MEMORY.md"
echo "  • $OMO_MEM_DIR/AGENTS.md"
echo "  • $OMO_MEM_DIR/memory/"
echo "  • $OMO_MEM_DIR/plugin/omo-mem.js"
echo "  • $OPENCODE_PLUGINS_DIR/omo-mem.js (plugin symlink)"
echo ""
echo "Usage:"
echo "  Start opencode in any project — memory is injected automatically."
echo "  No @mention needed. The plugin runs on every session."
echo ""
echo "To work directly in the memory workspace:"
echo "  cd $OMO_MEM_DIR && opencode"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
