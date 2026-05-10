---
theme: default
title: "The Meta Repo: Giving AI a Map of Your Codebase"
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

### Giving AI a Map of Your Entire Codebase

<div class="mt-8 text-gray-400">
Brian Sokol · Slalom
</div>

<!--
Welcome. Today I'm going to talk about a pattern we've been using to dramatically improve how AI tools work across multi-repo projects.

The core problem: AI coding assistants are incredibly powerful inside a single repo. But most real projects aren't a single repo. The moment you have a frontend, a backend, a contracts layer, and an infrastructure repo — the AI loses the plot.

The Meta Repo is our solution to that problem.
-->

---
layout: default
---

# The World We Actually Work In

Most real projects look like this:

<div class="grid grid-cols-4 gap-4 mt-8">
  <div class="border border-blue-500 rounded-lg p-4 text-center">
    <div class="text-3xl mb-2">⚛️</div>
    <div class="font-bold">frontend</div>
    <div class="text-sm text-gray-400 mt-1">React / Vue / Angular</div>
  </div>
  <div class="border border-green-500 rounded-lg p-4 text-center">
    <div class="text-3xl mb-2">🐍</div>
    <div class="font-bold">backend</div>
    <div class="text-sm text-gray-400 mt-1">FastAPI / Node / Go</div>
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

<!--
This is the reality for virtually every project beyond toy size. Four, five, six separate repos — each with its own tech stack, its own conventions, its own undocumented tribal knowledge.

When a new team member joins, it takes weeks to build up the mental model of how these pieces connect. The same problem exists for AI.
-->

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

<!--
Here's the core problem. When you open Claude Code — or any AI assistant — in one of your repos, it only sees that repo.

It can't see that the API contract lives in a separate contracts repo. It can't see that the backend team uses a specific migration pattern. It can't see that there's already a half-finished implementation in another branch.

So you either spend the first 10 minutes of every session pasting context... or the AI makes confident wrong assumptions.
-->

---
layout: center
class: text-center
---

# What if the AI could read the whole map?

<div class="text-6xl mt-8">🗺️</div>

<div class="mt-8 text-xl text-gray-300">
  Instead of one AI session per repo —<br>
  one AI session with <em>all repos in context</em>.
</div>

<!--
This is the question that led to the Meta Repo pattern.

What if there was one place you could open that would give the AI the full picture? Not just one repo — all of them. With their conventions, their patterns, their current status.
-->

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

<!--
The Meta Repo is simple in concept but powerful in practice.

It's a Git repository that sits above all your app repos. It doesn't contain application code itself — it contains context, specs, and tasks.

The key mechanism is the setup.sh script, which clones all your app repos into a local `repos/` folder. The AI can then read across all of them in a single session.
-->

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

<!--
This is the mechanism that makes it work.

Every app repo has a CLAUDE.md file that answers the question: "what do I need to know to work in this repo?" Stack, patterns, conventions, known stubs — all documented in one place.

The meta repo's CLAUDE.md then uses @ file references to pull all of those in at session start. When you open Claude Code in the meta repo, it reads all four CLAUDE.md files before you type a single word.
-->

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

<!--
The CLAUDE.md isn't meant to be a comprehensive wiki. It's a targeted briefing for an AI agent.

Think about what a senior engineer would tell a new hire on their first day: here's the stack, here's how it's organized, here's how you run things, here's what's broken and why.

That's what goes in CLAUDE.md. Concise, opinionated, actionable.
-->

---

# Spec-Driven Development

<div class="mt-4 text-gray-300">The Meta Repo enables a structured workflow for multi-repo features.</div>

<div class="grid grid-cols-5 gap-2 mt-6 text-sm text-center">

<div class="bg-blue-900/50 border border-blue-700 rounded-lg p-3">
  <div class="text-2xl mb-2">📝</div>
  <div class="font-bold">1. Spec</div>
  <div class="text-gray-400 mt-1">Write requirements + design in specs/&lt;feature&gt;/</div>
</div>

<div class="flex items-center justify-center text-gray-500 text-xl">→</div>

