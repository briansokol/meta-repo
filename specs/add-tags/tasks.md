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
  - Render a colored pill: `<span style={{ background: tag.color, color: 'white', fontSize: 11, padding: '1px 8px', borderRadius: 8 }}>{tag.name}</span>`
- [ ] Create `repos/todo-frontend/src/features/todos/useTags.ts`:
  - `useTags()` — fetch all tags
  - `useAddTagToTodo(listId)` — mutate
  - `useRemoveTagFromTodo(listId)` — mutate
- [ ] Replace `repos/todo-frontend/src/components/tags/TagFilter.tsx` stub:
  - Fetch tags via `useTags()`
  - Render tag pills; clicking one toggles selectedTagId
  - Accept `selectedTagId: number | null` and `onTagSelect: (id: number | null) => void` props
- [ ] Update `repos/todo-frontend/src/features/todos/TodoBoard.tsx`:
  - Add `selectedTagId` state, pass to `TagFilter` and `useTodos` filters
- [ ] Update `repos/todo-frontend/src/features/todos/useTodos.ts`:
  - Accept `tag_id` in `TodoFilters`, pass as query param
- [ ] Commit: `git commit -m "feat: implement TagBadge, TagFilter, and tag hooks"`

## Task 5: Verify end-to-end

- [ ] Start the stack: `docker compose up` (from `todo-infra/`)
- [ ] Run backend migration in container: `docker compose exec backend alembic upgrade head`
- [ ] Open http://localhost:3000
- [ ] Create a tag via API (http://localhost:8000/docs) — e.g. `{"name": "urgent", "color": "#ef4444"}`
- [ ] Verify tag appears in TagFilter
- [ ] Add tag to a todo and verify TagBadge renders on the todo item
- [ ] Filter by tag and verify only tagged todos appear
