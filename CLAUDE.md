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


# Agentic SDLC and Spec-Driven Development

Spec-Driven Development (SDD) on an agentic SDLC

## Project Context

### Paths
- Steering: `.sdd/steering/`
- Specs: `specs/`

### Steering vs Specification

**Steering** (`.sdd/steering/`) - Guide AI with project-wide rules and context
**Specs** (`specs/`) - Formalize development process for individual features

### Active Specifications
- Check `specs/` for active specifications
- Use `/sdd-spec-status [feature-name]` to check progress

## Development Guidelines
- Think in English, generate responses in English. All Markdown content written to project files (e.g., requirements.md, design.md, tasks.md, research.md, validation reports) MUST be written in the target language configured for this specification (see spec.json.language).

## Minimal Workflow
- Phase 0 (optional): `/sdd-steering`, `/sdd-steering-custom`
- Discovery: `/sdd-discovery "idea"` — determines action path, writes brief.md + roadmap.md for multi-spec projects
- Phase 1 (Specification):
  - Single spec: `/sdd-spec-quick {feature} [--auto]` or step by step:
    - `/sdd-spec-init "description"`
    - `/sdd-spec-requirements {feature}`
    - `/sdd-validate-gap {feature}` (optional: for existing codebase)
    - `/sdd-spec-design {feature} [-y]`
    - `/sdd-validate-design {feature}` (optional: design review)
    - `/sdd-spec-tasks {feature} [-y]`
  - Multi-spec: `/sdd-spec-batch` — creates all specs from roadmap.md in parallel by dependency wave
- Phase 2 (Implementation): `/sdd-impl {feature} [tasks]`
  - Without task numbers: autonomous mode (subagent per task + independent review + final validation)
  - With task numbers: manual mode (selected tasks in main context, still reviewer-gated before completion)
  - `/sdd-validate-impl {feature}` (standalone re-validation)
- Progress check: `/sdd-spec-status {feature}` (use anytime)

## Skills Structure
Skills are located in `.claude/skills/sdd-*/SKILL.md`
- Each skill is a directory with a `SKILL.md` file
- Skills run inline with access to conversation context
- Skills may delegate parallel research to subagents for efficiency
- Additional files (templates, examples) can be added to skill directories
- `sdd-review` — task-local adversarial review protocol used by reviewer subagents
- `sdd-debug` — root-cause-first debug protocol used by debugger subagents
- `sdd-verify-completion` — fresh-evidence gate before success or completion claims
- **If there is even a 1% chance a skill applies to the current task, invoke it.** Do not skip skills because the task seems simple.

## Development Rules
- 3-phase approval workflow: Requirements → Design → Tasks → Implementation
- Human review required each phase; use `-y` only for intentional fast-track
- Keep steering current and verify alignment with `/sdd-spec-status`
- Follow the user's instructions precisely, and within that scope act autonomously: gather the necessary context and complete the requested work end-to-end in this run, asking questions only when essential information is missing or the instructions are critically ambiguous.

## Steering Configuration
- Load entire `.sdd/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/sdd-steering-custom`)