<div class="bg-green-900/50 border border-green-700 rounded-lg p-3">
  <div class="text-2xl mb-2">🌿</div>
  <div class="font-bold">2. Worktrees</div>
  <div class="text-gray-400 mt-1">Create feature branches in specs/&lt;feature&gt;/repos/</div>
</div>

<div class="flex items-center justify-center text-gray-500 text-xl">→</div>

<div class="bg-purple-900/50 border border-purple-700 rounded-lg p-3">
  <div class="text-2xl mb-2">🤖</div>
  <div class="font-bold">3. Implement</div>
  <div class="text-gray-400 mt-1">AI works across all repos with full context</div>
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

</div>
</div>

<!--
The spec-driven workflow is where the Meta Repo really shines.

When you're starting a new feature, you write the requirements and design into the specs folder first. Then you create git worktree copies of each affected repo — so you're working on feature branches, not main.

The AI then works across all of those worktrees simultaneously, with the spec as its guide. It's not guessing — it's following a plan that you wrote, with access to all the context it needs.
-->

---
layout: center
class: text-center
---

# Let's See It In Action

<div class="text-5xl mt-6">🎬</div>

<div class="mt-6 text-xl text-gray-300">
  A simple todo app — four repos —<br>
  one incomplete feature.
</div>

<!--
Let's switch to the demo. I've built a realistic multi-repo todo app to make this concrete.

It has all four repos we talked about: a React frontend, a FastAPI backend, an OpenAPI contracts repo, and a Docker Compose infra repo.

One feature — Tags — is intentionally left incomplete. I'm going to show you the difference between working without the Meta Repo and working with it.
-->

---

# The Demo App: Four Repos

<div class="grid grid-cols-2 gap-6 mt-6">

<div class="border border-blue-500/50 rounded-lg p-5">
<div class="flex items-center gap-3 mb-3">
  <span class="text-2xl">⚛️</span>
  <span class="font-bold text-blue-400">todo-frontend</span>
</div>
<div class="text-sm text-gray-300 space-y-1">
  <div>React 18 + Vite + TypeScript</div>
  <div>TanStack Query for server state</div>
  <div>API client generated from contracts</div>
  <div class="text-orange-400 mt-2">⚠️ TagBadge + TagFilter: stub components</div>
</div>
</div>

<div class="border border-green-500/50 rounded-lg p-5">
<div class="flex items-center gap-3 mb-3">
  <span class="text-2xl">🐍</span>
  <span class="font-bold text-green-400">todo-backend</span>
</div>
<div class="text-sm text-gray-300 space-y-1">
  <div>FastAPI + SQLAlchemy + Alembic</div>
  <div>PostgreSQL — Pydantic v2 schemas</div>
  <div>Schemas derived from contracts spec</div>
  <div class="text-orange-400 mt-2">⚠️ /tags endpoints: all return 501</div>
</div>
</div>

<div class="border border-yellow-500/50 rounded-lg p-5">
<div class="flex items-center gap-3 mb-3">
  <span class="text-2xl">📋</span>
  <span class="font-bold text-yellow-400">todo-contracts</span>
</div>
<div class="text-sm text-gray-300 space-y-1">
  <div>OpenAPI 3.1 — single source of truth</div>
  <div>Frontend + backend both derive types here</div>
  <div>Tag + TagCreate schemas: defined</div>
  <div class="text-orange-400 mt-2">⚠️ Tag endpoints: TODO comment only</div>
</div>
</div>

<div class="border border-purple-500/50 rounded-lg p-5">
<div class="flex items-center gap-3 mb-3">
  <span class="text-2xl">🏗️</span>
  <span class="font-bold text-purple-400">todo-infra</span>
</div>
<div class="text-sm text-gray-300 space-y-1">
  <div>Docker Compose — three services</div>
  <div>frontend :3000 · backend :8000 · postgres :5432</div>
  <div>Healthchecks + volume persistence</div>
  <div class="text-green-400 mt-2">✅ No changes needed for tags</div>
</div>
</div>

</div>

<!--
Here are the four repos. Each one has its own CLAUDE.md documenting its stack, patterns, and conventions.

