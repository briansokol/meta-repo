# Todo App Multi-Repo Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 5 repos (todo-contracts, todo-backend, todo-frontend, todo-infra, todo-meta) that together demonstrate the Meta Repo pattern — a central context repo for AI-assisted development across a multi-repo project.

**Architecture:** An OpenAPI spec in `todo-contracts` is the source of truth. `todo-backend` (FastAPI) and `todo-frontend` (React/Vite) implement it. `todo-infra` wires them together with Docker Compose. `todo-meta` (at `~/Projects/meta-repo`) holds cross-repo AI context via `CLAUDE.md` references and a pre-written spec for the incomplete Tags feature.

**Tech Stack:** React 18 + Vite + TypeScript + TanStack Query (frontend); FastAPI + SQLAlchemy + Alembic + PostgreSQL (backend); OpenAPI 3.1 YAML (contracts); Docker Compose v2 (infra)

**Repo build order (dependency chain):** contracts → backend → frontend → infra → meta

---

## File Map

### todo-contracts
```
todo-contracts/
├── CLAUDE.md
├── openapi.yaml          # Single source of truth — all schemas + endpoints
├── package.json          # openapi-ts generator script
└── .gitignore
```

### todo-backend
```
todo-backend/
├── CLAUDE.md
├── requirements.txt
├── Makefile
├── alembic.ini
├── alembic/
│   ├── env.py
│   └── versions/
│       └── 001_initial_schema.py
├── app/
│   ├── __init__.py
│   ├── database.py       # SQLAlchemy engine + session
│   ├── models/
│   │   ├── __init__.py
│   │   ├── todo_list.py  # TodoList ORM model
│   │   └── todo.py       # Todo ORM model (priority, status, due_date, tags stub)
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── todo_list.py  # Pydantic schemas for lists
│   │   └── todo.py       # Pydantic schemas for todos
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── lists.py      # GET/POST /lists, GET/PUT/DELETE /lists/{id}
│   │   ├── todos.py      # GET/POST /lists/{id}/todos, PUT/DELETE /todos/{id}
│   │   └── tags.py       # STUB — all routes return 501
│   └── services/
│       ├── __init__.py
│       ├── lists.py      # List CRUD logic
│       └── todos.py      # Todo CRUD + filter logic
├── tests/
│   ├── conftest.py       # SQLite test DB fixture
│   ├── test_lists.py
│   └── test_todos.py
└── main.py               # FastAPI app, mounts routers, CORS
```

### todo-frontend
```
todo-frontend/
├── CLAUDE.md
├── package.json
├── vite.config.ts        # proxy /api → :8000
├── tsconfig.json
├── index.html
└── src/
    ├── main.tsx
    ├── App.tsx            # QueryClientProvider + layout
    ├── api/
    │   ├── client.ts     # axios instance pointed at /api
    │   └── types.ts      # TypeScript types matching openapi.yaml schemas
    ├── features/
    │   ├── lists/
    │   │   ├── ListSidebar.tsx      # Left panel, list of TodoLists
    │   │   ├── CreateListModal.tsx  # Modal form
    │   │   └── useLists.ts          # TanStack Query hooks for lists
    │   └── todos/
    │       ├── TodoBoard.tsx        # Right panel, todos for selected list
    │       ├── TodoItem.tsx         # Single row with priority badge + actions
    │       ├── CreateTodoModal.tsx  # Modal form
    │       ├── FilterBar.tsx        # Priority/status/due filter controls
    │       └── useTodos.ts          # TanStack Query hooks for todos
    └── components/
        └── tags/
            ├── TagBadge.tsx   # STUB — renders nothing, TODO comment
            └── TagFilter.tsx  # STUB — renders nothing, TODO comment
```

### todo-infra
```
todo-infra/
├── CLAUDE.md
├── docker-compose.yml    # frontend:3000, backend:8000, postgres:5432
├── .env.example
└── README.md
```

### todo-meta  (~/Projects/meta-repo)
```
todo-meta/
├── CLAUDE.md             # @-references to each app repo's CLAUDE.md
├── setup.sh              # Clones all 4 repos into repos/
├── .gitignore            # repos/ and specs/*/repos/
├── docs/
│   └── superpowers/
│       └── plans/
│           └── 2026-05-10-todo-meta-repo-demo.md  (this file)
└── specs/
    └── add-tags/
        ├── requirements.md
        ├── design.md
        └── tasks.md
```

---

## Task 1: Initialize todo-contracts repo

**Files:**
- Create: `~/Projects/todo-contracts/CLAUDE.md`
- Create: `~/Projects/todo-contracts/openapi.yaml`
- Create: `~/Projects/todo-contracts/package.json`
- Create: `~/Projects/todo-contracts/.gitignore`

- [ ] **Step 1: Scaffold the repo**

```bash
cd ~/Projects
mkdir todo-contracts && cd todo-contracts
git init
```

- [ ] **Step 2: Create `.gitignore`**

```
node_modules/
generated/
```

- [ ] **Step 3: Create `package.json`**

```json
{
  "name": "todo-contracts",
  "version": "1.0.0",
  "description": "OpenAPI contract definitions for the Todo App",
  "scripts": {
    "generate-frontend": "openapi-ts --input openapi.yaml --output ../todo-frontend/src/api/generated --client axios",
    "validate": "redocly lint openapi.yaml"
  },
  "devDependencies": {
    "@hey-api/openapi-ts": "^0.46.0"
  }
}
```

- [ ] **Step 4: Create `openapi.yaml`** — full spec with Tags schema defined but endpoints stubbed

```yaml
openapi: 3.1.0
info:
  title: Todo App API
  version: 1.0.0
  description: >
    REST API for the Todo App. This file is the single source of truth for
    all request/response shapes. Frontend and backend both derive their types
    from this spec.

servers:
  - url: http://localhost:8000
    description: Local development

tags:
  - name: lists
    description: Todo lists (collections of todos)
  - name: todos
    description: Individual todo items
  - name: tags
    description: Tags for categorizing todos (NOT YET IMPLEMENTED)

paths:
  /lists:
    get:
      summary: Get all todo lists
      operationId: getLists
      tags: [lists]
      responses:
        "200":
          description: List of todo lists
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: "#/components/schemas/TodoList"
    post:
      summary: Create a todo list
      operationId: createList
      tags: [lists]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/TodoListCreate"
      responses:
        "201":
          description: Created list
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/TodoList"

  /lists/{list_id}:
    parameters:
      - name: list_id
        in: path
        required: true
        schema:
          type: integer
    get:
      summary: Get a todo list by ID
      operationId: getList
      tags: [lists]
      responses:
        "200":
          description: The todo list
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/TodoList"
        "404":
          description: Not found
    put:
      summary: Update a todo list
      operationId: updateList
      tags: [lists]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/TodoListCreate"
      responses:
        "200":
          description: Updated list
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/TodoList"
        "404":
          description: Not found
    delete:
      summary: Delete a todo list
      operationId: deleteList
      tags: [lists]
      responses:
        "204":
          description: Deleted
        "404":
          description: Not found

  /lists/{list_id}/todos:
    parameters:
      - name: list_id
        in: path
        required: true
        schema:
          type: integer
    get:
      summary: Get todos in a list
      operationId: getTodos
      tags: [todos]
      parameters:
        - name: priority
          in: query
          schema:
            $ref: "#/components/schemas/Priority"
        - name: status
          in: query
          schema:
            $ref: "#/components/schemas/Status"
        - name: due_before
          in: query
          schema:
            type: string
            format: date
      responses:
        "200":
          description: List of todos
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: "#/components/schemas/Todo"
    post:
      summary: Create a todo
      operationId: createTodo
      tags: [todos]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/TodoCreate"
      responses:
        "201":
          description: Created todo
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Todo"

  /todos/{todo_id}:
    parameters:
      - name: todo_id
        in: path
        required: true
        schema:
          type: integer
    get:
      summary: Get a todo by ID
      operationId: getTodo
      tags: [todos]
      responses:
        "200":
          description: The todo
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Todo"
        "404":
          description: Not found
    put:
      summary: Update a todo
      operationId: updateTodo
      tags: [todos]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/TodoUpdate"
      responses:
        "200":
          description: Updated todo
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Todo"
        "404":
          description: Not found
    delete:
      summary: Delete a todo
      operationId: deleteTodo
      tags: [todos]
      responses:
        "204":
          description: Deleted
        "404":
          description: Not found

  # TODO: implement tags endpoints
  # The Tag schema is defined below. When implementing:
  # POST /tags — create a tag
  # GET /tags — list all tags
  # POST /todos/{todo_id}/tags/{tag_id} — add tag to todo
  # DELETE /todos/{todo_id}/tags/{tag_id} — remove tag from todo

components:
  schemas:
    Priority:
      type: string
      enum: [low, medium, high]

    Status:
      type: string
      enum: [pending, in_progress, done]

    TodoList:
      type: object
      required: [id, name, created_at]
      properties:
        id:
          type: integer
        name:
          type: string
        description:
          type: string
          nullable: true
        created_at:
          type: string
          format: date-time

    TodoListCreate:
      type: object
      required: [name]
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
        description:
          type: string
          nullable: true

    Todo:
      type: object
      required: [id, list_id, title, status, priority, created_at]
      properties:
        id:
          type: integer
        list_id:
          type: integer
        title:
          type: string
        description:
          type: string
          nullable: true
        status:
          $ref: "#/components/schemas/Status"
        priority:
          $ref: "#/components/schemas/Priority"
        due_date:
          type: string
          format: date
          nullable: true
        created_at:
          type: string
          format: date-time
        tags:
          type: array
          items:
            $ref: "#/components/schemas/Tag"
          description: Tags attached to this todo (feature not yet implemented — always empty)

    TodoCreate:
      type: object
      required: [title]
      properties:
        title:
          type: string
          minLength: 1
          maxLength: 200
        description:
          type: string
          nullable: true
        priority:
          $ref: "#/components/schemas/Priority"
          default: medium
        due_date:
          type: string
          format: date
          nullable: true

    TodoUpdate:
      type: object
      properties:
        title:
          type: string
          minLength: 1
          maxLength: 200
        description:
          type: string
          nullable: true
        status:
          $ref: "#/components/schemas/Status"
        priority:
          $ref: "#/components/schemas/Priority"
        due_date:
          type: string
          format: date
          nullable: true

    Tag:
      type: object
      required: [id, name, color]
      properties:
        id:
          type: integer
        name:
          type: string
          minLength: 1
          maxLength: 50
        color:
          type: string
          description: Hex color code e.g. "#3b82f6"
          pattern: "^#[0-9a-fA-F]{6}$"

    TagCreate:
      type: object
      required: [name, color]
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 50
        color:
          type: string
          pattern: "^#[0-9a-fA-F]{6}$"
```

