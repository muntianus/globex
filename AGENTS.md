# Repository Guidelines

## Project Structure & Module Organization
- `backend/` — FastAPI service, SQL schema and seeds, API tests.
- `frontend/` — React + TypeScript app with component tests.
- `b2b_marketplace_app/` — Flutter app (mobile/web/desktop) with Dart tests.
- `docker-compose.yml` — Local full‑stack environment (frontend, backend, db, nginx).
- `ssl/` — Local SSL materials for nginx; do not commit real secrets.

## Build, Test, and Development Commands
- Root (Docker): `docker compose up --build` — start all services with hot reload.
- Backend:
  - Dev: `cd backend && uvicorn main:app --reload` (requires `pip install -r requirements.txt`).
  - Test: `cd backend && pytest -q` (if pytest installed).
- Frontend:
  - Dev: `cd frontend && npm install && npm start`.
  - Test: `cd frontend && npm test`.
- Flutter app:
  - Dev: `cd b2b_marketplace_app && flutter pub get && flutter run`.
  - Test/Analyze: `flutter test`, `flutter analyze`.

## Coding Style & Naming Conventions
- Python (backend): PEP 8, 4‑space indent, type hints; modules `snake_case.py`, functions/vars `snake_case`, classes `PascalCase`.
- React/TS (frontend): components `PascalCase.tsx`, hooks `useX.ts`, functions/vars `camelCase`. ESLint extends `react-app`.
- Dart/Flutter: follow `very_good_analysis`; files `snake_case.dart`, classes `PascalCase`.
- Keep endpoints, DTOs, and models documented where defined; prefer small, focused modules.

## Testing Guidelines
- Backend: API tests live beside service in `backend/` (e.g., `test_*.py`); target FastAPI routes and auth flows; aim for critical path coverage.
- Frontend: place tests under `src/components/__tests__/` or next to components as `*.test.tsx`.
- Flutter: tests in `b2b_marketplace_app/test/`; include widget and provider tests; keep golden files deterministic.

## Commit & Pull Request Guidelines
- Commits: imperative mood with scope prefix, e.g., `backend: add JWT expiry`, `frontend: fix auth modal`, `flutter: refactor provider`.
- PRs: clear description, linked issue, steps to verify, screenshots for UI, and notes on migrations or env changes. Ensure CI/tests pass locally.

## Security & Configuration Tips
- Use the provided samples: `backend/env.example`, `frontend/env.example`. Do not commit real `.env` or secrets.
- Backend env: `DATABASE_URL`, `SECRET_KEY`; Frontend env: `REACT_APP_API_URL`.
- For local HTTPS via nginx, place dev certs in `ssl/` only.

## Agent‑Specific Notes
- Keep changes minimal and scoped; avoid renames or broad refactors.
- Follow existing structure and naming; update docs/tests when altering APIs.
