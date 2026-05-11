---
name: sdd-steering
description: Maintain .sdd/steering/ as persistent project memory (bootstrap/sync). Use when initializing or updating steering documents.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
metadata:
  shared-rules: "steering-principles.md"
---

# sdd-steering Skill

## Role
You are a specialized skill for maintaining `.sdd/steering/` as persistent project memory.

## Core Mission
**Role**: Maintain `.sdd/steering/` as persistent project memory.

**Mission**:
- Bootstrap: Generate core steering from codebase (first-time)
- Sync: Keep steering and codebase aligned (maintenance)
- Preserve: User customizations are sacred, updates are additive

**Success Criteria**:
- Steering captures patterns and principles, not exhaustive lists
- Code drift detected and reported
- All `.sdd/steering/*.md` treated equally (core + custom)

## Execution Steps

### Step 1: Gather Context

If steering context is already available from conversation, skip redundant file reads.

- For Bootstrap mode: Read templates from `.sdd/settings/templates/steering/`
- For Sync mode: Read all existing `.sdd/steering/*.md` files
- Read `rules/steering-principles.md` from this skill's directory for steering principles

## Scenario Detection

Check `.sdd/steering/` status:

**Bootstrap Mode**: Empty OR missing core files (product.md, tech.md, structure.md)
**Sync Mode**: All core files exist

---

## Bootstrap Flow

1. Load templates from `.sdd/settings/templates/steering/`
2. Analyze codebase (JIT):

#### Parallel Research

The following research areas are independent and can be executed in parallel:
1. **Product analysis**: README, package.json, documentation files for purpose, value, core capabilities
2. **Tech analysis**: Config files, dependencies, frameworks for technology patterns and decisions
3. **Structure analysis**: Directory tree, naming conventions, import patterns for organization
4. **Multi-repo stacks** (when `repos/` directory exists and is non-empty):
   - List the contents of `repos/`
   - For each present repo, read `repos/{repo-name}/CLAUDE.md`
   - Return a structured per-repo summary: repo name, role, tech stack, key conventions
   - This feeds into the `tech.md` generation as a "Per-Repo Stacks" section

After all parallel research completes, synthesize patterns for steering files.

3. Extract patterns (not lists):
   - Product: Purpose, value, core capabilities
   - Tech: Frameworks, decisions, conventions; **Multi-repo (when `repos/` exists)**: Cross-repo dependency direction, change propagation order, per-repo tech stacks, and shared contracts (e.g., OpenAPI spec as source of truth)
   - Structure: Organization, naming, imports
4. Generate steering files (follow templates); when `repos/` is non-empty: add a `## Per-Repo Stacks` section to `tech.md` listing each repo's name, role, primary language/framework, and key conventions, plus the cross-repo change propagation order
5. Load principles from `rules/steering-principles.md` from this skill's directory
6. Present summary for review

**Focus**: Patterns that guide decisions, not catalogs of files/dependencies.

---

## Sync Flow

1. Load all existing steering (`.sdd/steering/*.md`)
2. Analyze codebase for changes (JIT)
3. Detect drift:
   - **Steering → Code**: Missing elements → Warning
   - **Code → Steering**: New patterns → Update candidate
   - **Custom files**: Check relevance
   - **Multi-repo drift** (when `repos/` exists): Check whether `tech.md` contains a `## Per-Repo Stacks` section. If any repo's CLAUDE.md has changed since the section was written, flag the outdated repo as a drift candidate and propose updating the corresponding entry in `tech.md`.
4. Propose updates (additive, preserve user content)
5. Report: Updates, warnings, recommendations

**Update Philosophy**: Add, don't replace. Preserve user sections.

---

## Granularity Principle

From `rules/steering-principles.md` (in this skill's directory):

> "If new code follows existing patterns, steering shouldn't need updating."

Document patterns and principles, not exhaustive lists.

**Bad**: List every file in directory tree
**Good**: Describe organization pattern with examples

## Tool Guidance

- `Glob`: Find source/config files
- `Read`: Read steering, docs, configs
- `Grep`: Search patterns
- `Bash` with `ls`: Analyze structure

**JIT Strategy**: Fetch when needed, not upfront.

## Output Description

Chat summary only (files updated directly).

### Bootstrap:
```
Steering Created

## Generated:
- product.md: [Brief description]
- tech.md: [Key stack]
- structure.md: [Organization]

Review and approve as Source of Truth.
```

### Sync:
```
Steering Updated

## Changes:
- tech.md: React 18 → 19
- structure.md: Added API pattern

## Code Drift:
- Components not following import conventions

## Recommendations:
- Consider api-standards.md
```

## Examples

### Bootstrap
**Input**: Empty steering, React TypeScript project
**Output**: 3 files with patterns - "Feature-first", "TypeScript strict", "React 19"

### Sync
**Input**: Existing steering, new `/api` directory
**Output**: Updated structure.md, flagged non-compliant files, suggested api-standards.md

## Safety & Fallback

- **Security**: Never include keys, passwords, secrets (see principles)
- **Uncertainty**: Report both states, ask user
- **Preservation**: Add rather than replace when in doubt
- **`repos/` directory absent**: Skip multi-repo parallel research area; proceed with standard single-repo analysis. No `## Per-Repo Stacks` section is added to tech.md. No warning needed — single-repo is the silent default.

## Notes

- All `.sdd/steering/*.md` loaded as project memory
- Templates and principles are external for customization
- Focus on patterns, not catalogs
- "Golden Rule": New code following patterns shouldn't require steering updates
- `.sdd/settings/` content should NOT be documented in steering files (settings are metadata, not project knowledge)
