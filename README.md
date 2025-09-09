Globex Monorepo

Overview
- Monorepo with three apps and infra:
  - backend: FastAPI service (auth demo, JWT)
  - frontend: React (CRA + TypeScript)
  - b2b_marketplace_app: Flutter multi‑platform app
  - docker-compose: local dev stack (frontend, backend, Postgres, nginx)

Prerequisites
- Docker and Docker Compose
- Node.js 18 LTS (use .nvmrc in frontend)
- Python 3.11+
- Flutter SDK (if running the Flutter app)

Quick Start (Docker)
1) First run:
   - Ensure ssl/ exists (self-signed or bring your certs). See ssl/README.md
   - Ensure backend/init.sql exists (basic schema placeholder provided)
2) Start services:
   - docker compose up --build
3) Services:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:8000
   - Nginx (reverse proxy): http://localhost, https://localhost

Local Run (without Docker)
Backend
  cd backend
  python -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  export SECRET_KEY="dev-secret"
  uvicorn main:app --reload --host 0.0.0.0 --port 8000

Frontend
  cd frontend
  nvm use || echo "Use Node 18 LTS"
  npm install
  REACT_APP_API_URL=http://localhost:8000 npm start

Flutter
  cd b2b_marketplace_app
  flutter pub get
  flutter run

Configuration
- Frontend: frontend/.env (see .env.example)
- Backend: environment variables (see backend/.env.example)
- Database: docker-compose uses Postgres with volume and optional init.sql

Testing
- Frontend: npm test
- Backend: pytest (install pytest if needed)
- Flutter: flutter test

Notes
- docker-compose mounts frontend/nginx.conf to nginx container
- Keep secrets out of VCS; use environment variables

