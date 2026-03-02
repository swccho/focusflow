# FocusFlow – Reference (detailed)

Use this file when you need more detail on architecture or patterns. Main instructions are in [SKILL.md](SKILL.md).

---

## Layer responsibilities

| Layer        | Contains                          | Does NOT contain                    |
|-------------|------------------------------------|-------------------------------------|
| Presentation| Pages, widgets, Riverpod providers | Business rules, Hive, HTTP         |
| Domain      | Entities, repository interfaces    | UI, Hive, platform APIs             |
| Data        | Repositories impl, datasources     | UI, widget logic                    |

---

## Repository pattern (FocusFlow)

- **Interface** in domain: e.g. `TaskRepository` with `getTasks()`, `addTask()`, etc.
- **Implementation** in data: e.g. `HiveTaskRepository` that uses `HiveTaskDataSource`.
- **Provider** wires the implementation (e.g. in app setup or a provider that returns `HiveTaskRepository`).

---

## Riverpod state shape

- One state class per feature (e.g. `TimerState`, `TaskListState`).
- State is immutable; notifier uses `state = newState` (copy with changes).
- Async work: use `AsyncNotifier` or `FutureProvider` where appropriate; expose loading/error in state or via `AsyncValue`.

---

## Hive safety

- Wrap box open/read/write in try/catch.
- On corruption: return empty list or default, or a Result type; never let exception reach UI unhandled.
- Prefer type adapters and clear keys; avoid dynamic keys from user input without validation.

---

## Timer / disposal checklist

- Single active timer per logical timer (e.g. one Pomodoro countdown).
- On start: cancel previous timer if any, then start new one.
- On dispose/cancel: cancel timer and null out reference.
- In tests: inject a way to fake or advance time so timer logic is testable.
