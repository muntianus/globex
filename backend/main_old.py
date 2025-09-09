from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.middleware.cors import CORSMiddleware
import os
import logging
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta, UTC
from typing import Optional
from pydantic import BaseModel

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000", 
        "http://127.0.0.1:3000",
        "http://localhost:8080",  # Flutter web app
        "http://127.0.0.1:8080"   # Flutter web app
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
    logger.info(f"🔵 Headers: {dict(request.headers)}")
    if request.method in ["POST", "PUT", "PATCH"]:
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
    services: list[str]
    tags: Optional[list[str]] = []

# --- Mock Database (In a real app, use a proper database) ---
fake_users_db = {
    "admin": {
        "username": "admin",
        "email": "admin@example.com",
        "full_name": "Admin User",
        "hashed_password": get_password_hash("admin"),
        "disabled": False,
    }
}

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)
    return None

def authenticate_user(db, username: str, password: str):
    user = get_user(db, username)
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
    user = get_user(fake_users_db, token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user")
    return current_user

# --- API Endpoints ---
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    logger.info(f"🔐 Login attempt for username: {form_data.username}")
    
    user = authenticate_user(fake_users_db, form_data.username, form_data.password)
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
    
    if get_user(fake_users_db, user.username):
        logger.warning(f"❌ Registration failed - username already exists: {user.username}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already registered")
    
    try:
        hashed_password = get_password_hash(user.password)
        user_in_db = UserInDB(
            username=user.username,
            email=user.email,
            full_name=user.full_name,
            hashed_password=hashed_password,
            disabled=False
        )
        fake_users_db[user.username] = user_in_db.model_dump()
        logger.info(f"✅ Registration successful for username: {user.username}")
        return User(username=user.username, email=user.email, full_name=user.full_name, disabled=False)
    except Exception as e:
        logger.error(f"❌ Registration error for {user.username}: {str(e)}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Registration failed")

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
    tags: list[str]
    logo: str
    phone: str
    email: str
    website: str
    completedDeals: int
    responseTime: str
    services: list[str]
    reviews: list[Review]

# --- Mock Company Database (Russian version matching Flutter) ---
fake_companies_db = [
    {
        "id": 1,
        "name": "ТехноПром",
        "category": "manufacturing",
        "description": "Производство промышленного оборудования",
        "rating": 4.8,
        "reviewsCount": 127,
        "verified": True,
        "inn": "7725123456",
        "region": "Москва",
        "yearFounded": 2015,
        "employees": "100-500",
        "tags": ["Быстрая доставка", "Гарантия качества"],
        "logo": "🏭",
        "phone": "+7 (495) 123-45-67",
        "email": "info@technoprom.ru",
        "website": "technoprom.ru",
        "completedDeals": 342,
        "responseTime": "2 часа",
        "services": ["Производство на заказ", "Консультации", "Монтаж"],
        "reviews": [
            {"id": 1, "author": "ООО \"СтройКом\"", "rating": 5, "text": "Отличное качество продукции, всегда в срок", "date": "2024-11-15"},
            {"id": 2, "author": "ЗАО \"МегаСтрой\"", "rating": 4, "text": "Хороший сервис, но цены выше рынка", "date": "2024-10-22"}
        ]
    },
    {
        "id": 2,
        "name": "ЛогистикПро",
        "category": "logistics",
        "description": "Грузоперевозки по России и СНГ",
        "rating": 4.6,
        "reviewsCount": 89,
        "verified": True,
        "inn": "7726234567",
        "region": "Санкт-Петербург",
        "yearFounded": 2018,
        "employees": "50-100",
        "tags": ["Страхование груза", "GPS-трекинг"],
        "logo": "🚛",
        "phone": "+7 (812) 234-56-78",
        "email": "cargo@logisticpro.ru",
        "website": "logisticpro.ru",
        "completedDeals": 567,
        "responseTime": "30 минут",
        "services": ["FTL перевозки", "LTL перевозки", "Таможенное оформление"],
        "reviews": [
            {"id": 1, "author": "ИП Петров", "rating": 5, "text": "Всегда довозят в срок, груз в сохранности", "date": "2024-11-20"},
            {"id": 2, "author": "ООО \"ТоргСеть\"", "rating": 4, "text": "Хорошая компания, рекомендую", "date": "2024-11-10"}
        ]
    },
    {
        "id": 3,
        "name": "ДигиталСофт",
        "category": "it",
        "description": "Разработка корпоративного ПО",
        "rating": 4.9,
        "reviewsCount": 156,
        "verified": True,
        "inn": "7727345678",
        "region": "Москва",
        "yearFounded": 2012,
        "employees": "10-50",
        "tags": ["Agile", "Поддержка 24/7"],
        "logo": "💻",
        "phone": "+7 (495) 345-67-89",
        "email": "hello@digitalsoft.ru",
        "website": "digitalsoft.ru",
        "completedDeals": 234,
        "responseTime": "1 час",
        "services": ["Web-разработка", "Мобильные приложения", "Интеграции"],
        "reviews": [
            {"id": 1, "author": "АО \"ФинТех\"", "rating": 5, "text": "Профессиональная команда, сделали отличный продукт", "date": "2024-11-18"}
        ]
    },
    {
        "id": 4,
        "name": "СтройМатериал",
        "category": "construction",
        "description": "Поставка строительных материалов",
        "rating": 4.5,
        "reviewsCount": 203,
        "verified": False,
        "inn": "7728456789",
        "region": "Екатеринбург",
        "yearFounded": 2010,
        "employees": "100-500",
        "tags": ["Оптовые цены", "Доставка"],
        "logo": "🏗️",
        "phone": "+7 (343) 456-78-90",
        "email": "sales@stroymaterial.ru",
        "website": "stroymaterial.ru",
        "completedDeals": 891,
        "responseTime": "3 часа",
        "services": ["Оптовые поставки", "Розница", "Доставка на объект"],
        "reviews": [
            {"id": 1, "author": "ООО \"СтройГрад\"", "rating": 4, "text": "Большой ассортимент, приемлемые цены", "date": "2024-11-12"}
        ]
    },
    {
        "id": 5,
        "name": "КонсалтПлюс",
        "category": "consulting",
        "description": "Юридические и бухгалтерские услуги",
        "rating": 4.7,
        "reviewsCount": 67,
        "verified": True,
        "inn": "7729567890",
        "region": "Москва",
        "yearFounded": 2008,
        "employees": "10-50",
        "tags": ["Аудит", "Налоговое планирование"],
        "logo": "⚖️",
        "phone": "+7 (495) 567-89-01",
        "email": "info@consultplus.ru",
        "website": "consultplus.ru",
        "completedDeals": 445,
        "responseTime": "1 час",
        "services": ["Бухгалтерский учет", "Юридическое сопровождение", "Аудит"],
        "reviews": [
            {"id": 1, "author": "ИП Иванова", "rating": 5, "text": "Помогли оптимизировать налоги, спасибо!", "date": "2024-11-05"}
        ]
    }
]

# --- API Endpoints ---
@app.get("/companies/", response_model=list[Company])
async def get_companies(skip: int = 0, limit: int = 10):
    """Get list of companies with pagination"""
    return fake_companies_db[skip : skip + limit]

@app.get("/companies/{company_id}", response_model=Company)
async def get_company(company_id: int):
    """Get specific company by ID"""
    company = next((c for c in fake_companies_db if c["id"] == company_id), None)
    if company is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Company not found")
    return company

# --- Categories ---
categories = [
    {"id": "all", "nameKey": "allCategories", "icon": "📋"},
    {"id": "manufacturing", "nameKey": "manufacturing", "icon": "🏭"},
    {"id": "logistics", "nameKey": "logistics", "icon": "🚛"},
    {"id": "it", "nameKey": "itServices", "icon": "💻"},
    {"id": "construction", "nameKey": "construction", "icon": "🏗️"},
    {"id": "consulting", "nameKey": "consulting", "icon": "⚖️"}
]

@app.get("/categories/")
async def get_categories():
    """Get list of available categories"""
    return categories

@app.post("/companies/", response_model=Company)
async def create_company(company_data: CompanyCreate, current_user: User = Depends(get_current_active_user)):
    """Create new company (requires authentication)"""
    logger.info(f"🏢 Company registration attempt: {company_data.name} by user {current_user.username}")
    
    try:
        # Generate new ID
        max_id = max([c["id"] for c in fake_companies_db], default=0)
        new_id = max_id + 1
        
        # Create new company
        new_company = {
            "id": new_id,
            "name": company_data.name,
            "category": company_data.category,
            "description": company_data.description,
            "rating": 0.0,  # Initial rating
            "reviewsCount": 0,  # Initial reviews count
            "verified": False,  # New companies are not verified by default
            "inn": company_data.inn,
            "region": company_data.region,
            "yearFounded": company_data.yearFounded,
            "employees": company_data.employees,
            "tags": company_data.tags or [],
            "logo": "🏢",  # Default logo
            "phone": company_data.phone,
            "email": company_data.email,
            "website": company_data.website,
            "completedDeals": 0,  # Initial deals count
            "responseTime": "24 часа",  # Default response time
            "services": company_data.services,
            "reviews": []  # Empty reviews initially
        }
        
        # Add to database
        fake_companies_db.append(new_company)
        
        logger.info(f"✅ Company created successfully: {company_data.name} (ID: {new_id})")
        return new_company
        
    except Exception as e:
        logger.error(f"❌ Company creation error for {company_data.name}: {str(e)}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Company creation failed")

@app.get('/')
async def read_root():
    return {"message": "Welcome to the B2B Marketplace Backend!", "total_companies": len(fake_companies_db)}
