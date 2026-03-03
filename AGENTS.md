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
| Install on a new machine | `init.sh` | Also creates `~/.claude/agents/omo-mem.md` |
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
├── init.sh          # Install: creates all files + ~/.claude/agents/omo-mem.md
├── sync-setup.sh    # Syncthing cross-device sync helper
├── .stignore        # Syncthing exclusion patterns
└── memory/          # Short-term layer
    └── YYYY-MM-DD.md
```

---

## Session Startup

**Before doing anything else, execute these steps:**

1. **Read `SOUL.md`** — Your core identity and behavior principles
2. **Read `MEMORY.md`** — Your long-term memory (machine topology, project context, lessons learned)
3. **Read `memory/YYYY-MM-DD.md`** (today + yesterday) — Recent context
4. **Create today's note** — If `memory/YYYY-MM-DD.md` doesn't exist, create it

Don't ask for permission. Just do it.

---

## Memory Hierarchy

| Layer | File | Purpose |
|-------|------|---------|
| **Identity** | `SOUL.md` | AI behavior principles, work style, core beliefs |
| **Long-term** | `MEMORY.md` | Machine topology, project context, lessons learned, preferences |
| **Short-term** | `memory/YYYY-MM-DD.md` | Daily raw notes, session logs |

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
# Install on new machine
./init.sh

# Set up cross-device sync (Syncthing)
./sync-setup.sh

# Search memory history
grep -r "keyword" memory/

# Find sync conflicts
find . -name '*.sync-conflict*'

# Check Syncthing status (macOS)
brew services info syncthing

# Activate in any opencode session
@omo-mem
```

---

## ANTI-PATTERNS

- **Don't** add code, tests, or build tooling — pure markdown system
- **Don't** commit/push without being asked
- **Don't** let `MEMORY.md` accumulate raw logs — curate, don't dump
- **Don't** pretend to remember previous sessions — read the files
- **Don't** edit `.sisyphus/` — opencode runtime data, excluded from sync
- **Don't** version daily notes in git — they sync via Syncthing per-device

---

## Core Principles

1. **Files > Brain** — Write it down, don't "remember"
2. **Curate > Accumulate** — MEMORY.md stays concise, not a log
3. **Proactive Maintenance** — Don't wait to be asked to update memory

---

*Make it yours. Add your own conventions as you figure out what works.*
