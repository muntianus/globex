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

## Recent Changes & Implementation Details

### Authentication System Improvements
- **Fixed Admin Login**: Updated PostgreSQL schema with correct bcrypt hash for admin user
- **Password**: admin/admin now works with hash `$2b$12$BYWjSXn3ZkfXjXZfOJLeouR.kb1vnYy1SW1uP6jiBGnfj8TMCtaHG`
- **CORS Configuration**: Added Flutter port 8081 to backend CORS settings for cross-origin requests
- **Database Integration**: Full PostgreSQL integration with connection pooling and fallback to mock data

### Flutter Application Enhancements

#### Company Creation System
- **Comprehensive Form**: Full company creation form with validation for all business fields
- **API Integration**: Connects to `/companies/` POST endpoint with proper authentication
- **Field Validation**: INN validation (min 10 digits), email format validation, required field checks
- **Success Handling**: Success messages and automatic navigation back to home page
- **Error Handling**: Detailed error messages with user-friendly feedback

#### Investment Proposals Showcase
- **Advanced Filtering System**: 
  - Industry filtering (10+ business categories)
  - Business stage filtering (startup, growth, expansion, mature)
  - Investment type filtering (equity, debt, hybrid)
  - Amount range filtering (₽0 to ₽50M)
- **Detailed Proposal Cards**: Comprehensive display with investment amount, equity percentage, expected returns
- **Modal Details View**: Full proposal details with team info, market opportunity, risks, competitive advantages
- **Provider Integration**: Uses `InvestmentProvider` with state management for real-time filtering

#### Provider Architecture Improvements
- **Fixed Initialization Conflicts**: Resolved Riverpod provider initialization issues by removing circular dependencies
- **Error Handling with Clipboard**: Added copy-to-clipboard functionality for error debugging
- **Database Fallback**: Graceful fallback to mock data when API is unavailable
- **Loading States**: Proper loading indicators and error states throughout the application

### Backend API Enhancements

#### Database Schema
- **Complete Business Model**: 25 comprehensive fields for investment proposals
- **Sample Data**: 25+ companies and investment proposals with realistic business data
- **Foreign Key Relationships**: Proper relationships between users, companies, and investment proposals
- **Indexed Fields**: Optimized queries with proper indexing on frequently searched fields

#### API Endpoints
- **Company Management**: Full CRUD operations for companies with authentication
- **Investment Proposals**: Complete investment proposal system (ready for implementation)
- **Categories API**: Dynamic category listing for dropdown populations
- **Error Handling**: Comprehensive error responses with proper HTTP status codes

### Docker & Infrastructure
- **Container Orchestration**: Updated docker-compose.yml with proper service dependencies
- **Volume Management**: Persistent PostgreSQL data with automatic schema initialization
- **Hot Reload**: Flutter web development with hot reload support
- **Multi-Port Support**: Supports both 8080 and 8081 for Flutter development flexibility

### Technical Fixes Applied

#### Authentication Issues
- **Problem**: Admin login failed with "incorrect username or password"
- **Root Cause**: Database password hash didn't match "admin" password
- **Solution**: Generated new bcrypt hash and updated database schema
- **Verification**: Added admin user verification in startup logs

#### CORS Configuration
- **Problem**: Flutter app getting "ClientException: Failed to fetch" errors
- **Root Cause**: Backend CORS didn't include Flutter development port
- **Solution**: Added `http://localhost:8081` and `http://127.0.0.1:8081` to allowed origins
- **Result**: Seamless API communication between Flutter and FastAPI

#### Provider Initialization
- **Problem**: "Providers are not allowed to modify other providers during their initialization"
- **Root Cause**: Circular dependency in Riverpod provider initialization
- **Solution**: Removed `app_initializer.dart` and simplified provider initialization pattern
- **Result**: Clean provider initialization without conflicts

#### API Response Format
- **Problem**: Flutter expected company array but got object with "companies" key
- **Root Cause**: API response format mismatch
- **Solution**: Updated API to return company array directly
- **Result**: Proper data binding in Flutter without additional parsing

#### Data Model Compatibility
- **Problem**: API fields (`category_id`, `reviews_count`) didn't match Flutter model fields
- **Root Cause**: Naming convention differences between backend and frontend
- **Solution**: Updated `Company.fromJson()` to handle both naming conventions with null safety
- **Result**: Robust data parsing that works with both mock and API data

#### Dropdown Widget Error
- **Problem**: "There should be exactly one item with [DropdownButton]'s value: all"
- **Root Cause**: Initial value 'all' was filtered out but still set as default
- **Solution**: Changed initial category from 'all' to 'manufacturing'
- **Result**: Proper dropdown initialization without runtime errors

### Code Quality Improvements
- **Null Safety**: Complete null safety implementation across all Flutter models
- **Error Boundaries**: Comprehensive error handling with user-friendly messages
- **Loading States**: Proper loading indicators and states throughout the application
- **Validation**: Client-side validation for all forms with appropriate error messages
- **Responsive Design**: Mobile-first responsive design that works on all screen sizes

## Development Notes

### Current Status
- **Backend**: Fully functional API with complete PostgreSQL integration and authentication
- **Frontend (React)**: Basic authentication and dashboard structure  
- **Flutter App**: Production-ready investment showcase with full API integration capability
- **Database**: Production schema with 25+ companies and investment proposals
- **Authentication**: Working admin/admin login with JWT token flow
- **Error Handling**: Comprehensive error handling with clipboard debugging support

### Next Steps
1. **Complete API Integration**: Connect Flutter investment proposals to live backend data
2. **User Registration**: Implement user registration flow in Flutter app
3. **Investment Interest**: Add investor interest/contact functionality with email notifications
4. **Real-time Updates**: Implement WebSocket or polling for real-time proposal updates
5. **Admin Dashboard**: Create admin interface for managing companies and proposals
6. **Mobile Optimization**: Fine-tune mobile experience and add push notifications

## SSL Configuration

SSL certificates should be placed in `ssl/` directory. See `ssl/README.md` for setup instructions. Nginx is configured to serve both HTTP (port 80) and HTTPS (port 443) with reverse proxy to frontend and backend services.