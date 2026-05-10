# Todo App — Meta Repo

This is the AI context layer for the Todo App project. It holds cross-repo context,
feature specs, and task lists for AI-assisted development.

## What is this repo?

The Todo App is split across 4 separate repos. This repo (todo-meta) is the central
place to work on features that span multiple repos. Instead of jumping between repos
and losing context, you work here — the AI reads context from all repos at once.

## Repos

The 4 app repos are cloned into `repos/` by `setup.sh`. Run `./setup.sh` once to
populate them.

Read each repo's CLAUDE.md for repo-specific conventions before making changes:

- @repos/todo-frontend/CLAUDE.md
- @repos/todo-backend/CLAUDE.md
- @repos/todo-contracts/CLAUDE.md
- @repos/todo-infra/CLAUDE.md

## Folder structure

```
repos/             — live clones of each app repo (gitignored, populated by setup.sh)
specs/             — one folder per feature
specs/<feature>/
  requirements.md  — what the feature does and why
  design.md        — architecture and data model decisions
  tasks.md         — step-by-step implementation checklist
  repos/           — git worktree copies for this feature branch (gitignored)
```

## Active specs

- `specs/add-tags/` — Tags/Labels feature (not yet implemented across all repos)

## Workflow

1. Run `./setup.sh` to clone all repos
2. Open this repo in Claude Code
3. The AI reads context from all 4 CLAUDE.md files automatically
4. Work through a spec's `tasks.md` to implement a feature
5. Commit each repo separately when done
