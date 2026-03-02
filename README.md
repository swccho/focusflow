# 📘 FocusFlow – MVP Documentation

## 1. Project Overview

**FocusFlow** is a lightweight desktop productivity application built with Flutter.
It combines a Pomodoro timer with task management to help users stay focused and track daily productivity.

The goal of the MVP is to deliver a stable, minimal, production-ready desktop app with core functionality only.

---

## 2. MVP Goals

The MVP must:

* Be stable and performant on Windows desktop
* Persist user data locally
* Provide a clean and distraction-free UI
* Support core focus workflow (task → focus → break → complete)

The MVP will NOT include advanced OS integrations (system tray, auto-start, etc.). Those are Phase 2.

---

# 3. Core Features (MVP Scope)

## 3.1 Task Management

Users can:

* Add a new task
* Mark task as completed
* Delete a task
* View all tasks
* View active tasks
* View completed tasks

### Task Model

Each task will contain:

* `id` (UUID)
* `title` (String)
* `isDone` (bool)
* `createdAt` (DateTime)
* `doneAt` (DateTime?)

---

## 3.2 Pomodoro Timer

Users can:

* Start focus session (default: 25 minutes)
* Pause timer
* Reset timer
* Automatically switch to break session (default: 5 minutes)

### Timer Modes

* Focus Mode (25 minutes)
* Break Mode (5 minutes)

The timer will:

* Display countdown
* Show current mode (Focus / Break)
* Reset properly
* Persist settings locally

---

## 3.3 Daily Statistics

For MVP:

* Display number of completed tasks today
* Display total focus sessions completed today

No charts yet (charts come later).

---

## 3.4 Local Data Persistence

The app will store:

### Tasks

Stored locally using Hive.

### Settings

* focusMinutes (default 25)
* breakMinutes (default 5)

Data must persist after app restart.

---

# 4. Architecture Plan (MVP)

We will use a **Clean Architecture (Light Version)**.

## Folder Structure

```
lib/
 ├── app/
 ├── core/
 │    ├── constants/
 │    ├── utils/
 │    └── widgets/
 ├── features/
 │    ├── tasks/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    ├── timer/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    └── stats/
 │         └── presentation/
 ├── services/
 └── main.dart
```

---

# 5. State Management

We will use:

**Riverpod**

Reasons:

* Scalable
* Clean separation
* Testable
* Modern Flutter standard

---

# 6. User Interface Guidelines

### Design Principles

* Minimal
* Clean typography
* Soft shadows
* Focused layout
* Dark mode ready
* No visual clutter

### Main Screen Layout

Home Dashboard:

```
--------------------------------
|        Timer Card            |
|   24:59  [Start] [Reset]     |
--------------------------------
|   Add Task Input             |
--------------------------------
|   Today Stats                |
--------------------------------
```

Tasks Screen:

```
[ All | Active | Done ]

☐ Task 1
☑ Task 2
☐ Task 3
```

---

# 7. Non-Functional Requirements

* Fast startup (< 2 seconds)
* No internet required
* Fully offline
* No external API dependency
* Works on Windows desktop
* Handles app restart without data loss

---

# 8. Out of Scope (Phase 2)

These are NOT included in MVP:

* System tray integration
* Windows notifications
* Auto start with Windows
* Charts & advanced analytics
* Sync across devices
* Cloud backup
* Keyboard shortcuts
* Themes customization
* Multi-language support

---

# 9. Success Criteria for MVP Completion

The MVP is considered complete when:

* Tasks persist after restart
* Timer works correctly
* Timer transitions between focus and break
* Daily stats update correctly
* App runs without crashes
* Clean UI with no major layout issues

---

# 10. Future Roadmap (After MVP)

Phase 2:

* System tray support
* Desktop notifications
* Custom focus duration
* Charts (weekly productivity)
* Keyboard shortcuts
* Export data

Phase 3:

* Cloud sync
* Multi-device support
* Account system

---

# 🎯 Final MVP Definition (One Sentence)

FocusFlow MVP is a clean, offline, desktop Pomodoro + task manager that helps users focus, complete tasks, and track daily productivity.
