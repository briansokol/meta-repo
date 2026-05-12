---
theme: default
title: "The Meta Repo: The AI Map of Your Codebase"
titleTemplate: "%s"
author: Slalom
keywords: ai,meta-repo,claude,multi-repo,context,spec-driven-development
colorSchema: dark
fonts:
  sans: "Inter"
  mono: "Fira Code"
transition: slide-left
mdc: true
---

# The Meta Repo

### The AI Map of Your Entire Codebase

<div class="mt-8 text-gray-400">
Brian Sokol · May 2026
</div>

---
layout: two-cols
---

<div class="flex items-start justify-start pt-2">
  <img src="/profile.png" class="rounded-full object-cover" style="width: 270px; height: 270px;" />
</div>

::right::

# About Me

<div class="space-y-3 mt-6 text-lg">
  <div><strong>Brian Sokol</strong></div>
  <div>Director, Client Delivery</div>
  <div><strong>Slalom</strong>, 11 Years</div>
  <div class="mt-4 space-y-2">
    <div>🔗 <a href="https://github.com/briansokol" class="text-blue-400">github.com/briansokol</a></div>
    <div>🔗 <a href="https://linkedin.com/in/bsokol1" class="text-blue-400">linkedin.com/in/bsokol1</a></div>
  </div>
</div>

---
layout: default
---

# The World We Actually Work In

Most real projects look like this:

<div class="grid grid-cols-4 gap-4 mt-8">
  <div class="border border-blue-500 rounded-lg p-4 text-center">
    <div class="text-3xl mb-2">⚛️</div>
    <div class="font-bold">frontend</div>
    <div class="text-sm text-gray-400 mt-1">React / Svelte / Vue</div>
  </div>
  <div class="border border-green-500 rounded-lg p-4 text-center">
    <div class="text-3xl mb-2">🐍</div>
    <div class="font-bold">backend</div>
    <div class="text-sm text-gray-400 mt-1">FastAPI / Node / .NET / Go</div>
  </div>
  <div class="border border-yellow-500 rounded-lg p-4 text-center">
    <div class="text-3xl mb-2">📋</div>
    <div class="font-bold">contracts</div>
    <div class="text-sm text-gray-400 mt-1">OpenAPI / Protobuf</div>
  </div>
  <div class="border border-purple-500 rounded-lg p-4 text-center">
    <div class="text-3xl mb-2">🏗️</div>
    <div class="font-bold">infra</div>
    <div class="text-sm text-gray-400 mt-1">Terraform / Helm / Compose</div>
  </div>
</div>

<div class="mt-10 text-center text-xl text-gray-300">
  Each repo has its own conventions, patterns, and history.
</div>

---

# The Problem: AI Has No Map

<div class="grid grid-cols-2 gap-12 mt-6">
<div>

### What you ask:
<div class="bg-gray-800 rounded p-4 mt-3 text-sm font-mono">
"Add a tags feature to the todo app"
</div>

### What the AI sees:
<div class="bg-gray-800 rounded p-4 mt-3 text-sm">

When you're in <span class="text-blue-400">todo-frontend</span>:
- ✅ React component patterns
- ✅ TanStack Query hooks
- ❌ What does the API contract look like?
- ❌ What does the backend expect?
- ❌ How are migrations handled?

</div>
</div>

<div>

### The result:
<div class="mt-3 space-y-3">
  <div class="bg-red-900/40 border border-red-700 rounded p-3 text-sm">
    🔄 AI invents an API shape that doesn't match the backend
  </div>
  <div class="bg-red-900/40 border border-red-700 rounded p-3 text-sm">
    🔄 You repeat context in every session across every repo
  </div>
  <div class="bg-red-900/40 border border-red-700 rounded p-3 text-sm">
    🔄 The AI can't coordinate changes that span repos
  </div>
  <div class="bg-red-900/40 border border-red-700 rounded p-3 text-sm">
    🔄 Each repo session is its own isolated silo
  </div>
</div>
</div>
</div>

---
layout: center
class: text-center
---

# What if the AI could read the whole map?

<div class="text-6xl mt-8">🗺️</div>

