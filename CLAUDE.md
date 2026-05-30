# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`graduation_research_management` — a Flutter app for the **supervisor** side of a graduation-research management platform. UI is Arabic and RTL throughout (the root `MaterialApp` forces `TextDirection.rtl`). Supervisors view assigned research groups, give feedback, enter grades, chat, and manage project stages/files.

## Commands

- Install deps: `flutter pub get`
- Run (choose a device): `flutter run -d chrome` (web) / `flutter run -d windows` (desktop) / `flutter run`
- Static analysis / lint: `flutter analyze`  (lints come from `flutter_lints` via `analysis_options.yaml`)
- Format: `dart format lib`
- Tests: `flutter test`  — single file: `flutter test test/<file>_test.dart`  — single case: `flutter test --plain-name "<test name>"`

## Mock Data Mode (important)

The app currently runs WITHOUT a live backend:
- `lib/main.dart` has `Supabase.initialize` and `dotenv.load` commented out; it boots straight into mock mode.
- Every method in `lib/services/supabase_service.dart` returns data from `lib/constants/mock_data.dart`, with the equivalent real Supabase query preserved as a comment block directly below it.
- To enable the real backend: uncomment the init block in `main.dart`, populate `.env` (`SUPABASE_URL`, `SUPABASE_ANON_KEY` — see `.env.example`), and uncomment the query bodies in `supabase_service.dart`. Do not rewrite these from scratch — the queries already exist commented out.

## Architecture (MVC)

Data flows: **Models → SupabaseService → Repositories → Controllers → Views**

- `lib/models/` — plain data classes with `fromJson`/`toJson`. Import via the barrel `models/models.dart` (`import '../models/models.dart';`), not individual files.
- `lib/services/supabase_service.dart` — single static service; the only place that talks to Supabase (or mock data). All `static Future<...>` methods.
- `lib/repositories/` — `ProjectRepository` (interface) + `ProjectRepositoryImpl` thinly wrap `SupabaseService`; some methods also call `Supabase.instance.client` directly.
- `lib/controllers/` — `ChangeNotifier` classes holding view state + loading flags, calling `SupabaseService`. Supervisor-specific controllers live in `lib/controllers/supervisor/`.
- `lib/views/` — `StatefulWidget` screens. **State is wired manually**: a view creates its controller in `initState` and calls `_controller.addListener(() => setState((){}))`. The `provider` package is NOT a dependency — do not add `Provider`/`Consumer`; follow the existing addListener+setState pattern.
- `lib/views/widgets/desktop_layout.dart` — shared nav shell (sidebar + selected index) wrapping the main supervisor screens.
- `lib/constants/` — `supervisor_constants.dart` (statuses, comment/notification types, sizing, Arabic UI strings) and `mock_data.dart`.

Entry point: `main.dart` → `views/login_view.dart` (`LoginView`) → on success `Navigator.pushReplacement` to `DashboardView`.

### Dead / legacy code — do not edit by mistake
- `lib/screens/` — older pre-MVC screens; nothing in the active path imports them.
- `lib/providers/supervisor_provider.dart` (`SupervisorProvider`) — not wired into the app.
- Root-level `supervisor_constants.dart` duplicates `lib/constants/supervisor_constants.dart`; the one under `lib/constants/` is the one in use.

When adding a feature, mirror the existing slice: model (in `models/`, re-exported from `models.dart`) → method in `SupabaseService` (mock return + commented real query) → `ChangeNotifier` controller in `controllers/supervisor/` → `StatefulWidget` view in `views/supervisor/` using addListener+setState, surfaced through `DesktopLayout`.

## Conventions
- New backend methods should keep the Mock-Data-Mode shape: return mock data now, leave the real Supabase query as a comment beneath.
- Strings/labels are Arabic; keep new user-facing text Arabic and RTL-safe.
