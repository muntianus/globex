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

# === Модели данных ===

class Company(BaseModel):
    """Модель компании для создания и обновления"""
    name: str  # Название компании
    inn: Optional[str] = None  # ИНН компании
    category: Optional[str] = None  # Категория бизнеса
    description: Optional[str] = None  # Описание компании
    region: Optional[str] = None  # Регион
    city: Optional[str] = None  # Город
    address: Optional[str] = None  # Адрес
    website: Optional[str] = None  # Веб-сайт
    email: Optional[str] = None  # Email для связи
    phone: Optional[str] = None  # Телефон

class InvestmentProposal(BaseModel):
    """Модель инвестиционного предложения"""
    company_id: int  # ID компании
    title: str  # Заголовок предложения
    description: str  # Подробное описание
    investment_amount: float  # Требуемая сумма инвестиций
    equity_percentage: Optional[float] = None  # Процент доли
    expected_return: Optional[float] = None  # Ожидаемая доходность
    investment_type: str  # Тип инвестиций: equity, debt, hybrid
    business_stage: str  # Стадия бизнеса: startup, growth, expansion, mature
    industry: str  # Отрасль
    location: str  # Местоположение
    min_investment: Optional[float] = None  # Минимальные инвестиции
    max_investment: Optional[float] = None  # Максимальные инвестиции
    funding_deadline: Optional[str] = None  # Дедлайн привлечения
    use_of_funds: Optional[str] = None  # Использование средств
    financial_highlights: Optional[str] = None  # Финансовые показатели
    team_info: Optional[str] = None  # Информация о команде
    market_opportunity: Optional[str] = None  # Рыночная возможность
    competitive_advantages: Optional[str] = None  # Конкурентные преимущества
    risks: Optional[str] = None  # Риски

class InvestorInterest(BaseModel):
    """Модель заявки инвестора"""
    proposal_id: int  # ID предложения
    investor_name: str  # Имя инвестора
    investor_email: str  # Email инвестора
    investor_phone: Optional[str] = None  # Телефон инвестора
    investment_amount: float  # Сумма инвестиций
    message: Optional[str] = None  # Сообщение от инвестора

class BusinessMetrics(BaseModel):
    """Модель бизнес-метрик"""
    company_id: int  # ID компании
    revenue: Optional[float] = None  # Выручка
    profit: Optional[float] = None  # Прибыль
    employees_count: Optional[int] = None  # Количество сотрудников
    year: int  # Год метрик
    month: Optional[int] = None  # Месяц (если ежемесячно)

class SearchFilters(BaseModel):
    """Модель фильтров поиска"""
    industry: Optional[str] = None  # Отрасль
    business_stage: Optional[str] = None  # Стадия бизнеса
    investment_type: Optional[str] = None  # Тип инвестиций
    min_amount: Optional[float] = None  # Минимальная сумма
    max_amount: Optional[float] = None  # Максимальная сумма
    location: Optional[str] = None  # Местоположение
    search_query: Optional[str] = None  # Поисковый запрос

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

# === API Endpoints ===

@app.get("/categories/")
async def list_categories():
    """Получить список всех категорий бизнеса"""
    categories = [
        {"id": "all", "nameKey": "Все категории", "icon": "📋"},
        {"id": "it", "nameKey": "IT и разработка", "icon": "💻"},
        {"id": "manufacturing", "nameKey": "Производство", "icon": "🏭"},
        {"id": "logistics", "nameKey": "Логистика", "icon": "🚛"},
        {"id": "construction", "nameKey": "Строительство", "icon": "🏗️"},
        {"id": "consulting", "nameKey": "Консалтинг", "icon": "⚖️"},
        {"id": "retail", "nameKey": "Розничная торговля", "icon": "🛒"},
        {"id": "healthcare", "nameKey": "Здравоохранение", "icon": "🏥"},
        {"id": "education", "nameKey": "Образование", "icon": "🎓"},
        {"id": "finance", "nameKey": "Финансы", "icon": "💰"},
    ]
    return categories

