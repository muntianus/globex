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
import databases
from contextlib import asynccontextmanager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Database connection
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@db:5432/globex")
database = databases.Database(DATABASE_URL)

# Lifespan manager for database connections
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await database.connect()
    logger.info("🗄️ Database connected successfully")
    yield
    # Shutdown
    await database.disconnect()
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

    sanitized_headers = {
        key: value
        for key, value in request.headers.items()
        if key.lower() not in {"authorization"}
    }
    if sanitized_headers:
        logger.info(f"🔵 Headers: {sanitized_headers}")
    if request.method in ["POST", "PUT", "PATCH"] and request.url.path != "/token":
        try:
            body = await request.body()
            if body:
                logger.info(f"🔵 Body: {body.decode('utf-8')[:500]}...")
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

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(UTC) + expires_delta
    else:
        expire = datetime.now(UTC) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# --- User Models ---
class User(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None

class UserInDB(User):
    hashed_password: str

class UserCreate(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    password: str

class CompanyCreate(BaseModel):
    name: str
    category: str
    description: str
    inn: str
    region: str
    yearFounded: int
    employees: str
    phone: str
    email: str
    website: str
    services: List[str]
    tags: Optional[List[str]] = []

# --- Database User Functions ---
async def get_user(username: str):
    query = "SELECT * FROM users WHERE username = :username"
    user_record = await database.fetch_one(query, values={"username": username})
    if user_record:
        return UserInDB(**user_record)
    return None

async def authenticate_user(username: str, password: str):
    user = await get_user(username)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user

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
    user = await get_user(token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user")
    return current_user

# --- Company Models ---
class Review(BaseModel):
    id: int
    author: str
    rating: int
    text: str
    date: str

class Company(BaseModel):
    id: int
    name: str
    category: str
    description: str
    rating: float
    reviewsCount: int
    verified: bool
    inn: str
    region: str
    yearFounded: int
    employees: str
    tags: List[str]
    logo: str
    phone: str
    email: str
    website: str
    completedDeals: int
    responseTime: str
    services: List[str]
    reviews: List[Review]

# --- Database Company Functions ---
async def get_companies_from_db(skip: int = 0, limit: int = 10):
    # Main company query
    query = """
        SELECT c.*, cat.id as category_id
        FROM companies c
        LEFT JOIN categories cat ON c.category_id = cat.id
        ORDER BY c.id
        LIMIT :limit OFFSET :skip
    """
    companies_records = await database.fetch_all(query, values={"skip": skip, "limit": limit})

    if not companies_records:
        return []

    company_ids = [company_record["id"] for company_record in companies_records]
    tags_map = await _fetch_related_values("company_tags", "tag", company_ids)
    services_map = await _fetch_related_values("company_services", "service", company_ids)
    reviews_map = await _fetch_reviews(company_ids)

    return [
        _build_company(company_record, tags_map, services_map, reviews_map)
        for company_record in companies_records
    ]

async def get_company_from_db(company_id: int):
    company_query = """
        SELECT c.*, cat.id as category_id
        FROM companies c
        LEFT JOIN categories cat ON c.category_id = cat.id
        WHERE c.id = :company_id
    """
    company_record = await database.fetch_one(company_query, values={"company_id": company_id})
    if not company_record:
        return None

    tags_map = await _fetch_related_values("company_tags", "tag", [company_id])
    services_map = await _fetch_related_values("company_services", "service", [company_id])
    reviews_map = await _fetch_reviews([company_id])

    return _build_company(company_record, tags_map, services_map, reviews_map)


async def _fetch_related_values(table: str, column: str, company_ids: List[int]):
    if not company_ids:
        return {}

    query = f"""
        SELECT company_id, {column}
        FROM {table}
        WHERE company_id = ANY(:company_ids)
        ORDER BY company_id
    """
    records = await database.fetch_all(query, values={"company_ids": company_ids})

    result = {}
    for record in records:
        result.setdefault(record["company_id"], []).append(record[column])
    return result


async def _fetch_reviews(company_ids: List[int]):
    if not company_ids:
        return {}

    query = """
        SELECT id, company_id, author, rating, text, date
        FROM reviews
        WHERE company_id = ANY(:company_ids)
        ORDER BY company_id, created_at DESC
    """
    records = await database.fetch_all(query, values={"company_ids": company_ids})

    result = {}
    for record in records:
        review = Review(
            id=record["id"],
            author=record["author"],
            rating=record["rating"],
            text=record["text"],
            date=record["date"].strftime("%Y-%m-%d")
        )
        result.setdefault(record["company_id"], []).append(review)
    return result


def _build_company(company_record, tags_map, services_map, reviews_map):
    company_id = company_record["id"]
    return Company(
        id=company_id,
        name=company_record["name"],
        category=company_record["category_id"],
        description=company_record["description"],
        rating=float(company_record["rating"]),
        reviewsCount=company_record["reviews_count"],
        verified=company_record["verified"],
        inn=company_record["inn"],
        region=company_record["region"],
        yearFounded=company_record["year_founded"],
        employees=company_record["employees"],
        tags=tags_map.get(company_id, []),
        logo=company_record["logo"],
        phone=company_record["phone"],
        email=company_record["email"],
        website=company_record["website"],
        completedDeals=company_record["completed_deals"],
        responseTime=company_record["response_time"],
        services=services_map.get(company_id, []),
        reviews=reviews_map.get(company_id, [])
    )

# --- API Endpoints ---
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    logger.info(f"🔐 Login attempt for username: {form_data.username}")
    
    user = await authenticate_user(form_data.username, form_data.password)
    if not user:
        logger.warning(f"❌ Login failed for username: {form_data.username}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    logger.info(f"✅ Login successful for username: {form_data.username}")
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me/", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@app.post("/register/", response_model=User)
async def register_user(user: UserCreate):
    logger.info(f"👤 Registration attempt for username: {user.username}")
    
    existing_user = await get_user(user.username)
    if existing_user:
        logger.warning(f"❌ Registration failed - username already exists: {user.username}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already registered")
    
    try:
        hashed_password = get_password_hash(user.password)
        
        # Insert new user
        query = """
            INSERT INTO users (username, email, full_name, hashed_password, disabled)
            VALUES (:username, :email, :full_name, :hashed_password, :disabled)
            RETURNING id, username, email, full_name, disabled
        """
        user_record = await database.fetch_one(
            query, 
            values={
                "username": user.username,
                "email": user.email,
                "full_name": user.full_name,
                "hashed_password": hashed_password,
                "disabled": False
            }
        )
        
        logger.info(f"✅ Registration successful for username: {user.username}")
        return User(**user_record)
    except Exception as e:
        logger.error(f"❌ Registration error for {user.username}: {str(e)}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Registration failed")

# --- API Endpoints ---
@app.get("/companies/", response_model=List[Company])
async def get_companies(skip: int = 0, limit: int = 10):
    """Get list of companies with pagination"""
    return await get_companies_from_db(skip, limit)

@app.get("/companies/{company_id}", response_model=Company)
async def get_company(company_id: int):
    """Get specific company by ID"""
    company = await get_company_from_db(company_id)
    if company is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Company not found")
    return company

@app.get("/categories/")
async def get_categories():
    """Get list of available categories"""
    query = "SELECT * FROM categories ORDER BY id"
    categories = await database.fetch_all(query)
    return [{"id": cat["id"], "nameKey": cat["name_key"], "icon": cat["icon"]} for cat in categories]

@app.post("/companies/", response_model=Company)
async def create_company(company_data: CompanyCreate, current_user: User = Depends(get_current_active_user)):
    """Create new company (requires authentication)"""
    logger.info(f"🏢 Company registration attempt: {company_data.name} by user {current_user.username}")
    
    try:
        # Insert new company
        company_query = """
            INSERT INTO companies (
                name, category_id, description, inn, region, year_founded, 
                employees, phone, email, website, created_by
            )
            VALUES (
                :name, :category_id, :description, :inn, :region, :year_founded,
                :employees, :phone, :email, :website, :created_by
            )
            RETURNING id
        """
        
        # Get user ID
        user_query = "SELECT id FROM users WHERE username = :username"
        user_record = await database.fetch_one(user_query, values={"username": current_user.username})
        
        company_record = await database.fetch_one(
            company_query,
            values={
                "name": company_data.name,
                "category_id": company_data.category,
                "description": company_data.description,
                "inn": company_data.inn,
                "region": company_data.region,
                "year_founded": company_data.yearFounded,
                "employees": company_data.employees,
                "phone": company_data.phone,
                "email": company_data.email,
                "website": company_data.website,
                "created_by": user_record["id"]
            }
        )
        
        company_id = company_record["id"]
        
        # Insert services
        for service in company_data.services:
            await database.execute(
                "INSERT INTO company_services (company_id, service) VALUES (:company_id, :service)",
                values={"company_id": company_id, "service": service}
            )
        
        # Insert tags
        for tag in (company_data.tags or []):
            await database.execute(
                "INSERT INTO company_tags (company_id, tag) VALUES (:company_id, :tag)",
                values={"company_id": company_id, "tag": tag}
            )
        
        logger.info(f"✅ Company created successfully: {company_data.name} (ID: {company_id})")
        
        # Return the created company
        return await get_company_from_db(company_id)
        
    except Exception as e:
        logger.error(f"❌ Company creation error for {company_data.name}: {str(e)}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Company creation failed")

@app.get('/')
async def read_root():
    total_companies_query = "SELECT COUNT(*) as count FROM companies"
    result = await database.fetch_one(total_companies_query)
    return {"message": "Welcome to the B2B Marketplace Backend!", "total_companies": result["count"]}