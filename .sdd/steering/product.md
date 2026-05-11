# Product Overview

The Todo App is a multi-repo web application for managing todo items organized into named lists, with tagging/labeling support for cross-list categorization. It is also a demonstration of **AI-assisted development across a split-repo architecture** using Claude Code.

This `todo-meta` repo is the **AI context layer**: a coordination hub that aggregates context from all four app repos so an AI can work on cross-repo features in a single session.

## Core Capabilities

- **Todo Lists**: Create and manage named collections of todo items
- **Todo Items**: Create, complete, and organize individual tasks within lists
- **Tags / Labels**: Create colored tags and attach them to todos for cross-list filtering (in progress)
- **Filtering**: Filter the todo board by tag

## Target Use Cases

- Developers demonstrating AI-assisted cross-repo feature development
- Teams using Claude Code to plan and implement features that span multiple services
- Workflows where an AI needs full-stack context (frontend + backend + contracts + infra) at once

## Value Proposition

The meta-repo pattern eliminates context-switching: the AI reads all four `CLAUDE.md` files and specs simultaneously, enabling end-to-end feature implementation without losing context between repos.

---
_Focus on patterns and purpose, not exhaustive feature lists_
