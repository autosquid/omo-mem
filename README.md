# omo-mem

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![opencode plugin](https://img.shields.io/badge/opencode-plugin-blue)](https://opencode.ai)

Persistent memory plugin for [opencode](https://opencode.ai). Gives the AI cross-session continuity — it remembers who you are, what you're working on, and what happened last session.

**How it works:** Three markdown files form a memory hierarchy injected into every session's system prompt:
- `SOUL.md` — AI behavior principles and work style (identity)
- `MEMORY.md` — Long-term knowledge: projects, gotchas, preferences
- `memory/YYYY-MM-DD.md` — Daily session logs (short-term)

The plugin also exposes 6 CRUD tools so the AI can read and write memory during sessions.

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

After install, start opencode in any project — memory is injected automatically. No `@mention` needed.

## Usage

```bash
cd ~/any-project
opencode
# Memory is automatically injected. The AI knows who you are.
```

To edit memory directly:
```bash
cd ~/workspace/omo-mem
opencode
# AI has full access to memory tools
```

## Directory Structure

```
~/workspace/omo-mem/
├── SOUL.md             # AI behavior principles (identity)
├── MEMORY.md           # Long-term memory (curated)
├── AGENTS.md           # Memory system rules (injected as project context)
├── README.md           # This file
├── init.sh             # Installation script
├── deploy-plugin.sh    # Rebuild & redeploy plugin bundle after source changes
├── sync-daemon.js      # Apple Notes ↔ disk bidirectional sync (macOS)
├── sync-setup.sh       # Syncthing cross-device sync helper
├── plugin/
│   └── omo-mem.js      # opencode plugin source
└── memory/             # Daily notes (gitignored — local only)
    └── YYYY-MM-DD.md
```

## Plugin Architecture

omo-mem v2 is implemented as an opencode plugin:

- **Location**: `~/.config/opencode/plugins/omo-mem.js` (self-contained Bun bundle)
- **Registration**: Automatically added to `~/.config/opencode/opencode.json` by `init.sh`
- **Auto-injection**: Uses `experimental.chat.system.transform` hook to inject SOUL.md, MEMORY.md, and today's daily note into every session's system prompt
- **Memory tools**: Exposes 6 CRUD tools (`memory_list`, `memory_read`, `memory_write`, `memory_append`, `memory_patch`, `memory_delete_lines`)
- **Session initialization**: Creates today's daily note on `session.created` event if it doesn't exist
- **Deployment**: `init.sh` builds the bundle via `bun build`; run `./deploy-plugin.sh` after editing `plugin/omo-mem.js`

### Memory Tools

| Tool | Description |
|------|-------------|
| `memory_list` | List all memory files |
| `memory_read` | Read SOUL.md, MEMORY.md, daily note, or any `memory/YYYY-MM-DD.md` |
| `memory_write` | Overwrite a file (SOUL.md write-protected) |
| `memory_append` | Append to a file without reading first |
| `memory_patch` | Find-and-replace (first occurrence) |
| `memory_delete_lines` | Delete a line range (1-indexed, inclusive) |

## Memory Hierarchy

| Layer | File | Purpose |
|-------|------|---------|
| **Identity** | `SOUL.md` | AI behavior principles, work style, core beliefs |
| **Long-term** | `MEMORY.md` | Machine topology, project context, lessons learned, preferences |
| **Short-term** | `memory/YYYY-MM-DD.md` | Daily session logs, temporary context |

## Customization

Edit `MEMORY.md` to add your own context:
- Machine topology
- Project architecture
- Personal gotchas and lessons
- Preferences and work style

Edit `SOUL.md` to adjust AI behavior principles. Changes take effect immediately on the next session.

## Cross-Machine Sync

### Apple Notes sync (macOS — automatic)

`init.sh` installs `sync-daemon.js` as a launchd service. It syncs SOUL.md, MEMORY.md, and all daily notes bidirectionally between disk and Apple Notes every 60 seconds. This enables cross-machine sync via iCloud without Syncthing.

```bash
tail -f /tmp/omo-mem-sync.log    # monitor
launchctl unload ~/Library/LaunchAgents/com.omo-mem.sync.plist   # stop
launchctl load ~/Library/LaunchAgents/com.omo-mem.sync.plist     # start
```

### Syncthing (all platforms)

For direct device-to-device sync without iCloud:

```bash
./sync-setup.sh   # guided setup
```

See [Syncthing docs](https://docs.syncthing.net/) for manual setup.

## Development

After editing `plugin/omo-mem.js`, rebuild and deploy:

```bash
./deploy-plugin.sh
# Restart opencode for changes to take effect
```

Requirements: [Bun](https://bun.sh) ≥ 1.0

## License

MIT — see [LICENSE](LICENSE)
