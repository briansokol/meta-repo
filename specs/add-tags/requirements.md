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
