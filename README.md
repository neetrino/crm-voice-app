# crm-voice-app

Minimal Flutter client for **Ilona** administrators: sign in, pick an **active center** from the API, record a short voice note, and upload it so the backend creates a **NEW** CRM card with source **VOICE_APP**.

This repository is **client-only**. It does not ship a backend, database, local CRM board, or mock API.

## Main backend

The API lives in the separate **ilona** project (`C:\AI\ilona`). Do not expect this app to run without that API (or a compatible deployment).

## Endpoints used

| Step | Method | Path | Notes |
|------|--------|------|--------|
| Login | `POST` | `/auth/login` | JSON body: `email`, `password` |
| Centers | `GET` | `/admin/centers` | Bearer **ADMIN** access token |
| Upload | `POST` | `/admin/recordings` | Bearer token; multipart: `file`, `centerId`, `durationSec` |

All paths are resolved against your **API base URL** (must include the `/api` prefix), e.g. `http://localhost:4000/api`.

## Configuration

- **API base URL:** `dart-define` `API_BASE_URL` (see below). The default in code matches the **Android emulator** mapping to the host machine (`10.0.2.2`).
- **Credentials:** never hardcoded or stored in the repo. The user types email and password on each sign-in. Tokens are stored with **flutter_secure_storage** only.

### Local manual testing account (Ilona dev)

For **local manual testing** on a trusted machine you may use the Ilona dev **ADMIN** account (example): `admin@ilona.edu` / `admin123`. This is **not** embedded in the app and must not be committed as secrets.

## Run

From this directory, with the Ilona API listening on port **4000**:

**Android emulator** (host machine reachable as `10.0.2.2`):

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

**Windows / desktop** (API on the same machine):

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:4000/api
```

**Physical device** (same LAN as the PC running the API):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:4000/api
```

Replace `192.168.x.x` with your computer’s LAN IP.

## First-time / platform scaffolding

If `android/`, `ios/`, or Gradle wrapper files are incomplete, run once from the repo root:

```bash
flutter create .
```

Then re-apply any local edits if prompted, and ensure **microphone** permissions remain configured:

- Android: `android/app/src/main/AndroidManifest.xml` includes `RECORD_AUDIO` (and cleartext is enabled for **HTTP dev** only as in this template).
- iOS: `ios/Runner/Info.plist` includes `NSMicrophoneUsageDescription` with: *This app needs microphone access to record voice notes.*

## Centers and upload behavior

- Centers are loaded live from `GET /admin/centers` (no hardcoded list).
- Upload sends only `file`, `centerId`, and `durationSec`. The backend creates the CRM card (status **NEW**, source **VOICE_APP**) and attachment.

## Integration summary

See [docs/INTEGRATION.md](docs/INTEGRATION.md) for a short endpoint overview.

## Analyze / format

```bash
flutter pub get
dart format .
flutter analyze
```
