# Daily-AI

## Goal
Publish a deep, credible, and practical daily AI intelligence briefing to GitHub Pages.

## Operating model
- Strategy/approval: Liam + Baby Teto
- Execution: subagents when substantial
- Standard: follow `../../AGENT_JOBS.md` for every substantial task

## Job lanes
`backlog` → `ready` → `running` → `review` → `blocked` → `done`

## Key files
- `index.html` (site UI)
- `data/posts.json` (newest-first content)
- `DAILY_EDITORIAL_GUIDE.md` (quality baseline)
- `scripts/update_daily_ai.sh` (automation)
- `TASKS.json` (job queue + ownership)

## Done definition (daily refresh)
- New entry added to top of `data/posts.json`
- Required sections present (stats, breaking, OSS, GitHub, local, API, implementation)
- Links included and claims source-backed
- Commit pushed to `main` (Pages auto-refresh)
