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

## Live Backend Mode (important)

The app runs against a **live Supabase backend** (it no longer uses mock data):
- `lib/main.dart` calls `dotenv.load(".env")` then `Supabase.initialize(...)` at startup.
- `.env` must define `SUPABASE_URL` and `SUPABASE_ANON_KEY` (see `.env.example`). Without it, init fails and every query throws.
- Every method in `lib/services/supabase_service.dart` is a real `Supabase.instance.client` query. `lib/constants/mock_data.dart` has been deleted — do not reintroduce mock returns.
- Schema note: several table names contain spaces/parentheses and must be quoted in `.from(...)`: `'first stage'`, `'third stage(discussion)'`, `'fourth stage'`, `'fifth_Stage'`, `'Title of second stage'`, `'stages statues'`. These work via `client.from('first stage')`.
- Inspecting the schema/data: the Supabase MCP is available (project ref `quakwoghhxoobcgcknsj`) — use `list_tables` / `execute_sql` for read-back verification.

## Architecture (MVC)

Data flows: **Models → SupabaseService → Repositories → Controllers → Views**

- `lib/models/` — plain data classes with `fromJson`/`toJson`. Import via the barrel `models/models.dart` (`import '../models/models.dart';`), not individual files.
- `lib/services/supabase_service.dart` — single static service; the only place that talks to Supabase. All `static Future<...>` methods. Tables that may have no row yet for a group (e.g. per-stage tables, `stages statues`) use a **read-then-insert-or-update (upsert) pattern** on writes so the first save creates the row.
- `lib/repositories/` — `ProjectRepository` (interface) + `ProjectRepositoryImpl` thinly wrap `SupabaseService`; some methods also call `Supabase.instance.client` directly.
- `lib/controllers/` — `ChangeNotifier` classes holding view state + loading flags, calling `SupabaseService`. Supervisor-specific controllers live in `lib/controllers/supervisor/`.
- `lib/views/` — `StatefulWidget` screens. **State is wired manually**: a view creates its controller in `initState` and calls `_controller.addListener(() => setState((){}))`. The `provider` package is NOT a dependency — do not add `Provider`/`Consumer`; follow the existing addListener+setState pattern.
- `lib/views/widgets/desktop_layout.dart` — shared nav shell (sidebar + selected index) wrapping the main supervisor screens.
- `lib/constants/` — `supervisor_constants.dart` (statuses, comment/notification types, sizing, Arabic UI strings).

Entry point: `main.dart` → `views/login_view.dart` (`LoginView`) → on success `Navigator.pushReplacement` to `DashboardView`.

### Identity propagation (`supervisorId`) — must-follow
There is no global session/auth store: the logged-in supervisor's identity is **threaded manually** through every screen via constructor args (`supervisorId` + `supervisorName`). When adding/navigating screens, always forward the real id. Two rules to avoid silently breaking data loads:
- Every view that wraps `DesktopLayout` must pass `supervisorId` (and `supervisorName`), and every `Navigator.push`/`pushReplacement` to another supervisor screen must forward them. `DesktopLayout`'s sidebar (`_onSidebarItemSelected`) is the hub — keep all cases passing the id (Dashboard included).
- **Do not** rely on `?? 0` / `?? 1` fallbacks as the real value — a wrong/zero `id_sprvsr` returns an empty list (HTTP 200, no error) and surfaces as "لا يوجد مشاريع". `DashboardView` accepts `supervisor` OR `supervisorId`/`supervisorName` so the id survives the round-trip back to the dashboard.

