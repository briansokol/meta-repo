# Todo App — Meta Repo

Central coordination repo for AI-assisted development of the Todo App.

## What is this?

The Todo App is split across four repos. This repo is the **AI context layer**: it holds cross-repo feature specs and task lists so an AI assistant (Claude Code) can read context from all four repos at once, without jumping between them.

The four app repos are:

| Repo | Description |
|------|-------------|
| [todo-frontend](https://github.com/briansokol/todo-frontend) | React + TypeScript + Vite SPA |
| [todo-backend](https://github.com/briansokol/todo-backend) | FastAPI + SQLAlchemy + PostgreSQL |
| [todo-contracts](https://github.com/briansokol/todo-contracts) | OpenAPI spec (source of truth for API shapes) |
| [todo-infra](https://github.com/briansokol/todo-infra) | Docker Compose local dev environment |

## Getting started

```bash
./setup.sh   # clones all four app repos into repos/
```

Then open this repo in Claude Code. It will read all four `CLAUDE.md` files automatically.

## Folder structure

```
repos/               — live clones of each app repo (gitignored, populated by setup.sh)
specs/               — one folder per feature
specs/<feature>/
  requirements.md    — what the feature does and why
  design.md          — architecture and data model decisions
  tasks.md           — step-by-step implementation checklist
  repos/             — git worktree copies for this feature branch (gitignored)
```

## Active specs

- `specs/add-tags/` — Tags/Labels feature (in progress)

## Workflow

1. Run `./setup.sh` to clone all repos into `repos/`
2. Open this repo in Claude Code
3. Pick a spec in `specs/` and work through its `tasks.md`
4. Commit each app repo separately when done
