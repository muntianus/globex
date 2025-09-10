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

# Mock database with correct admin password hash
fake_users_db = {
    "admin": {
        "username": "admin",
        "full_name": "Administrator",
        "email": "admin@globex.com",
        "hashed_password": "$2b$12$BYWjSXn3ZkfXjXZfOJLeouR.kb1vnYy1SW1uP6jiBGnfj8TMCtaHG",  # admin password
        "disabled": False,
    }
}

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)

def authenticate_user(fake_db, username: str, password: str):
    logger.info(f"🔐 Authenticating user: {username}")
    user = get_user(fake_db, username)
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
    user = get_user(fake_users_db, username=token_data.username)
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
    return {"message": "Globex B2B Marketplace API is running! 🚀", "timestamp": datetime.now()}

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    logger.info(f"🔐 Login attempt for username: {form_data.username}")
    
    user = authenticate_user(fake_users_db, form_data.username, form_data.password)
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
    
    # In real implementation, this would save to database
    company_data = company.dict()
    company_data["id"] = 1  # Mock ID
    company_data["created_by"] = current_user.username
    company_data["created_at"] = datetime.now()
    
    logger.info(f"✅ Company created successfully: {company.name}")
    return {"message": "Company created successfully", "company": company_data}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)