<div class="mt-8 text-xl text-gray-300">
  Instead of one AI session per repo...<br>
  One AI session with <em>all relevant repos in context</em>.
</div>

---

# Introducing the Meta Repo

<div class="grid grid-cols-2 gap-10 mt-6">
<div>

A dedicated repository that acts as the **AI context layer** for your entire project.

<div class="mt-6 space-y-3">

<div class="flex items-start gap-3">
  <span class="text-blue-400 text-xl">📎</span>
  <div><strong>Links</strong> to all app repos — clones them locally for AI to read</div>
</div>

<div class="flex items-start gap-3">
  <span class="text-green-400 text-xl">📖</span>
  <div><strong>Reads</strong> each repo's <code>CLAUDE.md</code> automatically at session start</div>
</div>

<div class="flex items-start gap-3">
  <span class="text-yellow-400 text-xl">📋</span>
  <div><strong>Holds</strong> feature specs, requirements, and implementation tasks</div>
</div>

<div class="flex items-start gap-3">
  <span class="text-purple-400 text-xl">🌿</span>
  <div><strong>Creates</strong> worktree copies per feature for isolated development</div>
</div>

</div>
</div>

<div>

```
todo-meta/
├── CLAUDE.md          ← the context aggregator
├── setup.sh           ← clones all repos
├── repos/             ← gitignored
│   ├── todo-frontend/
│   ├── todo-backend/
│   ├── todo-contracts/
│   └── todo-infra/
└── specs/
    └── add-tags/
        ├── requirements.md
        ├── design.md
        ├── tasks.md
        └── repos/     ← worktrees for this feature
```

</div>
</div>

---

# The Key: `CLAUDE.md` Files

<div class="grid grid-cols-2 gap-8 mt-6">
<div>

### Each app repo documents itself

```markdown
# todo-backend

## Stack
- FastAPI 0.111, SQLAlchemy 2.0
- PostgreSQL 16, Alembic migrations

## Project structure
app/
  models/   — ORM models (source of DB schema)
  schemas/  — Pydantic (match todo-contracts)
  routers/  — thin, delegate to services/
  services/ — business logic

## Known stubs
`app/routers/tags.py` — returns 501.
No Tag model, no migration yet.
See specs/add-tags/ in todo-meta.
```

</div>

<div>

### The meta repo aggregates them

```markdown
# Todo App — Meta Repo

## Repos
Run ./setup.sh to populate repos/.
Read each repo's CLAUDE.md first:

- @repos/todo-frontend/CLAUDE.md
- @repos/todo-backend/CLAUDE.md
- @repos/todo-contracts/CLAUDE.md
- @repos/todo-infra/CLAUDE.md

## Active specs
- specs/add-tags/ — Tags feature
  (not yet implemented)
```

The `@file` references are read **automatically** when you open Claude Code here.

</div>
</div>

---

# What Goes in Each `CLAUDE.md`?

<div class="grid grid-cols-3 gap-6 mt-6 text-sm">

<div class="border border-gray-600 rounded-lg p-4">
<div class="font-bold text-blue-400 mb-3">🛠️ Tech Stack</div>
<ul class="space-y-1 text-gray-300">
  <li>Framework + version</li>
  <li>Key libraries</li>
  <li>Language/runtime</li>
  <li>Database + ORM</li>
</ul>
</div>

<div class="border border-gray-600 rounded-lg p-4">
<div class="font-bold text-green-400 mb-3">🏗️ Architecture</div>
<ul class="space-y-1 text-gray-300">
  <li>Folder structure</li>
  <li>Naming conventions</li>
  <li>Design patterns used</li>
  <li>What talks to what</li>
</ul>
</div>

<div class="border border-gray-600 rounded-lg p-4">
<div class="font-bold text-yellow-400 mb-3">⚙️ Workflow</div>
<ul class="space-y-1 text-gray-300">
  <li>How to run locally</li>
  <li>How to run tests</li>
  <li>How to add migrations</li>
  <li>How to deploy</li>
</ul>
</div>

