# Project Structure

## Organization Philosophy

The meta-repo is organized by **purpose**, not by code layer. It holds no runtime code. Its artifacts are specs, context files, and coordination scripts.

## Directory Patterns

### Specs (`specs/<feature>/`)
**Location**: `specs/`  
**Purpose**: One folder per feature. Contains the full SDD lifecycle: requirements → design → tasks.  
**Example**: `specs/add-tags/requirements.md`, `design.md`, `tasks.md`  
**Convention**: Work through tasks in order; each task maps to changes across one or more app repos.

### Live Repo Clones (`repos/<repo-name>/`)
**Location**: `repos/` (gitignored)  
**Purpose**: Live clones of the four app repos, populated by `setup.sh`. The AI reads their `CLAUDE.md` files for repo-specific conventions.  
**Convention**: Changes made here are committed inside each repo independently — never via the meta-repo.

### Per-Repo Structure (Backend)
```
app/
  models/     — SQLAlchemy ORM (drives DB schema)
  schemas/    — Pydantic (matches todo-contracts)
  routers/    — FastAPI handlers (thin, delegate to services/)
  services/   — Business logic
```

### Per-Repo Structure (Frontend)
```
src/
  api/
    client.ts   — axios instance
    types.ts    — TypeScript types (hand-written to match openapi.yaml)
  features/
    lists/      — List sidebar, hooks, modals
    todos/      — Todo board, item, filter, hooks
  components/
    tags/       — Tag UI (TagBadge, TagFilter)
```

## Naming Conventions

- **Spec folders**: `kebab-case` matching feature name (`add-tags`, not `AddTags`)
- **Backend**: `snake_case` for files, functions, variables (Python conventions)
- **Frontend**: `PascalCase` for React components and files; `camelCase` for hooks (`useTodos.ts`) and utilities

## Key Architectural Rules

- **Contracts first**: `openapi.yaml` is edited before any backend or frontend change
- **No business logic in routers**: FastAPI handlers call service functions only
- **No server state in `useState`**: All API-fetched data goes through TanStack Query hooks
- **Stubs are intentional markers**: Stub components/endpoints (`TagBadge`, `app/routers/tags.py`) exist as integration points, not bugs

---
_Document patterns, not file trees. New files following patterns shouldn't require updates_
