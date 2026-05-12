---
name: sdd-cleanup
description: Archive a completed spec and tear down its worktrees. Checks for uncommitted work, optionally opens PRs, writes an archive summary, then removes all worktrees.
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion, Skill
argument-hint: <spec-name>
---

# sdd-cleanup Skill

## Core Mission

Close out a spec after implementation: verify worktrees are clean, capture a summary of the work done, write it to `archives/<spec-name>/summary.md`, and remove all worktrees.

**Order of operations** (do not skip or reorder):
1. Validate spec exists
2. Inspect worktrees for uncommitted changes
3. If dirty: ask user how to proceed
4. If PRs requested: invoke `/sdd-pr`
5. Generate and write archive summary
6. Remove worktrees

---

## Execution Steps

### Step 1: Validate Inputs

- Extract `<spec-name>` from arguments.
- Read `specs/<spec-name>/spec.json`. If missing, stop with:
  > "No spec found for `<spec-name>`. Check available specs in `specs/`."
- Parse: `feature_name`, `affected_repos`, `phase`, `approvals`, `created_at`, `updated_at`.
- Confirm `specs/<spec-name>/repos/` exists. If not, skip worktree steps (no worktrees were ever set up) and proceed directly to Step 4.

### Step 2: Inspect Worktrees for Uncommitted Changes

For each repo in `affected_repos`, in order:

**a) Locate worktree**:
- Check `specs/<spec-name>/repos/<repo-name>/` exists. If absent, log a warning and skip.

**b) Detect branch**:
- Run `git -C specs/<spec-name>/repos/<repo-name>/ rev-parse --abbrev-ref HEAD`.
- Store as `BRANCH`.

**c) Check for uncommitted changes**:
- Run `git -C specs/<spec-name>/repos/<repo-name>/ status --porcelain`.
- If output is non-empty, record the repo as **dirty** and store the status output.

### Step 3: Handle Dirty Worktrees

If **any** worktrees have uncommitted changes:

- Present a single `AskUserQuestion` listing every dirty repo and its uncommitted files.
- Options:
  - **Open PRs then continue** — invoke `/sdd-pr` (which will commit with user confirmation and push), then continue with cleanup after PRs are opened.
  - **Discard changes and continue** — abandon uncommitted changes and proceed with cleanup.
  - **Cancel** — stop immediately; leave everything as-is.

**If user selects "Open PRs then continue"**:
- Invoke the `sdd-pr` skill by calling `Skill` with `skill: "sdd-pr"` and `args: "<spec-name>"`.
- Wait for sdd-pr to complete. If sdd-pr reports any errors, surface them and ask the user whether to proceed with cleanup or abort.

**If user selects "Discard changes and continue"**:
- For each dirty worktree, run:
  ```
  git -C specs/<spec-name>/repos/<repo-name>/ checkout -- .
  git -C specs/<spec-name>/repos/<repo-name>/ clean -fd
  ```
- Confirm each worktree is now clean before proceeding.

**If user selects "Cancel"**:
- Stop immediately with: "Cleanup cancelled. No changes were made."

If all worktrees are clean, proceed directly to Step 4.

### Step 4: Generate Archive Summary

Read the following files (use only what exists; skip missing files gracefully):

| File | Purpose |
|------|---------|
| `specs/<spec-name>/spec.json` | Metadata (dates, phase, approvals, affected repos) |
| `specs/<spec-name>/requirements.md` | What the feature does and why |
| `specs/<spec-name>/design.md` | Architecture and key decisions |
| `specs/<spec-name>/tasks.md` | Task completion stats and implementation notes |
| `specs/<spec-name>/research.md` | Research findings (if present) |

**Compute task stats from tasks.md**:
- Count `- [x]` lines → `TASKS_DONE`
- Count `- [ ]` lines → `TASKS_REMAINING`
- Count `_Blocked:_` annotations → `TASKS_BLOCKED`
- Extract any `## Implementation Notes` section verbatim.

**Collect PR URLs (best effort)**:
- For each repo in `affected_repos`, run:
  ```
  gh -C specs/<spec-name>/repos/<repo-name>/ pr list --head <BRANCH> --json url --jq '.[0].url' 2>/dev/null
  ```
  where `<BRANCH>` is the branch detected in Step 2. If `gh` is not installed or returns empty, skip silently.