Notice the orange warnings — the Tags feature is deliberately half-done across three of the four repos. The schema is defined in contracts. The stub components exist in the frontend. The 501 routes exist in the backend.

It looks intentional, because it is.
-->

---

# The Tags Feature: Intentionally Incomplete

<div class="grid grid-cols-3 gap-6 mt-6">

<div class="border border-orange-500/60 rounded-lg p-4">
<div class="font-bold text-yellow-400 mb-3">📋 todo-contracts</div>

```yaml
# openapi.yaml

# ✅ Schema defined:
Tag:
  type: object
  required: [id, name, color]
  properties:
    id: { type: integer }
    name: { type: string }
    color: { type: string }

# ⚠️ Endpoints: TODO only
# TODO: implement tags endpoints
# POST /tags — create a tag
# GET /tags — list all tags
```

</div>

<div class="border border-orange-500/60 rounded-lg p-4">
<div class="font-bold text-green-400 mb-3">🐍 todo-backend</div>

```python
# app/routers/tags.py

router = APIRouter(tags=["tags"])

NOT_IMPLEMENTED = JSONResponse(
  status_code=501,
  content={"detail":
    "Tags not yet implemented."
    " See specs/add-tags/"
    " in todo-meta."},
)

@router.get("/tags")
def list_tags():
    return NOT_IMPLEMENTED

@router.post("/tags")
def create_tag():
    return NOT_IMPLEMENTED
```

</div>

<div class="border border-orange-500/60 rounded-lg p-4">
<div class="font-bold text-blue-400 mb-3">⚛️ todo-frontend</div>

```tsx
// src/components/tags/TagBadge.tsx

// TODO: Implement as part of
// the add-tags feature.
// See specs/add-tags/ in todo-meta.
// Should render a colored pill badge.
export function TagBadge(_props: Props) {
  return null  // ← stub
}

// src/components/tags/TagFilter.tsx

export function TagFilter() {
  return (
    <div style={{border:'1px dashed #d1d5db'}}>
      Tags filter — not yet implemented
    </div>
  )
}
```

</div>
</div>

<!--
This is the "stub pattern." Rather than leaving the feature half-built in a confusing state, we made it consistently incomplete.

The contracts repo has the schema but no endpoints.
The backend has the endpoints but they all return 501.
The frontend has the components but they render nothing.

Each stub has a comment pointing to the spec. An AI reading any of these files knows exactly what's going on and where to find the implementation guide.
-->

---

# Demo Step 1: Without the Meta Repo

<div class="grid grid-cols-2 gap-8 mt-6">
<div>

Open **todo-backend** in Claude Code and ask:

<div class="bg-gray-800 rounded p-4 mt-3 font-mono text-sm">
"How do I implement the tags feature?"
</div>

<div class="mt-6 text-sm space-y-3">

The AI sees:
<div class="bg-gray-800 rounded p-3 space-y-1">
  <div class="text-green-400">✅ FastAPI routing patterns</div>
  <div class="text-green-400">✅ SQLAlchemy models for lists/todos</div>
  <div class="text-green-400">✅ The 501 stub in tags.py</div>
  <div class="text-red-400">❌ The OpenAPI spec in todo-contracts</div>
  <div class="text-red-400">❌ The TagBadge/TagFilter stubs in the frontend</div>
  <div class="text-red-400">❌ The spec in specs/add-tags/</div>
</div>

</div>
</div>

<div class="mt-2">

The AI will likely:

<div class="space-y-3 mt-3 text-sm">
<div class="bg-yellow-900/40 border border-yellow-700 rounded p-3">
  <strong>Invent</strong> a Tag schema that may not match what the contracts repo expects
</div>
<div class="bg-yellow-900/40 border border-yellow-700 rounded p-3">
  <strong>Miss</strong> that the frontend needs TagBadge and TagFilter wired up
</div>
<div class="bg-yellow-900/40 border border-yellow-700 rounded p-3">
  <strong>Skip</strong> the contracts-first update order (contracts → backend → frontend)
</div>
<div class="bg-yellow-900/40 border border-yellow-700 rounded p-3">
  <strong>Create</strong> a working backend that breaks the frontend
