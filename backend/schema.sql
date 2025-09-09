-- =====================================================
-- Globex B2B Маркетплейс - Полная схема базы данных
-- =====================================================

-- Удалить существующие таблицы и создать заново
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS company_services CASCADE;
DROP TABLE IF EXISTS company_tags CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- =====================================================
-- Таблица пользователей
-- =====================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(150) UNIQUE NOT NULL,
    email VARCHAR(255),
    full_name VARCHAR(255),
    hashed_password TEXT NOT NULL,
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Таблица категорий
-- =====================================================
CREATE TABLE categories (
    id VARCHAR(50) PRIMARY KEY,
    name_key VARCHAR(100) NOT NULL,
    icon VARCHAR(10) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Таблица компаний
-- =====================================================
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id VARCHAR(50) REFERENCES categories(id),
    description TEXT NOT NULL,
    rating DECIMAL(2,1) DEFAULT 0.0,
    reviews_count INTEGER DEFAULT 0,
    verified BOOLEAN DEFAULT FALSE,
    inn VARCHAR(20) NOT NULL,
    region VARCHAR(100) NOT NULL,
    year_founded INTEGER NOT NULL,
    employees VARCHAR(20) NOT NULL,
    logo VARCHAR(10) DEFAULT '🏢',
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    website VARCHAR(255) NOT NULL,
    completed_deals INTEGER DEFAULT 0,
    response_time VARCHAR(50) DEFAULT '24 часа',
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Таблица тегов компаний
-- =====================================================
CREATE TABLE company_tags (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id) ON DELETE CASCADE,
    tag VARCHAR(100) NOT NULL
);

-- =====================================================
-- Таблица услуг компаний
-- =====================================================
CREATE TABLE company_services (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id) ON DELETE CASCADE,
    service VARCHAR(255) NOT NULL
);

-- =====================================================
-- Таблица отзывов
-- =====================================================
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id) ON DELETE CASCADE,
    author VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text TEXT NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Индексы для производительности
-- =====================================================
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_companies_category ON companies(category_id);
CREATE INDEX idx_companies_region ON companies(region);
CREATE INDEX idx_companies_verified ON companies(verified);
CREATE INDEX idx_companies_rating ON companies(rating);
CREATE INDEX idx_reviews_company ON reviews(company_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- =====================================================
-- Триггеры для обновления времени
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at 
    BEFORE UPDATE ON companies 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Начальные данные: Категории
-- =====================================================
INSERT INTO categories (id, name_key, icon) VALUES
('all', 'allCategories', '📋'),
('manufacturing', 'manufacturing', '🏭'),
('logistics', 'logistics', '🚛'),
('it', 'itServices', '💻'),
('construction', 'construction', '🏗️'),
('consulting', 'consulting', '⚖️');

-- =====================================================
-- Начальные данные: Пользователи
-- =====================================================
INSERT INTO users (username, email, full_name, hashed_password, disabled) VALUES
('admin', 'admin@globex.com', 'System Administrator', '$2b$12$BYWjSXn3ZkfXjXZfOJLeouR.kb1vnYy1SW1uP6jiBGnfj8TMCtaHG', FALSE);

-- =====================================================
-- Начальные данные: Компании
-- =====================================================
INSERT INTO companies (
    name, category_id, description, rating, reviews_count, verified, inn, region, 
    year_founded, employees, logo, phone, email, website, completed_deals, response_time
) VALUES
('ТехноПром', 'manufacturing', 'Производство промышленного оборудования', 4.8, 127, TRUE, 
 '7725123456', 'Москва', 2015, '100-500', '🏭', '+7 (495) 123-45-67', 
 'info@technoprom.ru', 'technoprom.ru', 342, '2 часа'),

('ЛогистикПро', 'logistics', 'Грузоперевозки по России и СНГ', 4.6, 89, TRUE, 
 '7726234567', 'Санкт-Петербург', 2018, '50-100', '🚛', '+7 (812) 234-56-78', 
 'cargo@logisticpro.ru', 'logisticpro.ru', 567, '30 минут'),

('ДигиталСофт', 'it', 'Разработка корпоративного ПО', 4.9, 156, TRUE, 
 '7727345678', 'Москва', 2012, '10-50', '💻', '+7 (495) 345-67-89', 
 'hello@digitalsoft.ru', 'digitalsoft.ru', 234, '1 час'),

('СтройМатериал', 'construction', 'Поставка строительных материалов', 4.5, 203, FALSE, 
 '7728456789', 'Екатеринбург', 2010, '100-500', '🏗️', '+7 (343) 456-78-90', 
 'sales@stroymaterial.ru', 'stroymaterial.ru', 891, '3 часа'),

('КонсалтПлюс', 'consulting', 'Юридические и бухгалтерские услуги', 4.7, 67, TRUE, 
 '7729567890', 'Москва', 2008, '10-50', '⚖️', '+7 (495) 567-89-01', 
 'info@consultplus.ru', 'consultplus.ru', 445, '1 час');

-- =====================================================
-- Начальные данные: Теги компаний
-- =====================================================
INSERT INTO company_tags (company_id, tag) VALUES
(1, 'Быстрая доставка'), (1, 'Гарантия качества'),
(2, 'Страхование груза'), (2, 'GPS-трекинг'),
(3, 'Agile'), (3, 'Поддержка 24/7'),
(4, 'Оптовые цены'), (4, 'Доставка'),
(5, 'Аудит'), (5, 'Налоговое планирование');

-- =====================================================
-- Начальные данные: Услуги компаний
-- =====================================================
INSERT INTO company_services (company_id, service) VALUES
(1, 'Производство на заказ'), (1, 'Консультации'), (1, 'Монтаж'),
(2, 'FTL перевозки'), (2, 'LTL перевозки'), (2, 'Таможенное оформление'),
(3, 'Web-разработка'), (3, 'Мобильные приложения'), (3, 'Интеграции'),
(4, 'Оптовые поставки'), (4, 'Розница'), (4, 'Доставка на объект'),
(5, 'Бухгалтерский учет'), (5, 'Юридическое сопровождение'), (5, 'Аудит');

-- =====================================================
-- Начальные данные: Отзывы
-- =====================================================
INSERT INTO reviews (company_id, author, rating, text, date) VALUES
(1, 'ООО "СтройКом"', 5, 'Отличное качество продукции, всегда в срок', '2024-11-15'),
(1, 'ЗАО "МегаСтрой"', 4, 'Хороший сервис, но цены выше рынка', '2024-10-22'),
(2, 'ИП Петров', 5, 'Всегда довозят в срок, груз в сохранности', '2024-11-20'),
(2, 'ООО "ТоргСеть"', 4, 'Хорошая компания, рекомендую', '2024-11-10'),
(3, 'АО "ФинТех"', 5, 'Профессиональная команда, сделали отличный продукт', '2024-11-18'),
(4, 'ООО "СтройГрад"', 4, 'Большой ассортимент, приемлемые цены', '2024-11-12'),
(5, 'ИП Иванова', 5, 'Помогли оптимизировать налоги, спасибо!', '2024-11-05');