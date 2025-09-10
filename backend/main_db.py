from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.middleware.cors import CORSMiddleware
import os
import logging
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta, UTC
from typing import Optional, List
from pydantic import BaseModel
import asyncpg
from contextlib import asynccontextmanager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Database connection
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@db:5432/globex")
db_pool = None

# Lifespan manager for database connections
@asynccontextmanager
async def lifespan(app: FastAPI):
    global db_pool
    # Startup - connect to database
    try:
        db_pool = await asyncpg.create_pool(DATABASE_URL)
        logger.info("🗄️ Database connected successfully")
        
        # Verify admin user exists
        async with db_pool.acquire() as connection:
            admin_user = await connection.fetchrow(
                "SELECT username, hashed_password FROM users WHERE username = $1", "admin"
            )
            if admin_user:
                logger.info(f"✅ Admin user found in database")
            else:
                logger.warning("⚠️ Admin user not found in database")
                
    except Exception as e:
        logger.error(f"❌ Database connection failed: {e}")
        # Fall back to simple mode without database
        db_pool = None
    
    yield
    
    # Shutdown - close database connections
    if db_pool:
        await db_pool.close()
        logger.info("🗄️ Database disconnected")

app = FastAPI(lifespan=lifespan)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000", 
        "http://127.0.0.1:3000",
        "http://localhost:8080",  # Flutter web app
        "http://127.0.0.1:8080",  # Flutter web app
        "http://localhost:8081",  # Flutter web app
        "http://127.0.0.1:8081"   # Flutter web app
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = datetime.now()
    
    # Log request
    logger.info(f"🔵 REQUEST: {request.method} {request.url}")
    if request.method in ["POST", "PUT", "PATCH"]:
        try:
            body = await request.body()
            if body:
                logger.info(f"🔵 Body: {body.decode('utf-8')[:200]}...")
        except Exception as e:
            logger.error(f"❌ Error reading request body: {e}")
    
    # Process request
    response = await call_next(request)
    
    # Log response
    process_time = datetime.now() - start_time
    logger.info(f"🟢 RESPONSE: {response.status_code} - {process_time.total_seconds():.3f}s")
    
    return response

# --- Configuration ---
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# --- Password Hashing ---
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

# --- JWT Token Handling ---
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class User(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None

class UserInDB(User):
    hashed_password: str

class Company(BaseModel):
    name: str
    inn: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    region: Optional[str] = None
    city: Optional[str] = None
    address: Optional[str] = None
    website: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None

# Mock database fallback (in case DB is not available)
fake_users_db = {
    "admin": {
        "username": "admin",
        "full_name": "Administrator",
        "email": "admin@globex.com",
        "hashed_password": "$2b$12$BYWjSXn3ZkfXjXZfOJLeouR.kb1vnYy1SW1uP6jiBGnfj8TMCtaHG",  # admin password
        "disabled": False,
    }
}

async def get_user_from_db(username: str):
    """Get user from database or fallback to mock data"""
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                row = await connection.fetchrow(
                    "SELECT username, email, full_name, hashed_password, is_active FROM users WHERE username = $1",
                    username
                )
                if row:
                    return UserInDB(
                        username=row['username'],
                        email=row['email'],
                        full_name=row['full_name'],
                        hashed_password=row['hashed_password'],
                        disabled=not row['is_active']
                    )
        except Exception as e:
            logger.error(f"❌ Database query failed: {e}")
    
    # Fallback to mock data
    if username in fake_users_db:
        user_dict = fake_users_db[username]
        return UserInDB(**user_dict)
    
    return None

async def authenticate_user(username: str, password: str):
    logger.info(f"🔐 Authenticating user: {username}")
    user = await get_user_from_db(username)
    if not user:
        logger.warning(f"❌ User not found: {username}")
        return False
    if not verify_password(password, user.hashed_password):
        logger.warning(f"❌ Invalid password for user: {username}")
        return False
    logger.info(f"✅ User authenticated successfully: {username}")
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(UTC) + expires_delta
    else:
        expire = datetime.now(UTC) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = await get_user_from_db(username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# --- API Endpoints ---

@app.get("/")
async def read_root():
    db_status = "connected" if db_pool else "mock_mode"
    return {
        "message": "Globex B2B Marketplace API is running! 🚀", 
        "timestamp": datetime.now(),
        "database": db_status
    }

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    logger.info(f"🔐 Login attempt for username: {form_data.username}")
    
    user = await authenticate_user(form_data.username, form_data.password)
    if not user:
        logger.error(f"❌ Authentication failed for: {form_data.username}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    logger.info(f"✅ Login successful for: {form_data.username}")
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me/", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@app.post("/companies/")
async def create_company(
    company: Company, 
    current_user: User = Depends(get_current_active_user)
):
    """Create a new company"""
    logger.info(f"📊 Creating company: {company.name} by user: {current_user.username}")
    
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                # Get user ID
                user_row = await connection.fetchrow(
                    "SELECT id FROM users WHERE username = $1", current_user.username
                )
                user_id = user_row['id'] if user_row else 1
                
                # Insert company
                company_id = await connection.fetchval(
                    """INSERT INTO companies (name, inn, category, description, region, city, address, website, email, phone, created_by)
                       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                       RETURNING id""",
                    company.name, company.inn, company.category, company.description,
                    company.region, company.city, company.address, company.website,
                    company.email, company.phone, user_id
                )
                
                logger.info(f"✅ Company created in database with ID: {company_id}")
                return {"message": "Company created successfully", "company_id": company_id}
                
        except Exception as e:
            logger.error(f"❌ Database error creating company: {e}")
            raise HTTPException(status_code=500, detail="Database error creating company")
    
    # Fallback to mock response
    company_data = company.dict()
    company_data["id"] = 1  # Mock ID
    company_data["created_by"] = current_user.username
    company_data["created_at"] = datetime.now()
    
    logger.info(f"✅ Company created (mock mode): {company.name}")
    return {"message": "Company created successfully (mock mode)", "company": company_data}

@app.get("/companies/")
async def list_companies():
    """List all companies"""
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                rows = await connection.fetch(
                    """SELECT c.*, u.username as created_by_username 
                       FROM companies c 
                       LEFT JOIN users u ON c.created_by = u.id 
                       ORDER BY c.created_at DESC"""
                )
                companies = []
                for row in rows:
                    company_dict = dict(row)
                    companies.append(company_dict)
                
                logger.info(f"📊 Retrieved {len(companies)} companies from database")
                return companies
                
        except Exception as e:
            logger.error(f"❌ Database error listing companies: {e}")
            raise HTTPException(status_code=500, detail="Database error listing companies")
    
    # Mock response
    return []

@app.get("/categories/")
async def list_categories():
    """List all categories"""
    categories = [
        {"id": "all", "nameKey": "Все категории", "icon": "📋"},
        {"id": "it", "nameKey": "IT и разработка", "icon": "💻"},
        {"id": "manufacturing", "nameKey": "Производство", "icon": "🏭"},
        {"id": "logistics", "nameKey": "Логистика", "icon": "🚛"},
        {"id": "construction", "nameKey": "Строительство", "icon": "🏗️"},
        {"id": "consulting", "nameKey": "Консалтинг", "icon": "⚖️"},
    ]
    return categories

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)