- [ ] **Step 5: Create `CLAUDE.md`**

```markdown
# todo-contracts

OpenAPI specification for the Todo App. This is the **single source of truth** for all API shapes.

## What lives here

`openapi.yaml` — all request/response schemas and endpoint definitions.

## Rules

- **Update this file first.** Before changing the backend or frontend, update the spec.
- The frontend generates its TypeScript API client from this spec.
- The backend's Pydantic schemas should match this spec (currently hand-written to match; a future task could auto-generate them with `datamodel-code-generator`).

## Generating the frontend API client

From `todo-frontend/`:
```bash
npm run generate-api
```

This runs `openapi-ts` and writes TypeScript types + an axios client to `src/api/generated/`.

## Tags

The `Tag` and `TagCreate` schemas are defined. The **tag endpoints are not yet implemented** — see the `# TODO` comment in `openapi.yaml` around line 90. The `tags` array on `Todo` always returns empty until the feature is complete.
```

- [ ] **Step 6: Initial commit**

```bash
cd ~/Projects/todo-contracts
git add .
git commit -m "feat: initial OpenAPI spec with tags schema stubbed"
```

---

## Task 2: Initialize todo-backend repo

**Files:**
- Create: `~/Projects/todo-backend/requirements.txt`
- Create: `~/Projects/todo-backend/main.py`
- Create: `~/Projects/todo-backend/app/database.py`
- Create: `~/Projects/todo-backend/Makefile`
- Create: `~/Projects/todo-backend/alembic.ini`

- [ ] **Step 1: Scaffold repo and virtualenv**

```bash
cd ~/Projects
mkdir todo-backend && cd todo-backend
git init
python3 -m venv .venv
source .venv/bin/activate
```

- [ ] **Step 2: Create `requirements.txt`**

```
fastapi==0.111.0
uvicorn[standard]==0.29.0
sqlalchemy==2.0.30
alembic==1.13.1
psycopg2-binary==2.9.9
python-dotenv==1.0.1
pydantic[email]==2.7.1

# Dev / test
pytest==8.2.0
pytest-asyncio==0.23.6
httpx==0.27.0
```

- [ ] **Step 3: Install dependencies**

```bash
pip install -r requirements.txt
```

- [ ] **Step 4: Create `.gitignore`**

```
.venv/
__pycache__/
*.pyc
.env
*.db
```

- [ ] **Step 5: Create `app/__init__.py`** (empty)

```bash
mkdir -p app/models app/schemas app/routers app/services
touch app/__init__.py app/models/__init__.py app/schemas/__init__.py
touch app/routers/__init__.py app/services/__init__.py
```

- [ ] **Step 6: Create `app/database.py`**

```python
import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://todo:todo@localhost:5432/todo"
)

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

- [ ] **Step 7: Create `main.py`**

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import lists, todos, tags

