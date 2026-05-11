# Technology Stack

## Architecture

Four-repo split: contracts → backend → frontend, with infra as a separate orchestration layer. The OpenAPI spec in `todo-contracts` is the **single source of truth** for all API shapes — both the backend's Pydantic schemas and the frontend's TypeScript types derive from it.

## Core Technologies

- **Meta-repo**: No runtime code — markdown specs, shell scripts, SDD tooling
- **Contracts**: OpenAPI 3.1.0 (`openapi.yaml`)
- **Backend**: Python / FastAPI 0.111 / SQLAlchemy 2.0 / PostgreSQL 16
- **Frontend**: TypeScript / React 18 / Vite / TanStack Query v5

## Key Technical Decisions

- **Contracts-first**: Update `todo-contracts/openapi.yaml` before changing backend or frontend
- **Server state via TanStack Query**: Never use `useState` for data fetched from the API
- **Thin routers**: FastAPI route handlers delegate all business logic to `services/`
- **SQLAlchemy models as DB schema**: ORM models in `app/models/` drive Alembic migrations; Pydantic schemas in `app/schemas/` are written to match the contract

## Cross-Repo Change Propagation Order

```
todo-contracts  →  todo-backend  →  todo-frontend  →  (todo-infra, if needed)
```
Changes flow in this direction. Each repo is committed independently.

## Per-Repo Stacks

| Repo | Role | Primary Stack | Key Conventions |
|---|---|---|---|
| `todo-contracts` | API source of truth | OpenAPI 3.1.0 YAML | Edit first; never invent shapes elsewhere |
| `todo-backend` | REST API server | Python, FastAPI, SQLAlchemy, Alembic, Pydantic v2 | Thin routers; services layer; run `alembic revision --autogenerate` after model changes |
| `todo-frontend` | SPA client | TypeScript, React 18, Vite, TanStack Query v5, axios | API types hand-written to match contracts; `npm run generate-api` to regenerate; Vite proxies `/api/*` → `:8000` |
| `todo-infra` | Local dev environment | Docker Compose | Three services: frontend (:3000), backend (:8000), postgres (:5432) |

## Common Commands

```bash
# Meta-repo setup
./setup.sh         # clone all four app repos into repos/

# Backend (from todo-backend/)
make dev           # uvicorn on :8000 with --reload
make migrate       # run Alembic migrations
pytest tests/ -v   # tests (SQLite, no Postgres required)

# Frontend (from todo-frontend/)
npm run dev        # Vite dev server on :3000
npm run generate-api  # regenerate TypeScript types from openapi.yaml

# Infra
docker compose up  # start all services
```

---
_Document standards and patterns, not every dependency_
