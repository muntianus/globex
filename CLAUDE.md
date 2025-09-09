# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a multi-platform B2B marketplace monorepo containing three main applications:

1. **frontend/** - React 19 + TypeScript web application with Bootstrap 5 styling
2. **backend/** - FastAPI Python service with JWT authentication and mock data
3. **b2b_marketplace_app/** - Flutter cross-platform mobile/desktop application

## Build and Development Commands

### Full Stack Development (Recommended)
```bash
# Start all services with Docker Compose
docker compose up --build

# Services will be available at:
# - Frontend: http://localhost:3000
# - Backend API: http://localhost:8000
# - API Docs: http://localhost:8000/docs
# - Nginx Proxy: http://localhost (HTTP), https://localhost (HTTPS)
# - PostgreSQL: localhost:5432
```

### Frontend Development (React 19 + TypeScript)
```bash
cd frontend
npm install                # Install dependencies
npm start                  # Start development server
npm run build             # Build for production (includes TypeScript compilation)
npm test                  # Run Jest + React Testing Library tests

# Environment: Node.js 18 LTS (see .nvmrc)
# Frontend connects to backend via REACT_APP_API_URL environment variable
```

### Backend Development (FastAPI + Python)
```bash
cd backend
python -m venv .venv && source .venv/bin/activate  # Create/activate virtual environment
pip install -r requirements.txt                    # Install: fastapi, uvicorn, passlib[bcrypt], python-jose[cryptography], python-multipart
export SECRET_KEY="dev-secret-key"                 # Set JWT signing key
uvicorn main:app --reload --host 0.0.0.0 --port 8000  # Start development server

# Testing
pip install pytest
pytest                     # Run backend tests
pytest test_main.py        # Run specific test file
```

### Flutter Mobile/Desktop App
```bash
cd b2b_marketplace_app
flutter pub get           # Install dependencies
flutter test             # Run unit tests
flutter run              # Run on connected device/emulator

# Key dependencies: go_router, hooks_riverpod, flutter_hooks, freezed
```

## Architecture

### Backend Architecture (FastAPI)
- **Authentication**: JWT-based with OAuth2PasswordBearer flow
- **Password Security**: bcrypt hashing via passlib
- **Data Layer**: Currently uses mock in-memory data (`fake_users_db`)
- **API Structure**: RESTful endpoints with Pydantic models for request/response validation
- **Key Models**: `User`, `UserInDB`, `Token`, `TokenData`

### Frontend Architecture (React 19)
- **State Management**: Currently uses mock data, no global state management library
- **Styling**: Bootstrap 5 + custom CSS
- **Component Structure**: Component-based with separation between container and presentational components
- **Testing**: Jest + React Testing Library setup (minimal test coverage currently)
- **Build System**: Create React App with TypeScript strict mode

### Flutter Architecture
- **State Management**: Hooks Riverpod with Flutter Hooks
- **Navigation**: go_router for declarative routing
- **Code Generation**: freezed + json_serializable for data classes
- **Localization**: flutter_localizations with intl
- **Testing**: golden_toolkit + mocktail for comprehensive testing

### Docker Compose Stack
- **Frontend**: Node.js 18 Alpine with hot reload via volume mounts
- **Backend**: Custom Docker build with Python FastAPI
- **Database**: PostgreSQL 15 with persistent data volume and init.sql schema
- **Proxy**: Nginx with SSL termination and reverse proxy configuration

## Key API Endpoints

### Authentication
- `POST /token` - Login and obtain JWT token (username/password form data)
- `GET /users/me/` - Get current authenticated user info
- `POST /register/` - Register new user (currently accepts UserInDB model)

### General
- `GET /` - Welcome message and health check
- `GET /docs` - Interactive API documentation (Swagger UI)

## Environment Configuration

### Frontend Environment Variables
- `REACT_APP_API_URL` - Backend API base URL (default: http://localhost:8000)
- `CHOKIDAR_USEPOLLING=true` - Required for hot reload in Docker

### Backend Environment Variables
- `SECRET_KEY` - JWT signing secret (CRITICAL: change in production)
- `DATABASE_URL` - PostgreSQL connection string (format: postgresql://user:password@host:port/dbname)

### Docker Compose Environment
All environment variables are configured in `docker-compose.yml` with development defaults. The stack includes health checks for all services.

## Database Schema

Initial schema is defined in `backend/init.sql` and automatically loaded into PostgreSQL on first startup. Currently the backend uses mock data, but the infrastructure is ready for real database integration.

## Testing Strategy

### Frontend Testing
- Framework: Jest + React Testing Library
- Current coverage is minimal (only basic App component test)
- Run: `npm test` in frontend directory

### Backend Testing
- Framework: pytest (not installed by default)
- Test file: `test_main.py`
- Install: `pip install pytest` then run `pytest`

### Flutter Testing
- Unit tests: `flutter test`
- Integration tests: Available in `test/` directory
- Golden tests: Using golden_toolkit for widget testing

## SSL Configuration

SSL certificates should be placed in `ssl/` directory. See `ssl/README.md` for setup instructions. Nginx is configured to serve both HTTP (port 80) and HTTPS (port 443) with reverse proxy to frontend and backend services.