app = FastAPI(title="Todo App API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(lists.router)
app.include_router(todos.router)
app.include_router(tags.router)


@app.get("/health")
def health():
    return {"status": "ok"}
```

- [ ] **Step 8: Create `Makefile`**

```makefile
.PHONY: dev test migrate generate-schemas

dev:
	uvicorn main:app --reload --port 8000

test:
	pytest tests/ -v

migrate:
	alembic upgrade head

generate-schemas:
	@echo "Regenerate Pydantic schemas from openapi.yaml using datamodel-code-generator"
	@echo "Run: datamodel-codegen --input ../todo-contracts/openapi.yaml --output app/schemas/generated.py"
```

- [ ] **Step 9: Initialize Alembic**

```bash
alembic init alembic
```

- [ ] **Step 10: Update `alembic/env.py`** — replace the `target_metadata = None` line

Find this in `alembic/env.py`:
```python
target_metadata = None
```

Replace with:
```python
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from app.database import Base
from app.models import todo_list, todo  # noqa: F401 — ensures models register

target_metadata = Base.metadata
```

Also update the `get_url()` or `sqlalchemy.url` section. Find:
```python
    config.set_main_option("sqlalchemy.url", ...)
```

Replace the `run_migrations_offline` and `run_migrations_online` functions to use:
```python
from app.database import DATABASE_URL
config.set_main_option("sqlalchemy.url", DATABASE_URL)
```

Full updated `alembic/env.py`:
```python
import sys
import os
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool
from alembic import context

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app.database import Base, DATABASE_URL
from app.models import todo_list, todo  # noqa: F401

config = context.config
config.set_main_option("sqlalchemy.url", DATABASE_URL)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(url=url, target_metadata=target_metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

- [ ] **Step 11: Commit scaffold**

```bash
cd ~/Projects/todo-backend
git add .
git commit -m "feat: scaffold FastAPI app with SQLAlchemy and Alembic"
```

---

## Task 3: Backend models and initial migration

**Files:**
- Create: `~/Projects/todo-backend/app/models/todo_list.py`
- Create: `~/Projects/todo-backend/app/models/todo.py`
- Create: `~/Projects/todo-backend/alembic/versions/001_initial_schema.py`

- [ ] **Step 1: Create `app/models/todo_list.py`**

```python
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from app.database import Base


class TodoList(Base):
    __tablename__ = "todo_lists"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    todos = relationship("Todo", back_populates="list", cascade="all, delete-orphan")
```

- [ ] **Step 2: Create `app/models/todo.py`**

```python
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Date, ForeignKey, Enum
from sqlalchemy.orm import relationship
import enum
from app.database import Base


class Priority(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"


class Status(str, enum.Enum):
    pending = "pending"
    in_progress = "in_progress"
    done = "done"


class Todo(Base):
    __tablename__ = "todos"

    id = Column(Integer, primary_key=True, index=True)
    list_id = Column(Integer, ForeignKey("todo_lists.id"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(String, nullable=True)
    status = Column(Enum(Status), default=Status.pending, nullable=False)
    priority = Column(Enum(Priority), default=Priority.medium, nullable=False)
    due_date = Column(Date, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    list = relationship("TodoList", back_populates="todos")
    # tags relationship intentionally omitted — feature not yet implemented
```

- [ ] **Step 3: Generate migration**

```bash
cd ~/Projects/todo-backend
source .venv/bin/activate
# Requires postgres running — use docker compose from todo-infra, or run:
# docker run -d -e POSTGRES_USER=todo -e POSTGRES_PASSWORD=todo -e POSTGRES_DB=todo -p 5432:5432 postgres:16
alembic revision --autogenerate -m "initial schema"
```

Expected: creates `alembic/versions/<hash>_initial_schema.py`

- [ ] **Step 4: Rename migration file to match plan naming**

```bash
# Rename the generated file to have a clean prefix
cd ~/Projects/todo-backend/alembic/versions
ls  # note the generated filename
# mv <hash>_initial_schema.py 001_initial_schema.py
# Update the file's `revision` and `down_revision` if you rename it
```

- [ ] **Step 5: Run migration**

```bash
cd ~/Projects/todo-backend
alembic upgrade head
```

Expected output ends with: `Running upgrade  -> <rev>, initial schema`

- [ ] **Step 6: Commit**

```bash
git add .
git commit -m "feat: add TodoList and Todo ORM models with initial migration"
```

---

## Task 4: Backend Pydantic schemas

**Files:**
- Create: `~/Projects/todo-backend/app/schemas/todo_list.py`
- Create: `~/Projects/todo-backend/app/schemas/todo.py`

- [ ] **Step 1: Write failing test for list schema**

Create `tests/conftest.py`:
```python
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base

TEST_DATABASE_URL = "sqlite:///./test.db"

@pytest.fixture(scope="function")
def db():
    engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    TestSession = sessionmaker(bind=engine)
    session = TestSession()
    yield session
    session.close()
    Base.metadata.drop_all(bind=engine)
```

Create `tests/__init__.py` (empty).

Create `tests/test_lists.py`:
```python
from app.schemas.todo_list import TodoListCreate, TodoListOut


def test_todo_list_create_schema():
    data = TodoListCreate(name="Work", description="Work tasks")
    assert data.name == "Work"
    assert data.description == "Work tasks"


def test_todo_list_create_requires_name():
    import pytest
    from pydantic import ValidationError
    with pytest.raises(ValidationError):
        TodoListCreate()


def test_todo_list_out_schema():
    from datetime import datetime
    data = TodoListOut(id=1, name="Work", description=None, created_at=datetime.utcnow())
    assert data.id == 1
    assert data.name == "Work"
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
cd ~/Projects/todo-backend
source .venv/bin/activate
pytest tests/test_lists.py -v
```

Expected: `ImportError` — `app.schemas.todo_list` not found

- [ ] **Step 3: Create `app/schemas/todo_list.py`**

```python
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class TodoListCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    description: Optional[str] = None


class TodoListOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
pytest tests/test_lists.py -v
```

Expected: 3 tests PASS

- [ ] **Step 5: Write failing test for todo schema**

Add to `tests/test_todos.py`:
```python
from app.schemas.todo import TodoCreate, TodoOut, TodoUpdate
from app.models.todo import Priority, Status
from datetime import datetime


def test_todo_create_defaults():
    data = TodoCreate(title="Buy milk")
    assert data.title == "Buy milk"
    assert data.priority == Priority.medium
    assert data.status is None or data.status == Status.pending


def test_todo_create_requires_title():
    import pytest
    from pydantic import ValidationError
    with pytest.raises(ValidationError):
        TodoCreate()


def test_todo_out_has_tags_as_empty_list():
    data = TodoOut(
        id=1, list_id=1, title="Test", status=Status.pending,
        priority=Priority.medium, created_at=datetime.utcnow(), tags=[]
    )
    assert data.tags == []
```

- [ ] **Step 6: Run test — expect FAIL**

```bash
pytest tests/test_todos.py -v
```

Expected: `ImportError` — `app.schemas.todo` not found

- [ ] **Step 7: Create `app/schemas/todo.py`**

```python
from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel, Field
from app.models.todo import Priority, Status


class TagOut(BaseModel):
    id: int
    name: str
    color: str

    model_config = {"from_attributes": True}


class TodoCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: Optional[str] = None
    priority: Priority = Priority.medium
    due_date: Optional[date] = None


class TodoUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    description: Optional[str] = None
    status: Optional[Status] = None
    priority: Optional[Priority] = None
    due_date: Optional[date] = None


class TodoOut(BaseModel):
    id: int
    list_id: int
    title: str
    description: Optional[str]
    status: Status
    priority: Priority
    due_date: Optional[date]
    created_at: datetime
    tags: List[TagOut] = []

    model_config = {"from_attributes": True}
```

- [ ] **Step 8: Run all tests — expect PASS**

```bash
pytest tests/ -v
```

Expected: 6 tests PASS

- [ ] **Step 9: Commit**

```bash
git add .
git commit -m "feat: add Pydantic schemas for lists and todos"
```

---

## Task 5: Backend services and routers (lists + todos)

**Files:**
- Create: `~/Projects/todo-backend/app/services/lists.py`
- Create: `~/Projects/todo-backend/app/services/todos.py`
- Create: `~/Projects/todo-backend/app/routers/lists.py`
- Create: `~/Projects/todo-backend/app/routers/todos.py`

- [ ] **Step 1: Create `app/services/lists.py`**

```python
from sqlalchemy.orm import Session
from app.models.todo_list import TodoList
from app.schemas.todo_list import TodoListCreate
from fastapi import HTTPException


def get_lists(db: Session):
    return db.query(TodoList).order_by(TodoList.created_at).all()


def get_list(db: Session, list_id: int) -> TodoList:
    todo_list = db.query(TodoList).filter(TodoList.id == list_id).first()
    if not todo_list:
        raise HTTPException(status_code=404, detail="List not found")
    return todo_list


def create_list(db: Session, data: TodoListCreate) -> TodoList:
    todo_list = TodoList(**data.model_dump())
    db.add(todo_list)
    db.commit()
    db.refresh(todo_list)
    return todo_list


def update_list(db: Session, list_id: int, data: TodoListCreate) -> TodoList:
    todo_list = get_list(db, list_id)
    for key, value in data.model_dump().items():
        setattr(todo_list, key, value)
    db.commit()
    db.refresh(todo_list)
    return todo_list


def delete_list(db: Session, list_id: int) -> None:
    todo_list = get_list(db, list_id)
    db.delete(todo_list)
    db.commit()
```

- [ ] **Step 2: Create `app/services/todos.py`**

```python
from datetime import date
from typing import Optional
from sqlalchemy.orm import Session
from app.models.todo import Todo, Priority, Status
from app.schemas.todo import TodoCreate, TodoUpdate
from fastapi import HTTPException


def get_todos(
    db: Session,
    list_id: int,
    priority: Optional[Priority] = None,
    status: Optional[Status] = None,
    due_before: Optional[date] = None,
):
    query = db.query(Todo).filter(Todo.list_id == list_id)
    if priority:
        query = query.filter(Todo.priority == priority)
    if status:
        query = query.filter(Todo.status == status)
    if due_before:
        query = query.filter(Todo.due_date <= due_before)
    return query.order_by(Todo.created_at).all()


def get_todo(db: Session, todo_id: int) -> Todo:
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo


def create_todo(db: Session, list_id: int, data: TodoCreate) -> Todo:
    todo = Todo(list_id=list_id, **data.model_dump())
    db.add(todo)
    db.commit()
    db.refresh(todo)
    return todo


def update_todo(db: Session, todo_id: int, data: TodoUpdate) -> Todo:
    todo = get_todo(db, todo_id)
    for key, value in data.model_dump(exclude_none=True).items():
        setattr(todo, key, value)
    db.commit()
    db.refresh(todo)
    return todo


def delete_todo(db: Session, todo_id: int) -> None:
    todo = get_todo(db, todo_id)
    db.delete(todo)
    db.commit()
```

- [ ] **Step 3: Create `app/routers/lists.py`**

```python
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.todo_list import TodoListCreate, TodoListOut
from app.services import lists as list_service

router = APIRouter(prefix="/lists", tags=["lists"])


@router.get("", response_model=List[TodoListOut])
def get_lists(db: Session = Depends(get_db)):
    return list_service.get_lists(db)


@router.post("", response_model=TodoListOut, status_code=201)
def create_list(data: TodoListCreate, db: Session = Depends(get_db)):
    return list_service.create_list(db, data)


@router.get("/{list_id}", response_model=TodoListOut)
def get_list(list_id: int, db: Session = Depends(get_db)):
    return list_service.get_list(db, list_id)


@router.put("/{list_id}", response_model=TodoListOut)
def update_list(list_id: int, data: TodoListCreate, db: Session = Depends(get_db)):
    return list_service.update_list(db, list_id, data)


@router.delete("/{list_id}", status_code=204)
def delete_list(list_id: int, db: Session = Depends(get_db)):
    list_service.delete_list(db, list_id)
```

- [ ] **Step 4: Create `app/routers/todos.py`**

```python
from datetime import date
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.todo import Priority, Status
from app.schemas.todo import TodoCreate, TodoUpdate, TodoOut
from app.services import todos as todo_service
from app.services import lists as list_service

router = APIRouter(tags=["todos"])


@router.get("/lists/{list_id}/todos", response_model=List[TodoOut])
def get_todos(
    list_id: int,
    priority: Optional[Priority] = Query(None),
    status: Optional[Status] = Query(None),
    due_before: Optional[date] = Query(None),
    db: Session = Depends(get_db),
):
    list_service.get_list(db, list_id)  # raises 404 if list not found
    return todo_service.get_todos(db, list_id, priority, status, due_before)


@router.post("/lists/{list_id}/todos", response_model=TodoOut, status_code=201)
def create_todo(list_id: int, data: TodoCreate, db: Session = Depends(get_db)):
    list_service.get_list(db, list_id)
    return todo_service.create_todo(db, list_id, data)


@router.get("/todos/{todo_id}", response_model=TodoOut)
def get_todo(todo_id: int, db: Session = Depends(get_db)):
    return todo_service.get_todo(db, todo_id)


@router.put("/todos/{todo_id}", response_model=TodoOut)
def update_todo(todo_id: int, data: TodoUpdate, db: Session = Depends(get_db)):
    return todo_service.update_todo(db, todo_id, data)


@router.delete("/todos/{todo_id}", status_code=204)
def delete_todo(todo_id: int, db: Session = Depends(get_db)):
    todo_service.delete_todo(db, todo_id)
```

- [ ] **Step 5: Write integration test for lists endpoint**

Add to `tests/test_lists.py`:
```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base, get_db
from main import app

TEST_DB_URL = "sqlite:///./test_integration.db"
engine = create_engine(TEST_DB_URL, connect_args={"check_same_thread": False})
TestSessionLocal = sessionmaker(bind=engine)


@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client():
    def override_get_db():
        db = TestSessionLocal()
        try:
            yield db
        finally:
            db.close()
    app.dependency_overrides[get_db] = override_get_db
    return TestClient(app)


def test_create_and_get_list(client):
    response = client.post("/lists", json={"name": "Work", "description": "Work tasks"})
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Work"
    assert "id" in data

    response = client.get("/lists")
    assert response.status_code == 200
    assert len(response.json()) == 1


def test_delete_list(client):
    response = client.post("/lists", json={"name": "Temp"})
    list_id = response.json()["id"]
    response = client.delete(f"/lists/{list_id}")
    assert response.status_code == 204
    response = client.get(f"/lists/{list_id}")
    assert response.status_code == 404
```

- [ ] **Step 6: Run all tests — expect PASS**

```bash
pytest tests/ -v
```

Expected: all tests PASS (schema tests + integration tests)

- [ ] **Step 7: Commit**

```bash
git add .
git commit -m "feat: add list and todo services, routers, and integration tests"
```

---

## Task 6: Backend tags stub router

**Files:**
- Create: `~/Projects/todo-backend/app/routers/tags.py`

- [ ] **Step 1: Create `app/routers/tags.py`** — returns 501 for all endpoints

Note: no `prefix` on the router — the tag routes span two path prefixes (`/tags` and `/todos`).

```python
from fastapi import APIRouter
from fastapi.responses import JSONResponse

router = APIRouter(tags=["tags"])

NOT_IMPLEMENTED = JSONResponse(
    status_code=501,
    content={"detail": "Tags feature not yet implemented. See specs/add-tags/ in todo-meta."},
)


@router.get("/tags")
def list_tags():
    """List all tags. NOT YET IMPLEMENTED."""
    return NOT_IMPLEMENTED


@router.post("/tags")
def create_tag():
    """Create a tag. NOT YET IMPLEMENTED."""
    return NOT_IMPLEMENTED


@router.post("/todos/{todo_id}/tags/{tag_id}")
def add_tag_to_todo(todo_id: int, tag_id: int):
    """Add a tag to a todo. NOT YET IMPLEMENTED."""
    return NOT_IMPLEMENTED


@router.delete("/todos/{todo_id}/tags/{tag_id}")
def remove_tag_from_todo(todo_id: int, tag_id: int):
    """Remove a tag from a todo. NOT YET IMPLEMENTED."""
    return NOT_IMPLEMENTED
```

- [ ] **Step 2: Write test for stub behavior**

Add `tests/test_tags_stub.py`:
```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base, get_db
from main import app

TEST_DB_URL = "sqlite:///./test_tags.db"
engine = create_engine(TEST_DB_URL, connect_args={"check_same_thread": False})
TestSessionLocal = sessionmaker(bind=engine)


@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client():
    def override():
        db = TestSessionLocal()
        try:
            yield db
        finally:
            db.close()
    app.dependency_overrides[get_db] = override
    return TestClient(app)


def test_tags_list_returns_501(client):
    response = client.get("/tags")
    assert response.status_code == 501
    assert "not yet implemented" in response.json()["detail"].lower()


def test_tags_create_returns_501(client):
    response = client.post("/tags", json={"name": "urgent", "color": "#ff0000"})
    assert response.status_code == 501
```

- [ ] **Step 3: Run test — expect PASS**

```bash
pytest tests/test_tags_stub.py -v
```

Expected: 2 tests PASS

- [ ] **Step 4: Create `CLAUDE.md`**

```markdown
# todo-backend

FastAPI backend for the Todo App.

## Stack

- **FastAPI** 0.111 — web framework
- **SQLAlchemy** 2.0 — ORM
- **Alembic** — database migrations
- **PostgreSQL** 16 — database (SQLite for tests)
- **Pydantic** v2 — request/response validation

## Project structure

```
app/
  models/      — SQLAlchemy ORM models (source of DB schema)
  schemas/     — Pydantic models for request/response (hand-written to match todo-contracts)
  routers/     — FastAPI route handlers (thin — delegate to services/)
  services/    — Business logic (CRUD operations, filtering)
main.py        — FastAPI app, router mounts, CORS config
alembic/       — DB migrations (run after model changes)
```

## Schemas are derived from todo-contracts

The Pydantic schemas in `app/schemas/` are written to match `todo-contracts/openapi.yaml`. Do not invent new shapes — check the spec first. To regenerate them automatically: `make generate-schemas`.

## Running locally

Requires PostgreSQL running (use `todo-infra` Docker Compose or run postgres manually):

```bash
source .venv/bin/activate
make migrate       # run pending Alembic migrations
make dev           # starts uvicorn on :8000 with --reload
```

## Running tests

Tests use SQLite — no PostgreSQL required:

```bash
pytest tests/ -v
```

## Adding a migration

After changing a model in `app/models/`:

```bash
alembic revision --autogenerate -m "describe the change"
alembic upgrade head
```

## Known stubs

`app/routers/tags.py` — all endpoints return `501 Not Implemented`. The Tags feature is not complete:
- No `Tag` model exists yet
- No `tags` table in the DB
- No migration for tags
- See `specs/add-tags/` in `todo-meta` for the implementation spec
```

- [ ] **Step 5: Run all tests — expect PASS**

```bash
pytest tests/ -v
```

- [ ] **Step 6: Final commit**

```bash
git add .
git commit -m "feat: add tags stub router (501) and backend CLAUDE.md"
```

---

## Task 7: Initialize and scaffold todo-frontend

**Files:**
- Create: `~/Projects/todo-frontend/` (Vite scaffold)
- Create: `~/Projects/todo-frontend/vite.config.ts`
- Create: `~/Projects/todo-frontend/src/api/types.ts`
- Create: `~/Projects/todo-frontend/src/api/client.ts`

- [ ] **Step 1: Scaffold with Vite**

```bash
cd ~/Projects
npm create vite@latest todo-frontend -- --template react-ts
cd todo-frontend
npm install
```

- [ ] **Step 2: Install dependencies**

```bash
npm install @tanstack/react-query axios
npm install -D @tanstack/react-query-devtools
```

- [ ] **Step 3: Update `vite.config.ts`** — add proxy to backend

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
})
```

- [ ] **Step 4: Create `src/api/client.ts`**

```typescript
import axios from 'axios'

