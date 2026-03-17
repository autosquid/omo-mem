# omo-mem

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![opencode plugin](https://img.shields.io/badge/opencode-plugin-blue)](https://opencode.ai)

Standard LLMs have the memory of a goldfish. Every session is a blank slate. omo-mem fixes this by giving your opencode agent a persistent identity and a long-term memory hierarchy that follows you across sessions and machines.

It is a simple, opinionated system built on plain markdown files. No vector databases, no complex RAG pipelines, no proprietary clouds. Just files that you can read, edit, and sync like any other code.

## How it works

omo-mem maintains three plain markdown files that are automatically injected into every session's system prompt:

- **SOUL.md** — Who the AI is. Core behavior principles, work style, and non-negotiable boundaries.
- **MEMORY.md** — What the AI knows. Long-term context like machine topology, project architectures, and hard-learned lessons.
- **memory/YYYY-MM-DD.md** — What happened recently. Daily logs and short-term session context.

The plugin provides 6 CRUD tools so the AI can proactively manage its own memory as you work.

## Installation

### One-line (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/autosquid/omo-mem/master/install.sh | bash
```

### Pin a specific version (recommended for teams)

```bash
OMO_MEM_VERSION=v2.0.0 curl -fsSL https://raw.githubusercontent.com/autosquid/omo-mem/master/install.sh | bash
```

### Agent-driven install

Paste this to your coding agent:

```text
Install and configure omo-mem by following:
https://raw.githubusercontent.com/autosquid/omo-mem/master/docs/install.md
```

Or clone and run:

```bash
git clone https://github.com/autosquid/omo-mem ~/workspace/omo-mem
cd ~/workspace/omo-mem && ./init.sh
```

> **Custom install path:** `OMO_MEM_DIR=/your/path ./init.sh`

After install, start opencode in any project. Memory is injected automatically. No `@mention` required.

## Release Packages

Yes, release packages are worth it. One-line install is convenient; release artifacts make installs auditable and reproducible.

Each tagged release ships:
- `omo-mem.js` (bundled plugin artifact)
- `SHA256SUMS`
- `manifest.json` (version, commit SHA, build metadata)

Verify what you installed:

```bash
shasum -a 256 omo-mem.js
```

Compare with `SHA256SUMS` from the same release.

## Why this stack?

This project exists because most "AI memory" solutions are over-engineered. We made specific choices to keep this tool invisible and reliable:

- **Plain Markdown**: Databases are where data goes to die. Markdown is where it lives. You can grep it, edit it in Vim, or version control it. The AI understands it perfectly without embeddings or vector search.
- **Apple Notes for Sync**: If you use a Mac, you already have a globally synced, encrypted, offline-capable database that works on an airplane. We use a small daemon to bridge your local markdown files to iCloud via Apple Notes. Zero config, zero extra services.
- **Native Plugin API**: We didn't want a wrapper script or a system prompt hack. By building as a proper opencode plugin, we get clean hooks into the session lifecycle and tool registration without monkey-patching your environment.

## Origins

The idea of using plain markdown files as the canonical source of truth for AI memory — human-readable, editable, and git-diffable — was inspired by [OpenClaw](https://github.com/openclaw). We borrowed that philosophy and the file naming conventions (SOUL.md, MEMORY.md). The specific design here — SOUL.md as an identity layer injected into the system prompt, and the opencode plugin that automates it — is our own.

## Directory Structure

```
~/workspace/omo-mem/
├── SOUL.md             # AI behavior principles (identity)
├── MEMORY.md           # Long-term memory (curated)
├── AGENTS.md           # Memory system rules (injected as project context)
├── README.md           # This file
├── init.sh             # Installation script
├── plugin/
│   └── omo-mem.js      # opencode plugin source
├── scripts/
│   ├── build.sh        # Rebuild & redeploy plugin bundle
│   └── notes-sync.js   # Apple Notes ↔ disk bidirectional sync (macOS)
└── memory/             # Daily notes (gitignored — local only)
    └── YYYY-MM-DD.md
```

## Plugin Architecture

omo-mem is implemented as a self-contained opencode plugin:

- **Location**: `~/.config/opencode/plugins/omo-mem.js` (Bun bundle)
- **Auto-injection**: Uses the `experimental.chat.system.transform` hook to inject memory layers into every prompt.
- **Lifecycle**: Automatically creates the daily note on session creation.
- **Tools**: Exposes 6 CRUD tools for the AI to interact with the files.

### Memory Tools

| Tool | Description |
|------|-------------|
| `memory_list` | List all memory files |
| `memory_read` | Read SOUL, MEMORY, or any daily note |
| `memory_write` | Overwrite a file (SOUL.md is write-protected) |
| `memory_append` | Append to a file without reading first |
| `memory_patch` | Find-and-replace (exact match) |
| `memory_delete_lines` | Delete a line range (1-indexed, inclusive) |

## Cross-Machine Sync

`init.sh` installs `scripts/notes-sync.js` as a background service (`launchd`). It syncs your memory files bidirectionally with Apple Notes every 60 seconds, giving you seamless sync across your Macs via iCloud with zero configuration.

```bash
tail -f /tmp/omo-mem-sync.log    # monitor sync status
launchctl unload ~/Library/LaunchAgents/com.omo-mem.sync.plist   # stop
launchctl load ~/Library/LaunchAgents/com.omo-mem.sync.plist     # start
```

## Development

After editing `plugin/omo-mem.js`, rebuild and redeploy:

```bash
./scripts/build.sh
```

Requirements: [Bun](https://bun.sh) ≥ 1.0

## License

MIT — see [LICENSE](LICENSE)
