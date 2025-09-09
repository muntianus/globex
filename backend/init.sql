-- =====================================================
-- Globex B2B Маркетплейс - Инициализация базы данных
-- =====================================================
-- Этот файл автоматически выполняется при первом запуске
-- PostgreSQL контейнера (docker-compose)
-- 
-- Назначение: Настройка начальной схемы базы данных и тестовых данных
-- Расположение: Монтируется в /docker-entrypoint-initdb.d/init.sql
-- =====================================================

-- Включить расширение UUID для генерации уникальных идентификаторов
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Таблица пользователей
-- =====================================================
-- Хранит учетные записи пользователей для аутентификации и профильных данных
-- Соответствует модели UserInDB в backend/main.py
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,                    -- Автоинкрементный первичный ключ
    username VARCHAR(150) UNIQUE NOT NULL,    -- Уникальное имя пользователя для входа
    email VARCHAR(255),                       -- Email адрес пользователя
    full_name VARCHAR(255),                   -- Отображаемое имя
    hashed_password TEXT NOT NULL,            -- Bcrypt хешированный пароль
    disabled BOOLEAN DEFAULT FALSE,           -- Флаг статуса аккаунта
    created_at TIMESTAMPTZ DEFAULT NOW(),     -- Временная метка создания аккаунта
    updated_at TIMESTAMPTZ DEFAULT NOW()      -- Временная метка последнего изменения
);

-- Создать индекс по имени пользователя для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- =====================================================
-- Таблица компаний (Будущая функция B2B Маркетплейса)
-- =====================================================
-- Заглушка для профилей компаний в маркетплейсе
CREATE TABLE IF NOT EXISTS companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    industry VARCHAR(100),
    website VARCHAR(255),
    contact_email VARCHAR(255),
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Таблица продуктов/услуг (Будущая функция B2B Маркетплейса)
-- =====================================================
-- Заглушка для продуктов/услуг, предлагаемых компаниями
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Тестовые данные (Только для разработки)
-- =====================================================
-- ВНИМАНИЕ: Это только значения по умолчанию для разработки!
-- В продакшене создавайте пользователей через API endpoint регистрации

-- Пользователь администратора по умолчанию (пароль: 'admin' - ИЗМЕНИТЕ В ПРОДАКШЕНЕ!)
-- Хеш пароля ниже для 'admin' используя bcrypt
-- Для генерации новых хешей используйте: python -c "from passlib.context import CryptContext; print(CryptContext(schemes=['bcrypt']).hash('your_password'))"
INSERT INTO users (username, email, full_name, hashed_password, disabled) 
VALUES (
    'admin', 
    'admin@globex.com', 
    'System Administrator', 
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8Kz8Kz2', -- 'admin'
    FALSE
) ON CONFLICT (username) DO NOTHING;

-- =====================================================
-- Триггеры для временных меток обновления
-- =====================================================
-- Автоматически обновлять колонку updated_at при изменении записей

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Применить триггер к таблице пользователей
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Применить триггер к таблице компаний
DROP TRIGGER IF EXISTS update_companies_updated_at ON companies;
CREATE TRIGGER update_companies_updated_at 
    BEFORE UPDATE ON companies 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Применить триггер к таблице продуктов
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Настройка базы данных завершена
-- =====================================================
-- База данных готова для приложения Globex B2B Маркетплейс
-- 
-- Следующие шаги:
-- 1. Запустить backend сервис: uvicorn main:app --reload
-- 2. Протестировать API endpoints по адресу: http://localhost:8000/docs
-- 3. Войти с admin/admin для получения JWT токена
-- =====================================================