<div class="border border-gray-600 rounded-lg p-4">
<div class="font-bold text-purple-400 mb-3">🔗 Dependencies</div>
<ul class="space-y-1 text-gray-300">
  <li>What this repo consumes</li>
  <li>What consumes this repo</li>
  <li>Shared contracts location</li>
  <li>Generated code sources</li>
</ul>
</div>

<div class="border border-gray-600 rounded-lg p-4">
<div class="font-bold text-red-400 mb-3">🚧 Known Stubs</div>
<ul class="space-y-1 text-gray-300">
  <li>Incomplete features</li>
  <li>Intentional placeholders</li>
  <li>Where to find the spec</li>
  <li>What's blocking them</li>
</ul>
</div>

<div class="border border-gray-600 rounded-lg p-4">
<div class="font-bold text-cyan-400 mb-3">📏 Rules</div>
<ul class="space-y-1 text-gray-300">
  <li>What NOT to change</li>
  <li>Generated files (don't edit)</li>
  <li>Coding standards</li>
  <li>Repo-specific gotchas</li>
</ul>
</div>

</div>

---

# Spec-Driven Development

<div class="mt-4 text-gray-300">The Meta Repo enables a structured workflow for multi-repo features.</div>

<div class="grid grid-cols-7 gap-1 mt-6 text-sm text-center">

<div class="bg-blue-900/50 border border-blue-700 rounded-lg p-2">
  <div class="text-2xl mb-1">📝</div>
  <div class="font-bold">1. Spec</div>
  <div class="text-gray-400 text-xs">Write requirements + design in specs/&lt;feature&gt;/</div>
</div>

<div class="flex items-center justify-center text-gray-500 text-xl">→</div>

<div class="bg-green-900/50 border border-green-700 rounded-lg p-2">
  <div class="text-2xl mb-1">🌿</div>
  <div class="font-bold">2. Worktrees</div>
  <div class="text-gray-400 text-xs">Create feature branches in specs/&lt;feature&gt;/repos/</div>
</div>

<div class="flex items-center justify-center text-gray-500 text-xl">→</div>

<div class="bg-purple-900/50 border border-purple-700 rounded-lg p-2">
  <div class="text-2xl mb-1">🤖</div>
  <div class="font-bold">3. Implement</div>
  <div class="text-gray-400 text-xs">AI works across all repos with full context</div>
</div>

<div class="flex items-center justify-center text-gray-500 text-xl">→</div>

<div class="bg-orange-900/50 border border-orange-700 rounded-lg p-2">
  <div class="text-2xl mb-1">🗂️</div>
  <div class="font-bold">4. Archive</div>
  <div class="text-gray-400 text-xs">Archive the spec and remove worktrees after merge</div>
</div>

</div>

<div class="mt-8 grid grid-cols-2 gap-6">
<div>

**A spec folder contains:**

```
specs/add-tags/
├── requirements.md   ← what & why
├── design.md         ← how it works
├── tasks.md          ← step-by-step checklist
└── repos/            ← worktree copies (gitignored)
    ├── todo-frontend/  (feature branch)
    ├── todo-backend/   (feature branch)
    └── todo-contracts/ (feature branch)
```

</div>

<div class="text-sm text-gray-300 space-y-3 mt-2">

<div class="flex gap-2">
  <span class="text-green-400">✓</span>
  <span>Requirements written once, referenced by AI across all repos</span>
</div>
<div class="flex gap-2">
  <span class="text-green-400">✓</span>
  <span>Worktrees let you work on multiple repos' branches simultaneously</span>
</div>
<div class="flex gap-2">
  <span class="text-green-400">✓</span>
  <span>Tasks.md tracks progress across the entire feature</span>
</div>
<div class="flex gap-2">
  <span class="text-green-400">✓</span>
  <span>Changes stay isolated until you're ready to merge</span>
</div>
<div class="flex gap-2">
  <span class="text-green-400">✓</span>
  <span>Archive command cleans up worktrees and summarizes the completed feature</span>
</div>

</div>
</div>

---
layout: center
class: text-center
---

<div class="text-center">

# Live Demo

<div class="text-5xl mt-6">💻</div>

<div class="mt-6 text-xl text-gray-300">
  Switching to the IDE…
</div>

</div>

---

# Benefits Summary

<div class="grid grid-cols-2 gap-6 mt-6">

<div class="space-y-4">

<div class="flex gap-4 items-start">
  <span class="text-3xl">🧠</span>
  <div>
    <div class="font-bold">Full cross-repo context, zero repetition</div>
    <div class="text-sm text-gray-400 mt-1">Set up once. Every AI session starts with the complete picture — no copy-pasting context.</div>
  </div>
</div>

<div class="flex gap-4 items-start">
  <span class="text-3xl">📐</span>
  <div>
    <div class="font-bold">Coordinated multi-repo changes</div>
    <div class="text-sm text-gray-400 mt-1">The AI can reason about changes that span repos and execute them in the right order.</div>
  </div>
</div>

<div class="flex gap-4 items-start">
  <span class="text-3xl">📋</span>
  <div>
    <div class="font-bold">Spec-driven, not vibe-driven</div>
    <div class="text-sm text-gray-400 mt-1">Requirements and design decisions are written down. The AI follows the plan instead of inventing one.</div>
  </div>
</div>

</div>

<div class="space-y-4">

<div class="flex gap-4 items-start">
  <span class="text-3xl">🔁</span>
  <div>
    <div class="font-bold">Living documentation</div>
    <div class="text-sm text-gray-400 mt-1">CLAUDE.md files stay accurate because the AI reads and updates them. They're not stale wikis.</div>
  </div>
</div>

<div class="flex gap-4 items-start">
  <span class="text-3xl">🚀</span>
  <div>
    <div class="font-bold">Faster onboarding</div>
    <div class="text-sm text-gray-400 mt-1">New engineers get context by reading the same CLAUDE.md files the AI reads. One source of truth.</div>
  </div>
</div>

<div class="flex gap-4 items-start">
  <span class="text-3xl">🔌</span>
  <div>
    <div class="font-bold">Works with any AI tool</div>
    <div class="text-sm text-gray-400 mt-1">CLAUDE.md is just Markdown. Works with Claude Code, Cursor, Copilot, or any tool that reads context files.</div>
  </div>
</div>

</div>
</div>

---

# Getting Started

<div class="grid grid-cols-3 gap-6 mt-8">

<div class="text-center">
<div class="bg-blue-900/40 border border-blue-700 rounded-full w-12 h-12 flex items-center justify-center text-xl font-bold mx-auto mb-4">1</div>
<div class="font-bold">Write CLAUDE.md</div>
<div class="text-sm text-gray-400 mt-2">Add a CLAUDE.md to each of your existing repos. Answer: stack, structure, how to run, conventions, known issues.</div>
</div>

<div class="text-center">
<div class="bg-green-900/40 border border-green-700 rounded-full w-12 h-12 flex items-center justify-center text-xl font-bold mx-auto mb-4">2</div>
<div class="font-bold">Create the Meta Repo</div>
<div class="text-sm text-gray-400 mt-2">New repo with a CLAUDE.md that @-references each app repo's CLAUDE.md, plus a setup.sh that clones them.</div>
</div>

<div class="text-center">
<div class="bg-purple-900/40 border border-purple-700 rounded-full w-12 h-12 flex items-center justify-center text-xl font-bold mx-auto mb-4">3</div>
<div class="font-bold">Write specs before coding</div>
<div class="text-sm text-gray-400 mt-2">For cross-repo features: requirements.md + design.md + tasks.md in specs/&lt;feature&gt;/. Let the AI follow the plan.</div>
</div>

</div>

<div class="mt-10 bg-gray-800 rounded-lg p-5 text-sm">

**The Meta Repo for this demo is open source. Clone it and use it as a template:**

```bash
git clone https://github.com/briansokol/meta-repo
./setup.sh
# Open in Claude Code — AI reads all 4 repos immediately
```

</div>

---
layout: center
class: text-center
---

# The AI doesn't need to be smarter.

<div class="mt-4 text-2xl text-gray-300">It needs a better map.</div>

<div class="mt-12 text-gray-400 text-sm">

Questions? The demo repos are at:

`github.com/briansokol/meta-repo` · `todo-frontend` · `todo-backend` · `todo-contracts` · `todo-infra`

</div>