</div>
</div>

</div>
</div>

<!--
Let me show the problem concretely.

If you open just the backend repo and ask the AI to implement tags, it'll do its best — but it's working blind. It doesn't know the Tag schema was already defined in the contracts repo. It doesn't know the frontend has stub components waiting to be wired up. It doesn't know there's already a spec written.

So it might do something that works in isolation but breaks the larger system.
-->

---

# Demo Step 2: Opening the Meta Repo

<div class="grid grid-cols-2 gap-8 mt-6">
<div>

```bash
# Clone the meta repo
git clone <todo-meta-url>
cd todo-meta

# Populate all app repos
./setup.sh
```

```
Setting up Todo App repos in ./repos...
  Cloning todo-frontend...
  Cloning todo-backend...
  Cloning todo-contracts...
  Cloning todo-infra...

Done. Repos available at:
todo-contracts  todo-frontend
todo-backend    todo-infra
```

Now open **todo-meta** in Claude Code.

</div>

<div>

At session start, Claude reads:

<div class="space-y-2 mt-3 text-sm">
<div class="flex items-center gap-2 bg-blue-900/30 border border-blue-700/50 rounded p-2">
  <span>📖</span>
  <code>repos/todo-frontend/CLAUDE.md</code>
</div>
<div class="flex items-center gap-2 bg-green-900/30 border border-green-700/50 rounded p-2">
  <span>📖</span>
  <code>repos/todo-backend/CLAUDE.md</code>
</div>
<div class="flex items-center gap-2 bg-yellow-900/30 border border-yellow-700/50 rounded p-2">
  <span>📖</span>
  <code>repos/todo-contracts/CLAUDE.md</code>
</div>
<div class="flex items-center gap-2 bg-purple-900/30 border border-purple-700/50 rounded p-2">
  <span>📖</span>
  <code>repos/todo-infra/CLAUDE.md</code>
</div>
</div>

<div class="mt-4 text-sm text-gray-300">

The AI now knows:
- React + Vite + TanStack Query setup
- FastAPI + Alembic migration conventions
- OpenAPI is the source of truth — update first
- Docker Compose port mappings
- **Exactly what's stubbed and where the spec is**

</div>
</div>
</div>

<!--
Now let's do it the right way.

You clone the meta repo, run setup.sh, and open it in Claude Code. The moment the session starts, Claude reads all four CLAUDE.md files — automatically, because of the @ references in the meta repo's CLAUDE.md.

Before you've typed a single prompt, the AI has a complete mental model of the entire system.
-->

---

# Demo Step 3: The Spec Folder

<div class="grid grid-cols-2 gap-8 mt-6">
<div>

```
specs/add-tags/
├── requirements.md
├── design.md
└── tasks.md
```

**requirements.md** captures the *what* and *why*:
- User stories (create tags, attach to todos, filter)
- Out of scope (tag editing, deletion)
- Acceptance criteria (7 testable conditions)

**design.md** captures the *how*:
- New `tags` table + `todo_tags` join table
- Alembic migration plan
- What changes in each repo
- Change propagation order: contracts → backend → frontend

**tasks.md** is the implementation checklist:
- 5 tasks with checkboxes
- Exact code snippets for key changes
- Verification steps

</div>

<div>

<div class="bg-gray-800 rounded p-4 text-sm font-mono">

```markdown
# Tags Feature — Implementation Tasks

## Task 1: Update todo-contracts
- [ ] Replace # TODO comment with
      actual endpoint definitions
- [ ] Commit

## Task 2: Backend — Tag model
- [ ] Create app/models/tag.py
- [ ] Add tags relationship to Todo
- [ ] Generate migration
- [ ] Commit

## Task 3: Backend — service + router
- [ ] Create app/services/tags.py
- [ ] Replace 501 stubs with real impl
- [ ] Tests passing
- [ ] Commit

## Task 4: Frontend
- [ ] Implement TagBadge (colored pill)
- [ ] Implement TagFilter (functional)
- [ ] Wire useTags hooks
- [ ] Commit
```