export const apiClient = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json' },
})
```

- [ ] **Step 5: Create `src/api/types.ts`** — TypeScript types matching openapi.yaml schemas

```typescript
// Types derived from todo-contracts/openapi.yaml
// To regenerate: npm run generate-api (runs openapi-ts)

export type Priority = 'low' | 'medium' | 'high'
export type Status = 'pending' | 'in_progress' | 'done'

export interface Tag {
  id: number
  name: string
  color: string
}

export interface TodoList {
  id: number
  name: string
  description: string | null
  created_at: string
}

export interface TodoListCreate {
  name: string
  description?: string | null
}

export interface Todo {
  id: number
  list_id: number
  title: string
  description: string | null
  status: Status
  priority: Priority
  due_date: string | null
  created_at: string
  tags: Tag[]  // always [] until tags feature is implemented
}

export interface TodoCreate {
  title: string
  description?: string | null
  priority?: Priority
  due_date?: string | null
}

export interface TodoUpdate {
  title?: string
  description?: string | null
  status?: Status
  priority?: Priority
  due_date?: string | null
}
```

- [ ] **Step 6: Add `generate-api` script to `package.json`**

In `package.json`, add to `"scripts"`:
```json
"generate-api": "openapi-ts --input ../todo-contracts/openapi.yaml --output src/api/generated --client axios"
```

- [ ] **Step 7: Replace `src/App.tsx`** with QueryClientProvider shell

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { useState } from 'react'
import { ListSidebar } from './features/lists/ListSidebar'
import { TodoBoard } from './features/todos/TodoBoard'

const queryClient = new QueryClient()

export default function App() {
  const [selectedListId, setSelectedListId] = useState<number | null>(null)

  return (
    <QueryClientProvider client={queryClient}>
      <div style={{ display: 'flex', height: '100vh', fontFamily: 'system-ui, sans-serif' }}>
        <ListSidebar selectedListId={selectedListId} onSelectList={setSelectedListId} />
        <main style={{ flex: 1, padding: '24px', overflowY: 'auto' }}>
          {selectedListId ? (
            <TodoBoard listId={selectedListId} />
          ) : (
            <p style={{ color: '#6b7280' }}>Select a list to get started.</p>
          )}
        </main>
      </div>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

- [ ] **Step 8: Create directory structure**

```bash
mkdir -p src/features/lists src/features/todos src/components/tags
```

- [ ] **Step 9: Commit scaffold**

```bash
cd ~/Projects/todo-frontend
git add .
git commit -m "feat: scaffold React/Vite frontend with TanStack Query and API client"
```

---

## Task 8: Frontend lists feature

**Files:**
- Create: `~/Projects/todo-frontend/src/features/lists/useLists.ts`
- Create: `~/Projects/todo-frontend/src/features/lists/ListSidebar.tsx`
- Create: `~/Projects/todo-frontend/src/features/lists/CreateListModal.tsx`

- [ ] **Step 1: Create `src/features/lists/useLists.ts`**

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { apiClient } from '../../api/client'
import type { TodoList, TodoListCreate } from '../../api/types'

export function useLists() {
  return useQuery<TodoList[]>({
    queryKey: ['lists'],
    queryFn: async () => {
      const { data } = await apiClient.get('/lists')
      return data
    },
  })
}

export function useCreateList() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (payload: TodoListCreate) => {
      const { data } = await apiClient.post<TodoList>('/lists', payload)
      return data
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['lists'] }),
  })
}

export function useDeleteList() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (listId: number) => {
      await apiClient.delete(`/lists/${listId}`)
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['lists'] }),
  })
}
```

