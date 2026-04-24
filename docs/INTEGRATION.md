# crm-voice-app — Ilona API integration

## Endpoints

| Step | Method | Path | Auth |
|------|--------|------|------|
| Login | `POST` | `/auth/login` | Body: `email`, `password` |
| Centers | `GET` | `/admin/centers` | `Authorization: Bearer <accessToken>` |
| Upload | `POST` | `/admin/recordings` | Bearer + `multipart/form-data`: `file`, `centerId`, `durationSec` |

Resolve paths against your **API base URL** (must include the global prefix), e.g. `http://localhost:4000/api`.

## Rules

- **ADMIN only** for `/admin/centers` and `/admin/recordings`. The app rejects non-admin users immediately after login (tokens are not saved for them).
- **Do not hardcode** center ids; load the catalog from `/admin/centers` and let the user choose.
- The app always sends **`durationSec`** as a form field on upload (integer seconds, stringified in multipart).

## Verification

Use your Ilona deployment’s own API verification checklist if available; this repo does not duplicate Ilona documentation.