</div>
</div>
</div>

<!--
The spec folder is what separates spec-driven development from "just vibing with the AI."

The requirements capture the user stories and acceptance criteria. The design captures the technical decisions. The tasks are a concrete checklist that the AI can follow.

When you give the AI this spec along with full context from all four repos, it can execute reliably — because it's not making decisions, it's following a plan you already made.
-->

---
layout: center
---

# Demo Step 4: The Payoff

<div class="mt-6 bg-gray-800 rounded-lg p-6 text-sm font-mono max-w-2xl mx-auto">

```
You: Complete the tags feature following specs/add-tags/tasks.md
```

</div>

<div class="mt-6 grid grid-cols-3 gap-4 text-sm text-center">

<div class="bg-yellow-900/30 border border-yellow-700/50 rounded-lg p-4">
  <div class="text-2xl mb-2">📋</div>
  <div class="font-bold">Contracts first</div>
  <div class="text-gray-400 mt-1">Adds tag endpoints to openapi.yaml</div>
</div>

<div class="flex items-center justify-center text-2xl text-gray-500">→</div>

<div class="bg-green-900/30 border border-green-700/50 rounded-lg p-4">
  <div class="text-2xl mb-2">🐍</div>
  <div class="font-bold">Backend</div>
  <div class="text-gray-400 mt-1">Tag model, migration, service, real router</div>
</div>

<div class="flex items-center justify-center text-2xl text-gray-500">→</div>

<div class="bg-blue-900/30 border border-blue-700/50 rounded-lg p-4">
  <div class="text-2xl mb-2">⚛️</div>
  <div class="font-bold">Frontend</div>
  <div class="text-gray-400 mt-1">TagBadge, TagFilter, useTags hooks wired</div>
</div>

</div>

<div class="mt-8 bg-green-900/40 border border-green-500 rounded-lg p-4 text-center max-w-xl mx-auto">
  <strong>Tags work end-to-end</strong> — and the AI knew exactly what to do<br>
  because it had the full map.
</div>

<!--
This is the payoff.

You type one prompt. The AI follows the spec, updates the contracts first, then the backend, then the frontend — in the right order, with the right patterns, because it read all four CLAUDE.md files.

It creates the Tag model using the SQLAlchemy 2.x DeclarativeBase pattern it learned from the backend's CLAUDE.md. It updates the OpenAPI spec first because the contracts CLAUDE.md said "update this file first." It wires TagBadge correctly because it read the frontend's state management conventions.

Reload the app. Tags work.
-->

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

<!--
Let me summarize the benefits.

The biggest one is context persistence. You stop spending the first 10 minutes of every AI session re-explaining your codebase.

But the deeper benefit is coordination. Multi-repo features are hard precisely because you need to hold all four repos in your head simultaneously. The Meta Repo does that for you — and for the AI.
-->

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
git clone https://github.com/YOUR_ORG/todo-meta
./setup.sh
# Open in Claude Code — AI reads all 4 repos immediately
```

</div>

<!--
Here's how to get started.

Step one is the most important: write CLAUDE.md files for your existing repos today. Even a rough one — five minutes, cover the stack and how to run it — is infinitely better than nothing.

Step two is creating the meta repo itself. The structure is simple. You can copy ours.

Step three is the habit change: write the spec before you code. This feels slow the first time. By the third time, you realize you've stopped having to re-do work because the AI went in a direction you didn't want.
-->

---
layout: center
class: text-center
---

# The AI doesn't need to be smarter.

<div class="mt-4 text-2xl text-gray-300">It needs a better map.</div>

<div class="mt-12 text-gray-400 text-sm">

Questions? The demo repos are at:

`github.com/YOUR_ORG/todo-meta` · `todo-frontend` · `todo-backend` · `todo-contracts` · `todo-infra`

</div>

<!--
I'll leave you with this.

The AI tools we have today are remarkably capable. The limiting factor isn't model intelligence — it's context. The AI can only reason about what it can see.

The Meta Repo is simply a way to give it more to see. And when it can see the whole map, the work it produces looks completely different.

Happy to take questions.
-->