- [ ] **Step 2: Create `src/features/lists/CreateListModal.tsx`**

```tsx
import { useState } from 'react'
import { useCreateList } from './useLists'

interface Props {
  onClose: () => void
}

export function CreateListModal({ onClose }: Props) {
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const createList = useCreateList()

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) return
    createList.mutate({ name: name.trim(), description: description.trim() || null }, {
      onSuccess: onClose,
    })
  }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
      <form onSubmit={handleSubmit} style={{ background: 'white', borderRadius: 8, padding: 24, minWidth: 360 }}>
        <h2 style={{ margin: '0 0 16px' }}>New List</h2>
        <label style={{ display: 'block', marginBottom: 12 }}>
          Name
          <input
            value={name}
            onChange={e => setName(e.target.value)}
            placeholder="e.g. Work, Personal"
            style={{ display: 'block', width: '100%', marginTop: 4, padding: '6px 8px', border: '1px solid #d1d5db', borderRadius: 4 }}
            autoFocus
          />
        </label>
        <label style={{ display: 'block', marginBottom: 16 }}>
          Description (optional)
          <input
            value={description}
            onChange={e => setDescription(e.target.value)}
            style={{ display: 'block', width: '100%', marginTop: 4, padding: '6px 8px', border: '1px solid #d1d5db', borderRadius: 4 }}
          />
        </label>
        <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
          <button type="button" onClick={onClose} style={{ padding: '6px 16px' }}>Cancel</button>
          <button type="submit" disabled={!name.trim()} style={{ padding: '6px 16px', background: '#3b82f6', color: 'white', border: 'none', borderRadius: 4 }}>
            Create
          </button>
        </div>
      </form>
    </div>
  )
}
```

- [ ] **Step 3: Create `src/features/lists/ListSidebar.tsx`**

```tsx
import { useState } from 'react'
import { useLists, useDeleteList } from './useLists'
import { CreateListModal } from './CreateListModal'

interface Props {
  selectedListId: number | null
  onSelectList: (id: number) => void
}

export function ListSidebar({ selectedListId, onSelectList }: Props) {
  const { data: lists, isLoading } = useLists()
  const deleteList = useDeleteList()
  const [showModal, setShowModal] = useState(false)

  return (
    <aside style={{ width: 240, borderRight: '1px solid #e5e7eb', padding: '16px', overflowY: 'auto', background: '#f9fafb' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
        <h2 style={{ margin: 0, fontSize: 16 }}>Lists</h2>
        <button
          onClick={() => setShowModal(true)}
          style={{ background: '#3b82f6', color: 'white', border: 'none', borderRadius: 4, padding: '4px 10px', cursor: 'pointer' }}
        >
          +
        </button>
      </div>

      {isLoading && <p style={{ color: '#9ca3af', fontSize: 14 }}>Loading…</p>}

      {lists?.map(list => (
        <div
          key={list.id}
          onClick={() => onSelectList(list.id)}
          style={{
            padding: '8px 12px',
            borderRadius: 6,
            cursor: 'pointer',
            marginBottom: 4,
            background: list.id === selectedListId ? '#dbeafe' : 'transparent',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          <span style={{ fontWeight: list.id === selectedListId ? 600 : 400 }}>{list.name}</span>
          <button
            onClick={e => { e.stopPropagation(); deleteList.mutate(list.id) }}
            style={{ background: 'none', border: 'none', color: '#9ca3af', cursor: 'pointer', fontSize: 16, padding: '0 4px' }}
          >
            ×
          </button>
        </div>
      ))}

      {lists?.length === 0 && !isLoading && (
        <p style={{ color: '#9ca3af', fontSize: 13 }}>No lists yet.</p>
      )}

      {showModal && <CreateListModal onClose={() => setShowModal(false)} />}
    </aside>
  )
}
```

- [ ] **Step 4: Verify app loads in browser**

```bash
cd ~/Projects/todo-frontend
npm run dev
```

Open http://localhost:3000 — sidebar renders. Creating a list requires backend running.

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: lists sidebar with create/delete and TanStack Query hooks"
```

---

## Task 9: Frontend todos feature

**Files:**
- Create: `~/Projects/todo-frontend/src/features/todos/useTodos.ts`
- Create: `~/Projects/todo-frontend/src/features/todos/FilterBar.tsx`
- Create: `~/Projects/todo-frontend/src/features/todos/CreateTodoModal.tsx`
- Create: `~/Projects/todo-frontend/src/features/todos/TodoItem.tsx`
- Create: `~/Projects/todo-frontend/src/features/todos/TodoBoard.tsx`

- [ ] **Step 1: Create `src/features/todos/useTodos.ts`**

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { apiClient } from '../../api/client'
import type { Todo, TodoCreate, TodoUpdate, Priority, Status } from '../../api/types'

interface TodoFilters {
  priority?: Priority
  status?: Status
  due_before?: string
}

export function useTodos(listId: number, filters: TodoFilters = {}) {
  return useQuery<Todo[]>({
    queryKey: ['todos', listId, filters],
    queryFn: async () => {
      const { data } = await apiClient.get(`/lists/${listId}/todos`, { params: filters })
      return data
    },
  })
}

export function useCreateTodo(listId: number) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (payload: TodoCreate) => {
      const { data } = await apiClient.post<Todo>(`/lists/${listId}/todos`, payload)
      return data
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos', listId] }),
  })
}

export function useUpdateTodo(listId: number) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async ({ todoId, data }: { todoId: number; data: TodoUpdate }) => {
      const { data: updated } = await apiClient.put<Todo>(`/todos/${todoId}`, data)
      return updated
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos', listId] }),
  })
}

export function useDeleteTodo(listId: number) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (todoId: number) => {
      await apiClient.delete(`/todos/${todoId}`)
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos', listId] }),
  })
}
```

- [ ] **Step 2: Create `src/features/todos/FilterBar.tsx`**

```tsx
import type { Priority, Status } from '../../api/types'

interface Props {
  priority: Priority | ''
  status: Status | ''
  onPriorityChange: (v: Priority | '') => void
  onStatusChange: (v: Status | '') => void
}

const selectStyle = { padding: '4px 8px', borderRadius: 4, border: '1px solid #d1d5db', fontSize: 13 }

export function FilterBar({ priority, status, onPriorityChange, onStatusChange }: Props) {
  return (
    <div style={{ display: 'flex', gap: 12, marginBottom: 16, alignItems: 'center' }}>
      <span style={{ fontSize: 13, color: '#6b7280' }}>Filter:</span>
      <select style={selectStyle} value={priority} onChange={e => onPriorityChange(e.target.value as Priority | '')}>
        <option value="">Any priority</option>
        <option value="low">Low</option>
        <option value="medium">Medium</option>
        <option value="high">High</option>
      </select>
      <select style={selectStyle} value={status} onChange={e => onStatusChange(e.target.value as Status | '')}>
        <option value="">Any status</option>
        <option value="pending">Pending</option>
        <option value="in_progress">In Progress</option>
        <option value="done">Done</option>
      </select>
    </div>
  )
}
```