### Stage details screen (`views/supervisor/stage_details_view.dart`)
`ProjectDetailsView` → tap a stage → `StageDetailsView`. The screen shows different content per stage, keyed to the **stage's real number** parsed from `stage.name` (e.g. "مرحلة 2: …" → 2) via `_parseStageNumber` — NOT the stage's position in the list (an earlier bug). Stages without a content branch fall back to `_buildUnknownStageContent`. The supervisor's role ends at stage 5: **stages 6 and 7 are hidden** — `getProjectStages` filters out any stage whose parsed number > 5, so the timeline and "X من Y" counts only ever show 1–5. Data + write-back are handled by `StageDetailsController` + per-stage `SupabaseService` methods, with these table mappings:
- Stage 1 → `first stage` (`research_title`, `research_description`, `sprvsr_approval`) + `student` rows (leader = `groups.group_led_id`).
- Stage 2 → `stage2_titles_approval` (`pdf_file`, `stage_approval`, `sprvsr_note`) + checklist items from `Title of second stage`. "يحتاج تعديل" appends a line `العنوان: الملاحظة` to `sprvsr_note`. Per-item approval is local-only (no per-title column exists).
- Stage 3 → `third stage(discussion)` (`discussion_percent`, `discus_date`, `discussion_state`, `sprvsr_note`).
- Stage 4 → `fourth stage` (`stage4_pdf`, `approval`, `sprvsr_notes`). Review document + approve/reject + note only — **no percentage** (no stage-4 percentage in the UI or DB).
- Stage 5 → seven fixed sections (الفصول + الملحق + المراجع) from `fifth stage titles` (`title_id`, `title_name`), each with its own row in `fifth_Stage` keyed by `(group_id, title_id)` (`pdf_file`, `approval`, `sprvsr_note`). The supervisor approves/requests-edit + notes **per section** (`updateStage5Section` upsert). The stage progress % is **computed read-only** = approved sections ÷ total sections (not entered, not stored). Sections without an uploaded file still render (approval buttons disabled).

Stage info models live in `lib/models/stage_info.dart` (`Stage1Info`..`Stage4Info`, `Stage5Section`, exported from `models.dart`).

### Realtime
The app uses Supabase realtime in two places (tables enabled in the `supabase_realtime` publication):
- **Chats** — `ChatsController` subscribes to `SupabaseService.getMessagesStream(chatId)` for the selected chat; new messages render live. The subscription is re-created on `selectChat` and after a chat row is lazily created in `sendMessage`, and cancelled in `dispose`. Supervisor messages are inserted with `message_status='sent'`; `ChatMessage.status` carries the `message_status` column and the bubble shows a read-receipt tick (✓ sent / ✓✓ delivered grey / ✓✓ read blue) on the supervisor's own messages only — the student app drives the delivered/read transitions, reflected live via the stream.
- **Stage details** — `StageDetailsController.startRealtime()` calls `SupabaseService.subscribeStage(stageNumber, groupId, refreshStageData)`, subscribing to that stage's table filtered by group (`subscribeStage` maps stage → table/group-column). On a change it calls `refreshStageData()` (re-fetch without flipping the loading flag), and the channel is removed in `dispose`. Realtime-enabled tables: `messages`, `groups`, `first stage`, `stage2_titles_approval`, `third stage(discussion)`, `fourth stage`, `fifth_Stage`, `fifth stage titles`.

### Dead / legacy code — do not edit by mistake
- `lib/screens/` — older pre-MVC screens; nothing in the active path imports them.
- `lib/providers/supervisor_provider.dart` (`SupervisorProvider`) — not wired into the app.
- Root-level `supervisor_constants.dart` duplicates `lib/constants/supervisor_constants.dart`; the one under `lib/constants/` is the one in use.

When adding a feature, mirror the existing slice: model (in `models/`, re-exported from `models.dart`) → real Supabase query method in `SupabaseService` → `ChangeNotifier` controller in `controllers/supervisor/` → `StatefulWidget` view in `views/supervisor/` using addListener+setState, surfaced through `DesktopLayout`.

## Conventions
- New backend methods are real Supabase queries; for tables that may lack a row per group, follow the read-then-insert-or-update (upsert) pattern.
- Strings/labels are Arabic; keep new user-facing text Arabic and RTL-safe.
- `package:intl` exports its own `TextDirection` that collides with Flutter's — import it as `import 'package:intl/intl.dart' hide TextDirection;` in files that also use `TextDirection.rtl`.