**Compose summary** using the template below.

#### Archive Summary Template

```markdown
# Archive: <feature_name>

**Archived**: <today's date>
**Created**: <created_at from spec.json>
**Last Updated**: <updated_at from spec.json>
**Phase at Archival**: <phase>
**Affected Repos**: <comma-separated list>

---

## What Was Built

<2–4 sentence synthesis drawn from requirements.md — describe the feature, its purpose, and the user value it delivers.>

---

## Key Design Decisions

<3–5 bullet points drawn from design.md summarizing the most important architectural and data-model choices.>

---

## Implementation Summary

| Metric | Value |
|--------|-------|
| Tasks completed | <TASKS_DONE> |
| Tasks remaining | <TASKS_REMAINING> |
| Tasks blocked | <TASKS_BLOCKED> |
| Approvals | Requirements: <✅/❌> · Design: <✅/❌> · Tasks: <✅/❌> |

<If TASKS_REMAINING > 0 or TASKS_BLOCKED > 0, add a note: "This spec was archived before all tasks were complete.">

---

## Pull Requests

<If PRs were collected:>
| Repo | PR URL |
|------|--------|
| <repo-name> | <url> |

<If no PRs found:>
No pull requests were detected at archival time.

---

## Implementation Notes

<Copy the ## Implementation Notes section from tasks.md verbatim, or write "None recorded." if absent.>

---

## Spec Files

All original spec files are preserved in `specs/<spec-name>/`.
```

### Step 5: Write Archive

- Create directory `archives/<spec-name>/` if it does not exist.
- Write the composed summary to `archives/<spec-name>/summary.md`.
- Confirm the file was written before proceeding to teardown.

### Step 6: Tear Down Worktrees

For each repo in `affected_repos` (only those with a confirmed worktree in `specs/<spec-name>/repos/<repo-name>/`):

**a) Safety guard**: Run `git -C specs/<spec-name>/repos/<repo-name>/ status --porcelain`.
- If output is non-empty, STOP for that repo with:
  > "ERROR: `<repo-name>` worktree still has uncommitted changes. Skipping removal to avoid data loss."

**b) Remove worktree**:
```
git -C repos/<repo-name>/ worktree remove specs/<spec-name>/repos/<repo-name>/
```
- If the command fails (e.g., "not a worktree"), try the `--force` flag only if the directory still exists and the user has already confirmed discarding changes above. Otherwise report the error and skip.

**c) Verify removal**: Confirm `specs/<spec-name>/repos/<repo-name>/` no longer exists (or is empty).

After all worktrees are removed, run `git -C repos/<repo-name>/ worktree prune` for each affected repo to clean up stale refs.

### Step 7: Report Results

Output a final cleanup report:

```
## Cleanup Complete: <spec-name>

### Archive
- Written to: archives/<spec-name>/summary.md

### Worktrees Removed
| Repo | Branch | Status |
|------|--------|--------|
| todo-backend | feat/add-tags | ✅ removed |
| todo-frontend | feat/add-tags | ✅ removed |
| todo-contracts | feat/add-tags | ❌ skipped (error: ...) |

### Pull Requests
<list or "None opened during cleanup">

Spec files remain at `specs/<spec-name>/` for reference.
Run `git status` to confirm no lingering worktree refs.
```

---

## Safety & Fallback

**No spec found**: Stop with a clear message. List available specs in `specs/`.

**No worktrees**: If `specs/<spec-name>/repos/` is absent or empty, skip Steps 2–3 and 6. Still generate and write the archive summary.

**Dirty worktree after discard**: If `git checkout -- . && git clean -fd` leaves files behind, report the repo as uncleanable, skip its worktree removal, and continue with others.

**Worktree remove failure**: Report the error per-repo. Never use `rm -rf` to remove a worktree directory. After reporting, continue with the remaining repos.

**`gh` not installed**: Skip PR URL collection silently. Note "gh CLI not available" in the PRs section of the summary.

**Archive directory already exists**: Overwrite `summary.md` without prompting — re-archiving is idempotent.

**Branch is `main`/`master` in worktree**: This is an unexpected state. Report it as an error for that repo, skip its removal, and continue.

**User cancels mid-flow** (e.g., cancels the dirty-worktree prompt): Stop immediately. Leave worktrees and spec directory untouched.