- [ ] **Step 3: Create `src/features/todos/CreateTodoModal.tsx`**

```tsx
import { useState } from 'react'
import { useCreateTodo } from './useTodos'
import type { Priority } from '../../api/types'

interface Props {
  listId: number
  onClose: () => void
}

export function CreateTodoModal({ listId, onClose }: Props) {
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [priority, setPriority] = useState<Priority>('medium')
  const [dueDate, setDueDate] = useState('')
  const createTodo = useCreateTodo(listId)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim()) return
    createTodo.mutate({
      title: title.trim(),
      description: description.trim() || null,
      priority,
      due_date: dueDate || null,
    }, { onSuccess: onClose })
  }

  const inputStyle = { display: 'block', width: '100%', marginTop: 4, padding: '6px 8px', border: '1px solid #d1d5db', borderRadius: 4, boxSizing: 'border-box' as const }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
      <form onSubmit={handleSubmit} style={{ background: 'white', borderRadius: 8, padding: 24, minWidth: 400 }}>
        <h2 style={{ margin: '0 0 16px' }}>New Todo</h2>
        <label style={{ display: 'block', marginBottom: 12 }}>
          Title
          <input value={title} onChange={e => setTitle(e.target.value)} style={inputStyle} autoFocus />
        </label>
        <label style={{ display: 'block', marginBottom: 12 }}>
          Description
          <textarea value={description} onChange={e => setDescription(e.target.value)} style={{ ...inputStyle, height: 80, resize: 'vertical' }} />
        </label>
        <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
          <label style={{ flex: 1 }}>
            Priority
            <select value={priority} onChange={e => setPriority(e.target.value as Priority)} style={{ ...inputStyle, marginTop: 4 }}>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
          </label>
          <label style={{ flex: 1 }}>
            Due date
            <input type="date" value={dueDate} onChange={e => setDueDate(e.target.value)} style={inputStyle} />
          </label>
        </div>
        <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
          <button type="button" onClick={onClose} style={{ padding: '6px 16px' }}>Cancel</button>
          <button type="submit" disabled={!title.trim()} style={{ padding: '6px 16px', background: '#3b82f6', color: 'white', border: 'none', borderRadius: 4 }}>
            Create
          </button>
        </div>
      </form>
    </div>
  )
}
```

- [ ] **Step 4: Create `src/features/todos/TodoItem.tsx`**

```tsx
import { useUpdateTodo, useDeleteTodo } from './useTodos'
import { TagBadge } from '../../components/tags/TagBadge'
import type { Todo, Status } from '../../api/types'

interface Props {
  todo: Todo
  listId: number
}

const priorityColors: Record<string, string> = {
  low: '#d1fae5',
  medium: '#fef3c7',
  high: '#fee2e2',
}

const statusLabels: Record<Status, string> = {
  pending: 'Pending',
  in_progress: 'In Progress',
  done: 'Done',
}

export function TodoItem({ todo, listId }: Props) {
  const updateTodo = useUpdateTodo(listId)
  const deleteTodo = useDeleteTodo(listId)

  const cycleStatus = () => {
    const next: Record<Status, Status> = { pending: 'in_progress', in_progress: 'done', done: 'pending' }
    updateTodo.mutate({ todoId: todo.id, data: { status: next[todo.status] } })
  }

  return (
    <div style={{
      border: '1px solid #e5e7eb',
      borderRadius: 8,
      padding: '12px 16px',
      marginBottom: 8,
      background: todo.status === 'done' ? '#f9fafb' : 'white',
      opacity: todo.status === 'done' ? 0.7 : 1,
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
            <span
              style={{ fontSize: 12, padding: '2px 8px', borderRadius: 12, background: priorityColors[todo.priority] }}
            >
              {todo.priority}
            </span>
            <span style={{ fontWeight: 500, textDecoration: todo.status === 'done' ? 'line-through' : 'none' }}>
              {todo.title}
            </span>
          </div>
          {todo.description && (
            <p style={{ margin: '0 0 4px', fontSize: 13, color: '#6b7280' }}>{todo.description}</p>
          )}
          <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
            {todo.due_date && (
              <span style={{ fontSize: 12, color: '#9ca3af' }}>Due {todo.due_date}</span>
            )}
            {/* Tags — not yet functional, stub renders nothing */}
            {todo.tags.map(tag => <TagBadge key={tag.id} tag={tag} />)}
          </div>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginLeft: 12 }}>
          <button
            onClick={cycleStatus}
            style={{ fontSize: 12, padding: '4px 10px', border: '1px solid #d1d5db', borderRadius: 4, cursor: 'pointer', background: 'white' }}
          >
            {statusLabels[todo.status]}
          </button>
          <button
            onClick={() => deleteTodo.mutate(todo.id)}
            style={{ background: 'none', border: 'none', color: '#9ca3af', cursor: 'pointer', fontSize: 18 }}
          >
            ×
          </button>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 5: Create `src/features/todos/TodoBoard.tsx`**

```tsx
import { useState } from 'react'
import { useTodos } from './useTodos'
import { TodoItem } from './TodoItem'
import { FilterBar } from './FilterBar'
import { CreateTodoModal } from './CreateTodoModal'
import { TagFilter } from '../../components/tags/TagFilter'
import type { Priority, Status } from '../../api/types'

interface Props {
  listId: number
}

export function TodoBoard({ listId }: Props) {
  const [priority, setPriority] = useState<Priority | ''>('')
  const [status, setStatus] = useState<Status | ''>('')
  const [showModal, setShowModal] = useState(false)

  const filters = {
    ...(priority ? { priority } : {}),
    ...(status ? { status } : {}),
  }

  const { data: todos, isLoading } = useTodos(listId, filters)

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
        <h1 style={{ margin: 0, fontSize: 20 }}>Todos</h1>
        <button
          onClick={() => setShowModal(true)}
          style={{ background: '#3b82f6', color: 'white', border: 'none', borderRadius: 6, padding: '8px 16px', cursor: 'pointer' }}
        >
          + New Todo
        </button>
      </div>

      <FilterBar
        priority={priority}
        status={status}
        onPriorityChange={setPriority}
        onStatusChange={setStatus}
      />

      {/* TagFilter stub — visible but non-functional */}
      <TagFilter />

      {isLoading && <p style={{ color: '#9ca3af' }}>Loading…</p>}
      {todos?.length === 0 && !isLoading && (
        <p style={{ color: '#9ca3af' }}>No todos yet. Create one above.</p>
      )}
      {todos?.map(todo => <TodoItem key={todo.id} todo={todo} listId={listId} />)}

      {showModal && <CreateTodoModal listId={listId} onClose={() => setShowModal(false)} />}
    </div>
  )
}
```

- [ ] **Step 6: Commit**

```bash
cd ~/Projects/todo-frontend
git add .
git commit -m "feat: todos board with filter, create, update status, delete"
```

---

## Task 10: Frontend tags stubs

**Files:**
- Create: `~/Projects/todo-frontend/src/components/tags/TagBadge.tsx`
- Create: `~/Projects/todo-frontend/src/components/tags/TagFilter.tsx`
- Create: `~/Projects/todo-frontend/CLAUDE.md`

- [ ] **Step 1: Create `src/components/tags/TagBadge.tsx`** — renders nothing, visible stub

```tsx
import type { Tag } from '../../api/types'

interface Props {
  tag: Tag
}

// TODO: Implement TagBadge as part of the add-tags feature.
// See specs/add-tags/ in todo-meta for the implementation spec.
// When complete, this should render a colored pill badge with the tag name.
export function TagBadge(_props: Props) {
  return null
}
```

- [ ] **Step 2: Create `src/components/tags/TagFilter.tsx`** — renders placeholder, visible but non-functional

```tsx
// TODO: Implement TagFilter as part of the add-tags feature.
// See specs/add-tags/ in todo-meta for the implementation spec.
// When complete, this should render a row of tag pills that filter the todo list.
export function TagFilter() {
  return (
    <div
      style={{
        padding: '8px 12px',
        marginBottom: 12,
        border: '1px dashed #d1d5db',
        borderRadius: 6,
        color: '#9ca3af',
        fontSize: 13,
      }}
    >
      Tags filter — not yet implemented
    </div>
  )
}
```

- [ ] **Step 3: Create `CLAUDE.md`**

```markdown
# todo-frontend

React SPA for the Todo App, built with Vite and TypeScript.

## Stack