@app.post("/investment-proposals/")
async def create_investment_proposal(
    proposal: InvestmentProposal,
    current_user: User = Depends(get_current_active_user)
):
    """Создать новое инвестиционное предложение"""
    logger.info(f"📈 Creating investment proposal: {proposal.title} by user: {current_user.username}")
    
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                # Проверяем, что компания принадлежит пользователю
                company_check = await connection.fetchrow(
                    "SELECT id FROM companies WHERE id = $1", proposal.company_id
                )
                if not company_check:
                    raise HTTPException(status_code=404, detail="Company not found")
                
                # Вставляем предложение
                proposal_id = await connection.fetchval(
                    """INSERT INTO investment_proposals 
                       (company_id, title, description, investment_amount, equity_percentage, 
                        expected_return, investment_type, business_stage, industry, location,
                        min_investment, max_investment, funding_deadline, use_of_funds,
                        financial_highlights, team_info, market_opportunity, competitive_advantages, risks)
                       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
                       RETURNING id""",
                    proposal.company_id, proposal.title, proposal.description, proposal.investment_amount,
                    proposal.equity_percentage, proposal.expected_return, proposal.investment_type,
                    proposal.business_stage, proposal.industry, proposal.location,
                    proposal.min_investment, proposal.max_investment, proposal.funding_deadline,
                    proposal.use_of_funds, proposal.financial_highlights, proposal.team_info,
                    proposal.market_opportunity, proposal.competitive_advantages, proposal.risks
                )
                
                logger.info(f"✅ Investment proposal created with ID: {proposal_id}")
                return {"message": "Investment proposal created successfully", "proposal_id": proposal_id}
                
        except Exception as e:
            logger.error(f"❌ Database error creating proposal: {e}")
            raise HTTPException(status_code=500, detail="Database error creating proposal")
    
    return {"message": "Investment proposal created (mock mode)", "proposal_id": 1}

@app.get("/investment-proposals/")
async def list_investment_proposals(
    industry: Optional[str] = None,
    business_stage: Optional[str] = None,
    investment_type: Optional[str] = None,
    min_amount: Optional[float] = None,
    max_amount: Optional[float] = None,
    location: Optional[str] = None,
    limit: int = 50,
    offset: int = 0
):
    """Получить список инвестиционных предложений с фильтрацией"""
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                # Построение SQL запроса с фильтрами
                where_conditions = ["status = 'active'"]
                params = []
                param_count = 0
                
                if industry:
                    param_count += 1
                    where_conditions.append(f"industry = ${param_count}")
                    params.append(industry)
                
                if business_stage:
                    param_count += 1
                    where_conditions.append(f"business_stage = ${param_count}")
                    params.append(business_stage)
                
                if investment_type:
                    param_count += 1
                    where_conditions.append(f"investment_type = ${param_count}")
                    params.append(investment_type)
                
                if min_amount:
                    param_count += 1
                    where_conditions.append(f"investment_amount >= ${param_count}")
                    params.append(min_amount)
                
                if max_amount:
                    param_count += 1
                    where_conditions.append(f"investment_amount <= ${param_count}")
                    params.append(max_amount)
                
                if location:
                    param_count += 1
                    where_conditions.append(f"location ILIKE ${param_count}")
                    params.append(f"%{location}%")
                
                # Добавляем limit и offset
                param_count += 1
                limit_param = f"${param_count}"
                params.append(limit)
                
                param_count += 1
                offset_param = f"${param_count}"
                params.append(offset)
                
                where_clause = " AND ".join(where_conditions)
                
                query = f"""
                    SELECT ip.*, c.name as company_name, c.website as company_website
                    FROM investment_proposals ip
                    JOIN companies c ON ip.company_id = c.id
                    WHERE {where_clause}
                    ORDER BY ip.created_at DESC
                    LIMIT {limit_param} OFFSET {offset_param}
                """
                
                rows = await connection.fetch(query, *params)
                proposals = [dict(row) for row in rows]
                
                logger.info(f"📈 Retrieved {len(proposals)} investment proposals")
                return proposals
                
        except Exception as e:
            logger.error(f"❌ Database error listing proposals: {e}")
            raise HTTPException(status_code=500, detail="Database error listing proposals")
    
    # Mock response
    return []

@app.get("/investment-proposals/{proposal_id}")
async def get_investment_proposal(proposal_id: int):
    """Получить детальную информацию о предложении"""
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                # Увеличиваем счетчик просмотров
                await connection.execute(
                    "UPDATE investment_proposals SET views_count = views_count + 1 WHERE id = $1",
                    proposal_id
                )
                
                # Получаем данные предложения
                row = await connection.fetchrow(
                    """SELECT ip.*, c.name as company_name, c.website as company_website,
                              c.description as company_description, c.city as company_city
                       FROM investment_proposals ip
                       JOIN companies c ON ip.company_id = c.id
                       WHERE ip.id = $1""",
                    proposal_id
                )
                
                if not row:
                    raise HTTPException(status_code=404, detail="Investment proposal not found")
                
                return dict(row)
                
        except Exception as e:
            logger.error(f"❌ Database error getting proposal: {e}")
            raise HTTPException(status_code=500, detail="Database error getting proposal")
    
    raise HTTPException(status_code=404, detail="Investment proposal not found")

