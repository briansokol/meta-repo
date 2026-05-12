---
name: sdd-pr
description: Open pull requests for each repo in a spec's worktrees. Commits any uncommitted changes (with user confirmation) before pushing.
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
argument-hint: <spec-name>
---

# sdd-pr Skill

## Core Mission

For each repo worktree in `specs/<spec-name>/repos/`, commit any uncommitted changes (after asking the user), push the feature branch, and open a pull request.

## Execution Steps

### Step 1: Validate Inputs

- Extract `<spec-name>` from arguments.
- Read `specs/<spec-name>/spec.json`. If it does not exist, stop with: "No spec found for `<spec-name>`. Check available specs in `specs/`."
- Parse `affected_repos` from spec.json.
- Confirm `specs/<spec-name>/repos/` exists and is non-empty. If not, stop with: "No worktrees found at `specs/<spec-name>/repos/`. Run `/sdd-impl <spec-name>` first to set up worktrees."

### Step 2: Inspect Each Worktree

For each repo listed in `affected_repos`, in order:

**a) Locate worktree**:
- Check that `specs/<spec-name>/repos/<repo-name>/` exists. If absent, log a warning and skip that repo.

**b) Detect current branch**:
- Run `git -C specs/<spec-name>/repos/<repo-name>/ rev-parse --abbrev-ref HEAD`.
- Store as `BRANCH`. This is the feature branch that will be pushed and PR'd.

**c) Check for uncommitted changes**:
- Run `git -C specs/<spec-name>/repos/<repo-name>/ status --porcelain`.
- If output is non-empty, record the repo as having **uncommitted changes** and store the status output.

### Step 3: Confirm Uncommitted Changes With User

If **any** repos have uncommitted changes:

- Present the user with a single confirmation question listing every affected repo and its dirty files.
- Use `AskUserQuestion` with two options: **Commit and continue** and **Cancel**.
- If the user selects **Cancel**, stop immediately with: "Aborted. No changes were committed or pushed."

### Step 4: Commit Uncommitted Changes

For each repo that had uncommitted changes (only reached after user confirmed):

**a) Branch safety guard**:
- Verify `BRANCH` is NOT `main` or `master`. If it is, stop with: "ERROR: `<repo-name>` worktree is on branch `<BRANCH>`. Refusing to commit to the default branch."

**b) Stage and commit**:
- Run `git -C specs/<spec-name>/repos/<repo-name>/ add <explicit files from status output>` — list each file explicitly, never use `-A` or `.`.
- Commit with message: `feat(<spec-name>): uncommitted changes before PR`
  ```
  git -C specs/<spec-name>/repos/<repo-name>/ commit -m "feat(<spec-name>): uncommitted changes before PR"
  ```
- If the commit fails (e.g., pre-commit hook), report the error and stop for that repo. Do not proceed to push.

### Step 5: Push and Open PRs

For each repo (only those with a successful or already-clean state):

**a) Push branch**:
- Run `git -C specs/<spec-name>/repos/<repo-name>/ push -u origin <BRANCH>`.
- If push fails, report the error for that repo and skip to the next repo.

**b) Detect default branch**:
- Run `git -C specs/<spec-name>/repos/<repo-name>/ symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||'`.
- If empty, fall back to `main`.
- Store as `BASE_BRANCH`.

**c) Build PR body**:
- Read `specs/<spec-name>/requirements.md` (first 60 lines) for a summary of what this feature does.
- Compose a short PR description (≤5 bullet points) summarizing the changes for this specific repo.

**d) Open PR**:
- Use `gh pr create` from the worktree directory:
  ```
  gh -C specs/<spec-name>/repos/<repo-name>/ pr create \
    --title "feat(<spec-name>): <repo-name> changes" \
    --base <BASE_BRANCH> \
    --body "..."
  ```
  Pass the body via HEREDOC to preserve formatting.
- If a PR already exists for this branch (gh exits with "already exists" error), run `gh -C specs/<spec-name>/repos/<repo-name>/ pr view --web` and report the existing PR URL instead.
- Capture and store the PR URL.

### Step 6: Report Results

After processing all repos, output a summary table:

| Repo | Branch | Status | PR URL |
|------|--------|--------|--------|
| todo-backend | feat/add-tags | ✅ opened | https://... |
| todo-frontend | feat/add-tags | ✅ already existed | https://... |
| todo-contracts | feat/add-tags | ❌ push failed | — |

List any errors or skipped repos with their reasons.

## Safety & Fallback

**No worktrees found**: Stop with a clear message pointing to `/sdd-impl`.

**User declines commit**: Abort entirely — do not push any repos.

**Push failure**: Log the error for that repo, continue with remaining repos, and report all failures in the final summary.

**Default-branch guard**: Never commit or push when `BRANCH` is `main` or `master`.

**Pre-commit hook failure**: Report the hook output, do not retry, mark the repo as failed in the summary.

**gh not installed**: Stop with: "`gh` CLI is required for opening PRs. Install it from https://cli.github.com/."

**No remote configured**: If the repo has no `origin` remote, skip and report in the summary.