- **React** 18
- **Vite** — build tool and dev server (port 3000)
- **TypeScript**
- **TanStack Query** (React Query v5) — all server state management
- **axios** — HTTP client

## Running locally

Requires the backend running on :8000 (use `todo-infra` or `make dev` in `todo-backend`):

```bash
npm install
npm run dev
```

The Vite dev server proxies `/api/*` → `http://localhost:8000/*`.

## State management

- **Server state** (todos, lists): TanStack Query — never use `useState` for data that comes from the API
- **Local UI state** (modals open, filter values): `useState` in the component that owns it

## Project structure

```
src/
  api/
    client.ts     — axios instance (baseURL: /api)
    types.ts      — TypeScript types matching todo-contracts/openapi.yaml
  features/
    lists/        — List sidebar, create modal, useLists.ts hooks
    todos/        — Todo board, item, create modal, filter bar, useTodos.ts hooks
  components/
    tags/         — Tag UI components (STUBBED — see below)
```

## Generating the API client

The types in `src/api/types.ts` are hand-written to match `todo-contracts/openapi.yaml`.
To regenerate them automatically from the spec:

```bash
npm run generate-api
```

This runs `openapi-ts` and writes to `src/api/generated/`.

## Known stubs

`src/components/tags/TagBadge.tsx` — renders `null`. Used in `TodoItem.tsx` but produces no output.
`src/components/tags/TagFilter.tsx` — renders a placeholder dashed box. Used in `TodoBoard.tsx`.

These stubs are intentional. The Tags feature is not complete:
- The `tags` array on each `Todo` is always empty (backend returns empty array)
- No API calls for tags exist in the frontend
- See `specs/add-tags/` in `todo-meta` for the full implementation spec
```

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "feat: add TagBadge and TagFilter stub components and frontend CLAUDE.md"
```

---

## Task 11: Initialize todo-infra repo

**Files:**
- Create: `~/Projects/todo-infra/docker-compose.yml`
- Create: `~/Projects/todo-infra/.env.example`
- Create: `~/Projects/todo-infra/CLAUDE.md`
- Create: `~/Projects/todo-infra/README.md`

- [ ] **Step 1: Scaffold repo**

```bash
cd ~/Projects
mkdir todo-infra && cd todo-infra
git init
```

- [ ] **Step 2: Create `docker-compose.yml`**

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-todo}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-todo}
      POSTGRES_DB: ${POSTGRES_DB:-todo}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U todo"]
      interval: 5s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ../todo-backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER:-todo}:${POSTGRES_PASSWORD:-todo}@postgres:5432/${POSTGRES_DB:-todo}
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - ../todo-backend:/app
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

  frontend:
    build:
      context: ../todo-frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      VITE_API_URL: http://localhost:8000
    depends_on:
      - backend
    volumes:
      - ../todo-frontend:/app
      - /app/node_modules

volumes:
  postgres_data:
```

- [ ] **Step 3: Create `.env.example`**

```
# Copy this to .env and fill in values before running docker compose

# PostgreSQL credentials
POSTGRES_USER=todo
POSTGRES_PASSWORD=todo
POSTGRES_DB=todo
```

- [ ] **Step 4: Create `Dockerfile` in `todo-backend`**

```bash
cat > ~/Projects/todo-backend/Dockerfile << 'EOF'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
```

- [ ] **Step 5: Create `Dockerfile` in `todo-frontend`**

```bash
cat > ~/Projects/todo-frontend/Dockerfile << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
EOF
```

- [ ] **Step 6: Create `CLAUDE.md` in `todo-infra`**

```markdown
# todo-infra

Docker Compose configuration for running the Todo App locally.

## Services

| Service    | Port | Description               |
|------------|------|---------------------------|
| `frontend` | 3000 | React/Vite SPA            |
| `backend`  | 8000 | FastAPI app               |
| `postgres` | 5432 | PostgreSQL 16 database    |

## Running everything

```bash
cp .env.example .env   # only needed once
docker compose up      # starts all 3 services
```

App will be available at http://localhost:3000.

Backend API docs at http://localhost:8000/docs (Swagger UI).

## Postgres data

The postgres volume (`postgres_data`) persists between restarts. To reset:

```bash
docker compose down -v   # removes volumes
docker compose up
```

## Running backend migrations

After starting the stack, run Alembic migrations from the backend container:

```bash
docker compose exec backend alembic upgrade head
```

Or from `todo-backend/` locally (requires Python venv):

```bash
make migrate
```
```

- [ ] **Step 7: Create `README.md`**

```markdown
# todo-infra

Infrastructure config for the Todo App. See `CLAUDE.md` for details.

**Quick start:** `cp .env.example .env && docker compose up`
```

- [ ] **Step 8: Commit**

```bash
cd ~/Projects/todo-infra
git add .
git commit -m "feat: Docker Compose stack with frontend, backend, postgres"

cd ~/Projects/todo-backend
git add Dockerfile
git commit -m "feat: add Dockerfile for containerized deployment"

