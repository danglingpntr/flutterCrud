## Task Manager Architecture

### Layers
- **Bootstrap (`lib/main.dart`)** loads the `.env` file, initializes Parse, and decides whether to show the auth flow or the task experience based on the cached session.
- **Core (`lib/core/`)** exposes shared utilities (theme, validators, Parse config loader).
- **Features**
  - `auth/` contains UI + controllers for login, registration, and logout.
  - `tasks/` contains UI + controllers for the task list and editor surfaces.
- **Services (`lib/services/`)** wrap Parse SDK access for authentication, CRUD, and LiveQuery subscriptions. UI never touches Parse objects directly.
- **Models (`lib/models/`)** define immutable entities (`Task`) that convert from/to Parse objects.

### Parse Initialization
```text
main.dart
 ├─ loadEnv()
 ├─ Parse.initialize(appId, serverUrl,
 │    clientKey: ..., liveQueryUrl: ...,
 │    autoSendSessionId: true)
 └─ runApp(AppBootstrap(initialUser))
```
`autoSendSessionId` keeps the user signed in. `ParseUser.currentUser()` supplies the cached user for the splash gate.

### Authentication Flow
1. `LoginScreen` validates a school email (`*.edu` constraint by default) and password.
2. `AuthController` delegates to `AuthService` which wraps `ParseUser.login`/`signUp`.
3. Errors are surfaced via `AsyncValue<AuthState>` (implemented with `ChangeNotifier`).
4. Logout calls `ParseUser.logout()` and clears the cached user.

### Task Flow & Real‑Time Sync
1. `TaskService` performs CRUD via the `ParseObject('Task')` class; each task stores `owner` (Parse pointer), `title`, `description`, `isCompleted`.
2. `TaskLiveQuery` subscribes to the authenticated user’s tasks and streams inserts/updates/deletes to the UI.
3. `TaskController` merges snapshots from LiveQuery with optimistic updates so the UI responds immediately.
4. `TaskListScreen` and `TaskComposerSheet` use `ChangeNotifierProvider` for state.

### Offline & Error Handling
- Parse SDK caches the session and retries failed requests automatically.
- Each controller exposes `loading`, `error`, and `data` properties so the UI can show SnackBars/spinners inline.

### Configuration & Secrets
- `.env` (ignored) stores Parse credentials copied from Back4App.
- `.env.example` documents the expected keys.
- `flutter_dotenv` loads the values at runtime; missing configuration throws a friendly error before Parse initialization.

### Testing Strategy
- Widget tests cover auth validation and task list rendering with fake services.
- Service classes are easily mockable because controllers depend on interfaces, enabling future unit tests against Parse without network calls.

