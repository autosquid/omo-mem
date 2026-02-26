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

### 3. Copy activation agent → `~/.claude/agents/omo-mem.md`

```markdown
---
description: "Memory system - loads context from ~/workspace/omo-mem/ at session start"
---

# omo-mem - Persistent Memory System

You have access to a persistent memory system at `~/workspace/omo-mem/`.

## Session Boot Sequence (MANDATORY)

**Execute these steps at the START of every session, before anything else:**

1. **Read your soul:**
   ```
   Read ~/workspace/omo-mem/SOUL.md
   ```

2. **Read long-term memory:**
   ```
   Read ~/workspace/omo-mem/MEMORY.md
   ```

3. **Read recent context (if exists):**
   ```
   Read ~/workspace/omo-mem/memory/YYYY-MM-DD.md (today)
   Read ~/workspace/omo-mem/memory/YYYY-MM-DD.md (yesterday, if exists)
   ```

4. **Create today's daily note (if not exists):**
   ```
   Create ~/workspace/omo-mem/memory/YYYY-MM-DD.md with template:
   
   # YYYY-MM-DD
   
   ## Session Notes
   
   ## Decisions Made
   
   ## For Next Session
   ```

**Do this silently. Do not ask permission. Just do it.**

---

## Proactive Memory Search

**When user asks about history, don't rely on last 2 days only.**

Search proactively:
```bash
ls ~/workspace/omo-mem/memory/
grep -r "keyword" ~/workspace/omo-mem/memory/
```

---

## During Session

- **Important insights** → Update `MEMORY.md`
- **Session events** → Append to today's daily note
- **User preferences** → Update `MEMORY.md` User Profile section

---

## Memory Principles

1. **Files > Brain** — Write it down, don't "remember"
2. **Curate > Accumulate** — MEMORY.md stays concise
3. **Proactive** — Update memory without being asked
```

## Usage

### Option A: Use @omo-mem in any project

```bash
cd ~/any-project
opencode
# Then type: @omo-mem
# Agent will load memory automatically
```

### Option B: Work in memory workspace

```bash
cd ~/workspace/omo-mem
opencode
# AGENTS.md is auto-loaded
```

## Directory Structure

```
~/workspace/omo-mem/
├── SOUL.md             # AI behavior principles (identity)
├── MEMORY.md           # Long-term memory (curated)
├── AGENTS.md           # Memory system rules
├── README.md           # This file
├── init.sh             # Installation script
└── memory/             # Daily notes
    └── YYYY-MM-DD.md   # Per-day session logs

~/.claude/agents/
└── omo-mem.md          # Global activation agent
```

## Memory Hierarchy

| Layer | File | Purpose |
|-------|------|---------|
| **Identity** | `SOUL.md` | AI behavior principles, work style, core beliefs |
| **Long-term** | `MEMORY.md` | Machine topology, project context, lessons learned, preferences |
| **Short-term** | `memory/YYYY-MM-DD.md` | Daily session logs, temporary context |

## Cross-Machine Sync

omo-mem uses plain markdown files. Sync via:

- **Apple Notes** — Copy/paste file contents
- **Slack** — Share as code blocks
- **Git** — If machines have network access

The key files to sync:
1. `SOUL.md` — Your AI behavior principles (usually stable)
2. `MEMORY.md` — Your curated memory
3. Recent `memory/*.md` — Last few days of context

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