cd ~/Projects/todo-frontend
git add Dockerfile
git commit -m "feat: add Dockerfile for containerized deployment"
```

---

## Task 12: Initialize todo-meta repo

**Files:**
- Create: `~/Projects/meta-repo/CLAUDE.md`
- Create: `~/Projects/meta-repo/setup.sh`
- Create: `~/Projects/meta-repo/.gitignore`
- Create: `~/Projects/meta-repo/specs/add-tags/requirements.md`
- Create: `~/Projects/meta-repo/specs/add-tags/design.md`
- Create: `~/Projects/meta-repo/specs/add-tags/tasks.md`

- [ ] **Step 1: Initialize git repo**

```bash
cd ~/Projects/meta-repo
git init
```

- [ ] **Step 2: Create `.gitignore`**

```
repos/
specs/*/repos/
.superpowers/
```

- [ ] **Step 3: Create `setup.sh`**

```bash
#!/usr/bin/env bash
# setup.sh — clone all app repos into repos/
# Run this once after cloning todo-meta, then re-run to pull latest changes.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="$SCRIPT_DIR/repos"

# Update these URLs to match where you've pushed the repos
FRONTEND_URL="${FRONTEND_URL:-https://github.com/YOUR_ORG/todo-frontend.git}"
BACKEND_URL="${BACKEND_URL:-https://github.com/YOUR_ORG/todo-backend.git}"
CONTRACTS_URL="${CONTRACTS_URL:-https://github.com/YOUR_ORG/todo-contracts.git}"
INFRA_URL="${INFRA_URL:-https://github.com/YOUR_ORG/todo-infra.git}"

clone_or_pull() {
  local name="$1"
  local url="$2"
  local dest="$REPOS_DIR/$name"

  if [ -d "$dest/.git" ]; then
    echo "  Updating $name..."
    git -C "$dest" pull --ff-only
  else
    echo "  Cloning $name..."
    git clone "$url" "$dest"
  fi
}

mkdir -p "$REPOS_DIR"
echo "Setting up Todo App repos in $REPOS_DIR..."

clone_or_pull "todo-frontend"  "$FRONTEND_URL"
clone_or_pull "todo-backend"   "$BACKEND_URL"
clone_or_pull "todo-contracts" "$CONTRACTS_URL"
clone_or_pull "todo-infra"     "$INFRA_URL"

echo ""
echo "Done. Repos available at:"
ls "$REPOS_DIR"
```

```bash
chmod +x ~/Projects/meta-repo/setup.sh
```

- [ ] **Step 4: Create `CLAUDE.md`**

```markdown
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
```

- [ ] **Step 5: Create `specs/add-tags/requirements.md`**

```bash
mkdir -p ~/Projects/meta-repo/specs/add-tags
```

```markdown
# Feature: Tags / Labels

## Summary

Users can create colored tags and attach them to individual todos. Tags make it
easy to cross-cut across lists (e.g. "urgent", "waiting-on-someone", "home").

## User stories

- As a user, I can create a tag with a name and a hex color
- As a user, I can attach one or more tags to a todo
- As a user, I can remove a tag from a todo
- As a user, I can filter the todo board to show only todos with a specific tag
- As a user, tags are displayed as colored pill badges on each todo item

## Out of scope

- Tag editing (rename, recolor) — add later
- Per-list tags — tags are global across all lists
- Tag deletion — add later (needs cascade logic)

## Acceptance criteria

1. `GET /tags` returns all tags
2. `POST /tags` creates a tag with `name` and `color`
3. `POST /todos/{todo_id}/tags/{tag_id}` attaches a tag to a todo
4. `DELETE /todos/{todo_id}/tags/{tag_id}` removes a tag from a todo
5. `GET /lists/{list_id}/todos` includes a `tags` array on each todo (previously always empty)
6. `TagBadge` renders a colored pill with the tag name
7. `TagFilter` renders a row of tag pills; clicking one filters the todo board to that tag
```

- [ ] **Step 6: Create `specs/add-tags/design.md`**

```markdown
# Tags Feature — Design

## Data model

New `tags` table:

| Column | Type | Notes |
|--------|------|-------|
| id     | integer PK | auto increment |
| name   | varchar(50) | unique |
| color  | varchar(7) | hex color e.g. "#3b82f6" |

New `todo_tags` join table (many-to-many between todos and tags):

| Column | Type | Notes |
|--------|------|-------|
| todo_id | integer FK → todos.id | |
| tag_id  | integer FK → tags.id  | |
| PK | (todo_id, tag_id) | composite |

## Alembic migration

One migration: `002_add_tags.py`
- Creates `tags` table
- Creates `todo_tags` join table
- No changes to existing `todos` table structure (the `tags` relationship is loaded via join)

## Backend changes

1. **`app/models/tag.py`** — `Tag` ORM model with a many-to-many relationship back to `Todo`
2. **`app/models/todo.py`** — add `tags` relationship via `todo_tags` secondary table
3. **`app/schemas/todo.py`** — `TagOut` already defined; `Todo.tags` already typed as `List[TagOut]`
4. **`app/routers/tags.py`** — replace 501 stubs with real implementations:
   - `GET /tags` — list all tags
   - `POST /tags` — create tag
   - `POST /todos/{todo_id}/tags/{tag_id}` — add tag to todo
   - `DELETE /todos/{todo_id}/tags/{tag_id}` — remove tag from todo
5. **`app/services/tags.py`** — new service module

## Contracts changes

In `openapi.yaml`, replace the `# TODO: implement tags endpoints` comment with the
actual endpoint definitions for the 4 tag routes.

## Frontend changes

1. **`src/api/types.ts`** — `Tag` type already defined; no changes needed
2. **`src/features/todos/useTags.ts`** — new: TanStack Query hooks for tag CRUD
3. **`src/components/tags/TagBadge.tsx`** — replace `return null` with colored pill
4. **`src/components/tags/TagFilter.tsx`** — replace placeholder with functional tag filter
5. **`src/features/todos/TodoBoard.tsx`** — wire TagFilter to filter state

## Change propagation order

1. `todo-contracts` — add endpoint definitions to openapi.yaml
2. `todo-backend` — add Tag model, migration, service, replace stub router
3. `todo-frontend` — implement TagBadge, TagFilter, useTags hooks
```

- [ ] **Step 7: Create `specs/add-tags/tasks.md`**

```markdown
# Tags Feature — Implementation Tasks

Work through these tasks in order. Commit each repo after each task.
Run `./setup.sh` first to ensure all repos are cloned to `repos/`.

## Task 1: Update todo-contracts

- [ ] In `repos/todo-contracts/openapi.yaml`, replace the `# TODO: implement tags endpoints` comment with:

```yaml
  /tags:
    get:
      summary: List all tags
      operationId: getTags
      tags: [tags]
      responses:
        "200":
          description: All tags
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: "#/components/schemas/Tag"
    post:
      summary: Create a tag
      operationId: createTag
      tags: [tags]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/TagCreate"
      responses:
        "201":
          description: Created tag
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Tag"

  /todos/{todo_id}/tags/{tag_id}:
    parameters:
      - name: todo_id
        in: path
        required: true
        schema:
          type: integer
      - name: tag_id
        in: path
        required: true
        schema:
          type: integer
    post:
      summary: Add a tag to a todo
      operationId: addTagToTodo
      tags: [tags]
      responses:
        "200":
          description: Updated todo with tag attached
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Todo"
        "404":
          description: Todo or tag not found
    delete:
      summary: Remove a tag from a todo
      operationId: removeTagFromTodo
      tags: [tags]
      responses:
        "200":
          description: Updated todo with tag removed
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Todo"
        "404":
          description: Todo or tag not found
```

- [ ] Commit: `git commit -m "feat: add tags endpoints to OpenAPI spec"`

## Task 2: Backend — Tag model and migration

- [ ] Create `repos/todo-backend/app/models/tag.py`:
  - `Tag` model with `id`, `name` (unique), `color`
  - Many-to-many to `Todo` via `todo_tags` secondary table
- [ ] Update `repos/todo-backend/app/models/todo.py`:
  - Add `tags` relationship using `todo_tags` secondary table
- [ ] Generate migration: `alembic revision --autogenerate -m "add tags"`
- [ ] Run migration: `alembic upgrade head`
- [ ] Commit: `git commit -m "feat: add Tag model and todo_tags join table migration"`

## Task 3: Backend — tags service and router

- [ ] Create `repos/todo-backend/app/services/tags.py`:
  - `get_tags(db)`, `create_tag(db, data)`, `add_tag_to_todo(db, todo_id, tag_id)`, `remove_tag_from_todo(db, todo_id, tag_id)`
- [ ] Replace `repos/todo-backend/app/routers/tags.py` stub with real implementations
- [ ] Write tests in `repos/todo-backend/tests/test_tags.py`
- [ ] Run: `pytest tests/ -v` — all pass
- [ ] Commit: `git commit -m "feat: implement tags service and router"`

## Task 4: Frontend — TagBadge and TagFilter

- [ ] Replace `repos/todo-frontend/src/components/tags/TagBadge.tsx` stub:
  - Render a colored pill: `<span style={{ background: tag.color, ... }}>{tag.name}</span>`
- [ ] Create `repos/todo-frontend/src/features/todos/useTags.ts`:
  - `useTags()` — fetch all tags
  - `useAddTagToTodo(listId)` — mutate
  - `useRemoveTagFromTodo(listId)` — mutate
- [ ] Replace `repos/todo-frontend/src/components/tags/TagFilter.tsx` stub:
  - Render tag pills; clicking one toggles a selectedTagId filter
  - Accept `onTagSelect` prop
- [ ] Update `repos/todo-frontend/src/features/todos/TodoBoard.tsx`:
  - Pass selected tag filter to `useTodos`
- [ ] Update `repos/todo-frontend/src/features/todos/useTodos.ts`:
  - Accept `tag_id` in filters, pass to API
- [ ] Commit: `git commit -m "feat: implement TagBadge, TagFilter, and tag hooks"`

## Task 5: Verify end-to-end

- [ ] Start the stack: `docker compose up` (from `todo-infra/`)
- [ ] Run backend migration in container: `docker compose exec backend alembic upgrade head`
- [ ] Open http://localhost:3000
- [ ] Create a tag via API (http://localhost:8000/docs) — e.g. `{"name": "urgent", "color": "#ef4444"}`
- [ ] Verify tag appears in TagFilter
- [ ] Add tag to a todo and verify TagBadge renders on the todo item
- [ ] Filter by tag and verify only tagged todos appear
```

- [ ] **Step 8: Initial commit for meta repo**

```bash
cd ~/Projects/meta-repo
git add .
git commit -m "feat: initialize todo-meta with CLAUDE.md, setup.sh, and add-tags spec"
```

---

## Task 13: End-to-end verification

- [ ] **Step 1: Verify all repos have commits**

```bash
for repo in todo-contracts todo-backend todo-frontend todo-infra meta-repo; do
  echo "=== $repo ==="
  git -C ~/Projects/$repo log --oneline
done
```

- [ ] **Step 2: Start the stack**

```bash
cd ~/Projects/todo-infra
cp .env.example .env
docker compose up -d
```

Expected: postgres, backend, and frontend containers start

- [ ] **Step 3: Run backend migrations**

```bash
docker compose exec backend alembic upgrade head
```

Expected: `Running upgrade  -> 001, initial schema`

- [ ] **Step 4: Smoke test the app**

Open http://localhost:3000

- Create a list → should appear in sidebar
- Select the list → should show empty todo board
- Create a todo with a priority and due date → should appear in the list
- Click the status button on a todo → should cycle through pending → in_progress → done
- The "Tags filter — not yet implemented" placeholder should be visible below the filter bar

- [ ] **Step 5: Verify tags stub is visible but non-functional**

- The `TagFilter` dashed placeholder is visible in the todo board
- `GET http://localhost:8000/tags` returns `{"detail": "Tags feature not yet implemented..."}`

- [ ] **Step 6: Verify meta repo setup**

```bash
cd ~/Projects/meta-repo
./setup.sh
```

Expected: clones (or updates) all 4 repos into `repos/`

```bash
ls repos/
# todo-frontend  todo-backend  todo-contracts  todo-infra
```

- [ ] **Step 7: Verify CLAUDE.md @-references resolve**

Open the `meta-repo` directory in Claude Code. In a new session, check that the AI mentions context from all 4 repos when asked "what repos does this project have?"

Expected: Claude responds with knowledge of all 4 repos' stacks and the CLAUDE.md details from each.

---

*Plan complete. Use `superpowers:subagent-driven-development` to execute task-by-task.*
