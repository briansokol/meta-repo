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
