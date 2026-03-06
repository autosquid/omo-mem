# omo-mem

Persistent memory system for oh-my-opencode / opencode. Enables cross-session memory so you don't start from scratch.

## Quick Install

```bash
# Clone and run init script
git clone <repo-url> ~/workspace/omo-mem
cd ~/workspace/omo-mem && ./init.sh

# Or run init.sh directly (if you have the script)
./init.sh
```

> **Note:** `init.sh` also installs the opencode plugin and patches `opencode.json` for auto-injection.

## Manual Installation (for sh/mba via Apple Notes)

Copy these files to the target machine:

### 1. Create directory structure

```bash
mkdir -p ~/workspace/omo-mem/memory
mkdir -p ~/.claude/agents
```

### 2. Copy core files

| Source | Destination |
|--------|-------------|
| `SOUL.md` | `~/workspace/omo-mem/SOUL.md` |
| `MEMORY.md` | `~/workspace/omo-mem/MEMORY.md` |
| `AGENTS.md` | `~/workspace/omo-mem/AGENTS.md` |

### 3. Install plugin

```bash
mkdir -p ~/.config/opencode/plugins
# Build self-contained bundle (required — symlinks break module resolution)
cp plugin/omo-mem.js ~/.config/opencode/_omo-mem-src.js
bun build ~/.config/opencode/_omo-mem-src.js \
  --outfile ~/.config/opencode/plugins/omo-mem.js \
  --target bun \
  --external "fs/promises" --external "path" --external "os"
rm ~/.config/opencode/_omo-mem-src.js
```

Add to `~/.config/opencode/opencode.json`:
```json
{
  "plugins": ["file://~/.config/opencode/plugins/omo-mem.js"]
}
```

## Usage

The omo-mem plugin auto-loads in every opencode session. Memory is always available — no `@mention` needed.

```bash
cd ~/any-project
opencode
# Memory is automatically injected into every session
```

To work directly in the memory workspace:
```bash
cd ~/workspace/omo-mem
opencode
```
## Directory Structure

```
~/workspace/omo-mem/
├── SOUL.md             # AI behavior principles (identity)
├── MEMORY.md           # Long-term memory (curated)
├── AGENTS.md           # Memory system rules
├── README.md           # This file
├── init.sh             # Installation script
├── deploy-plugin.sh    # Rebuild & redeploy plugin bundle after source changes
├── plugin/
│   └── omo-mem.js      # opencode plugin source
└── memory/             # Daily notes
    └── YYYY-MM-DD.md   # Per-day session logs
```

## Plugin Architecture

omo-mem v2 is implemented as an opencode plugin:

- **Location**: `~/.config/opencode/plugins/omo-mem.js` (self-contained Bun bundle — **not** a symlink)
- **Registration**: Automatically added to `~/.config/opencode/opencode.json` by init.sh
- **Auto-injection**: Uses `experimental.chat.system.transform` hook to inject SOUL.md, MEMORY.md, and today's daily note into every session's system prompt
- **Memory tools**: Exposes 6 CRUD tools (`memory_list`, `memory_read`, `memory_write`, `memory_append`, `memory_patch`, `memory_delete_lines`)
- **Session initialization**: Creates today's daily note on `session.created` event if it doesn't exist
- **Deployment**: `init.sh` builds the bundle via `bun build`; run `./deploy-plugin.sh` after editing `plugin/omo-mem.js`

No `@mention` or manual activation required — the plugin runs automatically in every opencode session.

## Memory Hierarchy

| Layer | File | Purpose |
|-------|------|---------|
| **Identity** | `SOUL.md` | AI behavior principles, work style, core beliefs |
| **Long-term** | `MEMORY.md` | Machine topology, project context, lessons learned, preferences |
| **Short-term** | `memory/YYYY-MM-DD.md` | Daily session logs, temporary context |

## Cross-Machine Sync (Syncthing)

omo-mem syncs across devices using [Syncthing](https://syncthing.net/) with public relays. This allows devices on different networks to sync without port forwarding.

### Quick Setup

```bash
# Run the setup helper
./sync-setup.sh
```

The script will:
- Check if Syncthing is installed (with install instructions if not)
- Show your device ID (needed to connect devices)
- Print step-by-step folder setup instructions

### Manual Setup

1. **Install Syncthing**

   macOS:
   ```bash
   brew install syncthing
   brew services start syncthing
   ```

   Ubuntu:
   ```bash
   # Add official repo
   sudo mkdir -p /etc/apt/keyrings
   sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
   echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
   sudo apt-get update && sudo apt-get install syncthing
   
   # Start service
   systemctl --user enable syncthing
   systemctl --user start syncthing
   ```

2. **Get your device ID**
   ```bash
   syncthing device-id
   ```

3. **Open Web UI**: http://localhost:8384

4. **Add remote devices**: Paste device IDs from other machines

5. **Add omo-mem folder**:
   - Folder Label: `omo-mem`
   - Folder Path: `~/workspace/omo-mem`
   - Share with: Select all your devices

### Synced Files

| Synced | Excluded |
|--------|----------|
| SOUL.md | .git/ |
| MEMORY.md | .DS_Store |
| AGENTS.md | *.swp, *~ |
| memory/*.md | .sisyphus/ |
| README.md | .stversions/ |

See `.stignore` for the full exclusion list.

### Handling Conflicts

When the same file is edited on multiple devices before syncing, Syncthing creates conflict files:

```
MEMORY.sync-conflict-20260226-143052-ABCDEFG.md
```

To resolve:
```bash
# Find conflicts
find ~/workspace/omo-mem -name '*.sync-conflict*'

# Compare with original
diff MEMORY.md MEMORY.sync-conflict-*.md

# Merge manually, then delete conflict file
rm *.sync-conflict*
```

### Security

- All traffic is TLS encrypted end-to-end
- Public relays cannot read your data (they only relay encrypted packets)
- No account required, fully decentralized

### Useful Commands

```bash
# Check device ID
syncthing device-id

# Find sync conflicts
find ~/workspace/omo-mem -name '*.sync-conflict*'

# Check status (macOS)
brew services info syncthing

# Check status (Ubuntu)
systemctl --user status syncthing
```

## Customization

Edit `MEMORY.md` sections to match your needs. The template includes:

- 🖥️ Machine Topology
- 📂 Project Context
- 💡 Lessons Learned
- ⚙️ Preferences

Edit `SOUL.md` to adjust AI behavior principles. The template includes:

- Core beliefs (what makes AI useful)
- Work style (code, communication, failure handling)
- Boundaries (what to do, what not to do)

Add or remove sections as needed.

---

*Inspired by OpenClaw's memory system. Adapted for oh-my-opencode.*
