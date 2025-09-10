# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a full-stack B2B marketplace platform designed for connecting companies with investors and facilitating business partnerships. The system consists of three integrated applications:

1. **frontend/** - React 19 + TypeScript web dashboard with Bootstrap 5 styling
2. **backend/** - FastAPI Python API service with JWT authentication and PostgreSQL integration
3. **b2b_marketplace_app/** - Flutter cross-platform mobile/desktop application with investment showcase features

### Key Business Features
- **Company Management**: Registration and profile management for businesses
- **Investment Proposals**: Comprehensive system for creating and showcasing investment opportunities
- **Investor Portal**: Browse and filter investment proposals by industry, stage, type, and amount
- **Authentication System**: Secure JWT-based authentication with role-based access
- **Multi-platform Access**: Web dashboard + mobile/desktop Flutter application

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
flutter run -d chrome --web-port 8081  # Run web version (recommended)
flutter run              # Run on connected device/emulator

# Key dependencies: go_router, hooks_riverpod, flutter_hooks, freezed
# App runs on http://localhost:8081 for web development
```

## Architecture

### Backend Architecture (FastAPI)
- **Authentication**: JWT-based with OAuth2PasswordBearer flow
- **Password Security**: bcrypt hashing via passlib 
- **Data Layer**: PostgreSQL database with SQLAlchemy-ready schema
- **API Structure**: RESTful endpoints with Pydantic models for request/response validation
- **Key Models**: `User`, `UserInDB`, `Token`, `TokenData`, `Company`, `InvestmentProposal`
- **CORS Configuration**: Configured for Flutter web (port 8081) and React (port 3000)
- **Database Schema**: Comprehensive schema including companies and investment_proposals tables

### Frontend Architecture (React 19)
- **State Management**: Currently uses mock data, no global state management library
- **Styling**: Bootstrap 5 + custom CSS
- **Component Structure**: Component-based with separation between container and presentational components
- **Testing**: Jest + React Testing Library setup (minimal test coverage currently)
- **Build System**: Create React App with TypeScript strict mode

### Flutter Architecture
- **State Management**: Hooks Riverpod with Flutter Hooks for reactive state management
- **Navigation**: go_router for declarative routing with authentication guards
- **Code Generation**: freezed + json_serializable for data classes
- **Localization**: flutter_localizations with intl (Russian + English)
- **Testing**: golden_toolkit + mocktail for comprehensive testing
- **Key Features**: 
  - Company creation and management
  - Investment proposal showcase with advanced filtering
  - Responsive design for web, mobile, and desktop
  - Real-time data updates through providers

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

### Company Management
- `POST /companies/` - Create new company (requires authentication)
- `GET /companies/` - List all companies
- `GET /companies/{company_id}` - Get specific company details

### Investment Proposals (Planned)
- `GET /investment-proposals/` - List investment proposals with filtering
- `POST /investment-proposals/` - Create new investment proposal
- `GET /investment-proposals/{proposal_id}` - Get specific proposal details

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

Comprehensive database schema defined in `backend/schema.sql` and automatically loaded into PostgreSQL on first startup.

### Core Tables

#### Users Table
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Companies Table
```sql
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    inn VARCHAR(20) UNIQUE,
    category VARCHAR(100),
    description TEXT,
    region VARCHAR(100),
    city VARCHAR(100),
    address TEXT,
    website VARCHAR(255),
    email VARCHAR(100),
    phone VARCHAR(20),
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Investment Proposals Table
```sql
CREATE TABLE investment_proposals (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    investment_amount DECIMAL(15,2) NOT NULL,
    equity_percentage DECIMAL(5,2),
    expected_return DECIMAL(5,2),
    investment_type VARCHAR(50) NOT NULL, -- 'equity', 'debt', 'hybrid'
    business_stage VARCHAR(50) NOT NULL, -- 'startup', 'growth', 'expansion', 'mature'
    industry VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    min_investment DECIMAL(15,2),
    max_investment DECIMAL(15,2),
    funding_deadline DATE,
    use_of_funds TEXT,
    financial_highlights TEXT,
    team_info TEXT,
    market_opportunity TEXT,
    competitive_advantages TEXT,
    risks TEXT,
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'paused', 'closed', 'funded'
    views_count INTEGER DEFAULT 0,
    interested_investors INTEGER DEFAULT 0,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Sample Data
The schema includes seed data with:
- Admin user (username: admin, password: admin)
- 5 sample companies across different industries
- 5 detailed investment proposals with realistic business data

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

## Flutter Application Features

### Investment Showcase
- **Advanced Filtering**: Filter proposals by industry, business stage, investment type, and amount range
- **Detailed Proposal Cards**: Comprehensive display of investment opportunities with financial highlights
- **Responsive Design**: Optimized for web, mobile, and desktop platforms
- **Mock Data**: Currently uses rich mock data with 5 realistic investment proposals

### Company Management
- **Company Creation**: Full form with validation for creating company profiles
- **Integration Ready**: Designed to integrate with backend API for data persistence
- **Required Fields**: Name, INN, category, description, region, contact information

### Navigation & UX
- **Authenticated Routes**: Login/register flow with route protection
- **Intuitive Navigation**: Clear navigation between home, investors, company creation, and other features
- **Responsive Layout**: Consistent experience across all device types

## Development Notes

### Current Status
- **Backend**: Fully functional API with PostgreSQL schema ready
- **Frontend (React)**: Basic authentication and dashboard structure
- **Flutter App**: Complete investment showcase with mock data, ready for API integration
- **Database**: Production-ready schema with sample data

### Next Steps
1. Connect Flutter investment proposals to backend API
2. Implement investor interest/contact functionality
3. Add real-time notifications for new proposals
4. Enhance filtering and search capabilities
5. Add company dashboard for managing their proposals

## SSL Configuration

SSL certificates should be placed in `ssl/` directory. See `ssl/README.md` for setup instructions. Nginx is configured to serve both HTTP (port 80) and HTTPS (port 443) with reverse proxy to frontend and backend services.