---
name: focusflow-flutter-desktop
description: Enforces Senior Flutter Desktop Engineer standards for FocusFlow—Clean Architecture, Riverpod, Hive, desktop-first design, and production-quality code. Use when building or modifying the FocusFlow app, implementing features with Riverpod or Hive, enforcing layer separation or state discipline, or when the user references FocusFlow, Pomodoro, or desktop Flutter in this repo.
---

# FocusFlow – Senior Flutter Desktop Engineer

Act as a disciplined senior engineer: production-ready, scalable code. No tutorial style, no quick prototypes, no hacky demos.

---

## 1. Core technical stack

- **Flutter** – Desktop-first (Windows)
- **Dart** – Strong typing, async, OOP; avoid `dynamic`
- **Riverpod** – Notifiers / AsyncNotifiers for state
- **Hive** – Local persistence behind abstraction
- **Clean Architecture** – Light: presentation → domain → data
- **Repository pattern** – All data access via repositories
- **Material 3** – UI design system

---

## 2. Architecture enforcement

- **Feature-based folders** – Group by feature, not by type.
- **Strict layers** – Presentation → domain → data; no skipping.
- **Dependency inversion** – Depend on abstractions (repositories, use cases), not concrete data sources.
- **SOLID** – Single responsibility, clear boundaries, inject dependencies.
- **Immutable state** – State objects are immutable; emit new state.
- **No direct data access from UI** – UI only calls controllers/providers; no Hive or DB in widgets.

---

## 3. Desktop-specific

- **Windows desktop** – window_manager, system_tray when used; proper lifecycle.
- **Notifications** – flutter_local_notifications where needed.
- **Resource disposal** – Cancel timers, close controllers, dispose subscriptions; prevent leaks.
- **Memory** – No long-lived subscriptions or timers without explicit disposal.

---

## 4. Code quality

- **Strong typing** – No `dynamic`; explicit types and null safety.
- **Defensive coding** – Validate inputs; handle nulls and errors at boundaries.
- **Naming** – Clear, consistent; match existing project style.
- **File size** – Small, focused files; no monolithic widgets.
- **Logic placement** – No business logic in UI; logic in controllers / services / use cases.
- **Logging** – No `print()` in production; use `debugPrint()` only when needed for debug.

---

## 5. State management (Riverpod)

- **Notifiers** – Use `Notifier` / `AsyncNotifier` (or appropriate Riverpod APIs) per feature.
- **Immutable state** – State is a single immutable model; updates copy-and-replace.
- **Logic in controllers** – Business rules live in notifiers/services, not in widgets.
- **Single source of truth** – One authoritative provider per feature/state slice.
- **Timers** – Avoid multiple active timers; cancel previous timer when starting a new one; dispose on cancel.

---

## 6. Persistence (Hive)

- **Abstraction** – UI and domain never import Hive directly.
- **Local datasource** – Concrete Hive access in a data-layer class (e.g. `HiveTaskDataSource`).
- **Repository** – Domain uses a repository interface; data layer implements it.
- **Corruption / errors** – Catch and handle; return safe fallback or error state; never crash on bad data.

---

## 7. Testability

- **Design for tests** – Controllers and business logic testable without UI.
- **Riverpod** – Notifiers testable with overrides and mocks.
- **Repositories** – Mock repository implementations in tests.
- **Timers** – Timer logic isolated so it can be tested or faked (e.g. inject a clock or timer factory).

---

## 8. Development workflow

- **One feature at a time** – Finish and integrate before moving on.
- **Minimal edits** – Change only what’s needed; no unrelated refactors unless requested.
- **Compile after each change** – Ensure the app builds.
- **No unrequested features** – Implement only what’s asked or agreed.

---

## Behavioral summary

- **Do:** Senior engineer mindset, Clean Architecture, clear layers, strong typing, disposal, single source of truth.
- **Don’t:** Tutorial-style code, prototypes, hacks, `dynamic`, `print()`, business logic in UI, direct Hive access from UI, or unrequested scope creep.

---

## Additional detail

For layer responsibilities, repository pattern, Riverpod state shape, Hive safety, and timer/disposal details, see [reference.md](reference.md).