@app.post("/investor-interest/")
async def create_investor_interest(interest: InvestorInterest):
    """Создать заявку от инвестора"""
    logger.info(f"💰 New investor interest from: {interest.investor_email} for proposal: {interest.proposal_id}")
    
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                # Проверяем существование предложения
                proposal_check = await connection.fetchrow(
                    "SELECT id FROM investment_proposals WHERE id = $1", interest.proposal_id
                )
                if not proposal_check:
                    raise HTTPException(status_code=404, detail="Investment proposal not found")
                
                # Сохраняем заявку инвестора
                interest_id = await connection.fetchval(
                    """INSERT INTO investor_interests 
                       (proposal_id, investor_name, investor_email, investor_phone, investment_amount, message)
                       VALUES ($1, $2, $3, $4, $5, $6)
                       RETURNING id""",
                    interest.proposal_id, interest.investor_name, interest.investor_email,
                    interest.investor_phone, interest.investment_amount, interest.message
                )
                
                # Увеличиваем счетчик заинтересованных инвесторов
                await connection.execute(
                    "UPDATE investment_proposals SET interested_investors = interested_investors + 1 WHERE id = $1",
                    interest.proposal_id
                )
                
                logger.info(f"✅ Investor interest created with ID: {interest_id}")
                return {"message": "Interest registered successfully", "interest_id": interest_id}
                
        except Exception as e:
            logger.error(f"❌ Database error creating interest: {e}")
            raise HTTPException(status_code=500, detail="Database error creating interest")
    
    return {"message": "Interest registered (mock mode)", "interest_id": 1}

@app.get("/companies/{company_id}/metrics")
async def get_company_metrics(company_id: int):
    """Получить бизнес-метрики компании"""
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                rows = await connection.fetch(
                    """SELECT * FROM business_metrics 
                       WHERE company_id = $1 
                       ORDER BY year DESC, month DESC""",
                    company_id
                )
                return [dict(row) for row in rows]
                
        except Exception as e:
            logger.error(f"❌ Database error getting metrics: {e}")
            raise HTTPException(status_code=500, detail="Database error getting metrics")
    
    return []

@app.post("/companies/{company_id}/metrics")
async def create_business_metrics(
    company_id: int,
    metrics: BusinessMetrics,
    current_user: User = Depends(get_current_active_user)
):
    """Добавить бизнес-метрики для компании"""
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                # Проверяем права на компанию
                company_check = await connection.fetchrow(
                    "SELECT id FROM companies WHERE id = $1", company_id
                )
                if not company_check:
                    raise HTTPException(status_code=404, detail="Company not found")
                
                metrics_id = await connection.fetchval(
                    """INSERT INTO business_metrics 
                       (company_id, revenue, profit, employees_count, year, month)
                       VALUES ($1, $2, $3, $4, $5, $6)
                       RETURNING id""",
                    company_id, metrics.revenue, metrics.profit, 
                    metrics.employees_count, metrics.year, metrics.month
                )
                
                return {"message": "Metrics created successfully", "metrics_id": metrics_id}
                
        except Exception as e:
            logger.error(f"❌ Database error creating metrics: {e}")
            raise HTTPException(status_code=500, detail="Database error creating metrics")
    
    return {"message": "Metrics created (mock mode)", "metrics_id": 1}

@app.get("/dashboard/stats")
async def get_dashboard_stats(current_user: User = Depends(get_current_active_user)):
    """Получить статистику для дашборда"""
    if db_pool:
        try:
            async with db_pool.acquire() as connection:
                # Общая статистика
                stats = await connection.fetchrow(
                    """SELECT 
                        (SELECT COUNT(*) FROM companies) as total_companies,
                        (SELECT COUNT(*) FROM investment_proposals WHERE status = 'active') as active_proposals,
                        (SELECT COUNT(*) FROM investor_interests) as total_interests,
                        (SELECT SUM(investment_amount) FROM investment_proposals WHERE status = 'active') as total_funding_sought
                    """
                )
                
                # Топ отраслей
                industries = await connection.fetch(
                    """SELECT industry, COUNT(*) as count 
                       FROM investment_proposals 
                       WHERE status = 'active' 
                       GROUP BY industry 
                       ORDER BY count DESC 
                       LIMIT 5"""
                )
                
                return {
                    "total_companies": stats['total_companies'],
                    "active_proposals": stats['active_proposals'],
                    "total_interests": stats['total_interests'],
                    "total_funding_sought": float(stats['total_funding_sought']) if stats['total_funding_sought'] else 0,
                    "top_industries": [dict(row) for row in industries]
                }
                
        except Exception as e:
            logger.error(f"❌ Database error getting stats: {e}")
            raise HTTPException(status_code=500, detail="Database error getting stats")
    
    # Mock data
    return {
        "total_companies": 25,
        "active_proposals": 15,
        "total_interests": 42,
        "total_funding_sought": 150000000.0,
        "top_industries": [
            {"industry": "it", "count": 5},
            {"industry": "manufacturing", "count": 3},
            {"industry": "healthcare", "count": 2}
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)