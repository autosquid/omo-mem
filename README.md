# omo-mem

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![opencode plugin](https://img.shields.io/badge/opencode-plugin-blue)](https://opencode.ai)

Standard LLMs have the memory of a goldfish. Every session is a blank slate. omo-mem fixes this by giving your opencode agent a persistent identity and a long-term memory hierarchy that follows you across sessions and machines.

It is a simple, opinionated system built on plain markdown files. No vector databases, no complex RAG pipelines, no proprietary clouds. Just files that you can read, edit, and sync like any other code.

## How it works

The system maintains a three-layer memory hierarchy that is automatically injected into every session's system prompt:

- **SOUL.md** — Who the AI is. Core behavior principles, work style, and non-negotiable boundaries.
- **MEMORY.md** — What the AI knows. Long-term context like machine topology, project architectures, and hard-learned lessons.
- **memory/YYYY-MM-DD.md** — What happened recently. Daily logs and short-term session context.

The plugin provides 6 CRUD tools so the AI can proactively manage its own memory as you work.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/autosquid/omo-mem/master/init.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/autosquid/omo-mem ~/workspace/omo-mem
cd ~/workspace/omo-mem && ./init.sh
```

> **Custom install path:** `OMO_MEM_DIR=/your/path ./init.sh`

After install, start opencode in any project. Memory is injected automatically. No `@mention` required.

## Why this stack?

This project exists because most "AI memory" solutions are over-engineered. We made specific choices to keep this tool invisible and reliable:

- **Plain Markdown**: Databases are where data goes to die. Markdown is where it lives. You can grep it, edit it in Vim, or version control it. The AI understands it perfectly without embeddings or vector search.
- **Apple Notes for Sync**: If you use a Mac, you already have a globally synced, encrypted, offline-capable database that works on an airplane. We use a small daemon to bridge your local markdown files to iCloud via Apple Notes. Zero config, zero extra services.
- **Native Plugin API**: We didn't want a wrapper script or a system prompt hack. By building as a proper opencode plugin, we get clean hooks into the session lifecycle and tool registration without monkey-patching your environment.

## Origins

The three-layer memory hierarchy and the concept of a "SOUL.md" identity layer were inspired by [OpenClaw](https://github.com/openclaw). We took those core architectural ideas and stripped them down into a lightweight, markdown-first implementation for the opencode ecosystem.

## Directory Structure

```
~/workspace/omo-mem/
├── SOUL.md             # AI behavior principles (identity)
├── MEMORY.md           # Long-term memory (curated)
├── AGENTS.md           # Memory system rules (injected as project context)
├── README.md           # This file
├── init.sh             # Installation script
├── deploy-plugin.sh    # Rebuild & redeploy plugin bundle
├── sync-daemon.js      # Apple Notes ↔ disk bidirectional sync (macOS)
├── sync-setup.sh       # Syncthing cross-device sync helper (Experimental)
├── plugin/
│   └── omo-mem.js      # opencode plugin source
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

### Apple Notes + iCloud (Primary)

This is the designed and tested path for macOS users. `init.sh` installs `sync-daemon.js` as a background service (`launchd`). It syncs your memory files bidirectionally with Apple Notes every 60 seconds. This gives you seamless sync across your Macs via iCloud with zero maintenance.

```bash
tail -f /tmp/omo-mem-sync.log    # monitor sync status
launchctl unload ~/Library/LaunchAgents/com.omo-mem.sync.plist   # stop
launchctl load ~/Library/LaunchAgents/com.omo-mem.sync.plist     # start
```

### Syncthing + Linux (Experimental)

We include a `sync-setup.sh` script for Syncthing-based device-to-device sync. Note that this path is currently **experimental and untested**. If you are running on Linux or want to avoid iCloud, you can use this, but expect to do some manual configuration.

## Development

After editing `plugin/omo-mem.js`, rebuild and redeploy:

```bash
./deploy-plugin.sh
```

Requirements: [Bun](https://bun.sh) ≥ 1.0

## License

MIT — see [LICENSE](LICENSE)
