# AGENTS.md - omo-mem Memory System

This is your memory workspace. Files are your memory — don't rely on "mental notes."

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

Proactively search the `memory/` directory:
```
# List all daily notes
ls memory/

# Search keywords
grep -r "keyword" memory/

# Read specific date
cat memory/2026-02-15.md
```

**Search priority:**
1. Search `MEMORY.md` first (curated long-term memory)
2. If not found, grep the `memory/` directory
3. Once found, read and report the results

**Typical scenarios:**
- "What was the conclusion from our discussion about X?" → Search memory/ directory
- "How did we solve that bug last time?" → grep "bug" or related keywords
- "That environment we configured before..." → Check MEMORY.md first, then search daily notes

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

Every few days, proactively execute:

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

## Core Principles

1. **Files > Brain** — Write it down, don't "remember"
2. **Curate > Accumulate** — MEMORY.md stays concise, not a log
3. **Proactive Maintenance** — Don't wait to be asked to update memory

---

*Make it yours. Add your own conventions as you figure out what works.*
