# Globex Monorepo

## Обзор
Это монорепозиторий B2B маркетплейса, содержащий три основных приложения и поддерживающую инфраструктуру:

- **backend**: FastAPI сервис с JWT аутентификацией, управлением пользователями и API endpoints
- **frontend**: React приложение, созданное с помощью Create React App и TypeScript для веб-интерфейса
- **b2b_marketplace_app**: Flutter мультиплатформенное мобильное/десктопное приложение
- **docker-compose**: Полный стек локальной разработки с frontend, backend, PostgreSQL базой данных и nginx reverse proxy

## Архитектура
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Flutter App   │
│   (React)       │◄──►│   (FastAPI)     │◄──►│   (Mobile/Web)  │
│   Порт: 3000    │    │   Порт: 8000    │    │   Мультиплатформа│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┼───────────────────────────────┐
                                 │                               │
                    ┌─────────────────┐              ┌─────────────────┐
                    │   PostgreSQL    │              │     Nginx       │
                    │   Порт: 5432    │              │  Порты: 80/443  │
                    └─────────────────┘              └─────────────────┘
```

## Требования
- **Docker и Docker Compose** - для контейнеризованной среды разработки
- **Node.js 18 LTS** - используйте `.nvmrc` в директории frontend для управления версиями
- **Python 3.11+** - для разработки backend
- **Flutter SDK** - для разработки мобильных/десктопных приложений (опционально, если используете только веб)

## Быстрый старт (Docker)

### Первоначальная настройка
1. **SSL сертификаты**: Убедитесь, что директория `ssl/` существует с сертификатами (см. `ssl/README.md` для настройки)
2. **Схема базы данных**: `backend/init.sql` предоставляет базовую схему (уже включена)
3. **Переменные окружения**: Скопируйте примеры файлов и настройте по необходимости

### Запуск всех сервисов
```bash
docker compose up --build
```

### URL сервисов
- **Frontend**: http://localhost:3000 (React development server)
- **Backend API**: http://localhost:8000 (FastAPI с автоперезагрузкой)
- **API документация**: http://localhost:8000/docs (Swagger UI)
- **Nginx Reverse Proxy**: http://localhost (HTTP), https://localhost (HTTPS)
- **PostgreSQL**: localhost:5432 (подключение к базе данных)

## Локальная разработка (без Docker)

### Разработка Backend
```bash
cd backend
python -m venv .venv && source .venv/bin/activate  # Создать виртуальное окружение
pip install -r requirements.txt                    # Установить зависимости
export SECRET_KEY="dev-secret"                     # Установить переменную окружения
uvicorn main:app --reload --host 0.0.0.0 --port 8000  # Запустить сервер разработки
```

### Разработка Frontend
```bash
cd frontend
nvm use || echo "Используйте Node 18 LTS"          # Использовать правильную версию Node
npm install                                        # Установить зависимости
REACT_APP_API_URL=http://localhost:8000 npm start # Запустить сервер разработки
```

### Разработка Flutter приложения
```bash
cd b2b_marketplace_app
flutter pub get                                    # Установить зависимости
flutter run                                        # Запустить на подключенном устройстве/эмуляторе
```

## Конфигурация

### Переменные окружения
- **Frontend**: Скопируйте `frontend/env.example` в `frontend/.env` и настройте
- **Backend**: Скопируйте `backend/env.example` в `backend/.env` и настройте
- **Docker**: Переменные окружения установлены в `docker-compose.yml`

### Конфигурация базы данных
- **PostgreSQL**: Настроена в docker-compose с постоянным томом
- **Схема**: Начальная схема загружается из `backend/init.sql`
- **Подключение**: `postgresql://user:password@localhost:5432/globex`

## Тестирование

### Тестирование Frontend
```bash
cd frontend
npm test                    # Запустить Jest test suite
npm run test:coverage       # Запустить с отчетом покрытия
```

### Тестирование Backend
```bash
cd backend
pip install pytest         # Установить фреймворк тестирования
pytest                     # Запустить test suite
pytest --cov              # Запустить с покрытием
```

### Тестирование Flutter
```bash
cd b2b_marketplace_app
flutter test               # Запустить unit тесты
flutter test integration_test/  # Запустить интеграционные тесты
```

## API Endpoints

### Аутентификация
- `POST /token` - Вход и получение JWT токена
- `GET /users/me/` - Получить информацию о текущем пользователе (требует аутентификации)
- `POST /register/` - Регистрация нового пользователя

### Общие
- `GET /` - Приветственное сообщение
- `GET /docs` - Интерактивная документация API (Swagger UI)

## Заметки для разработки

### Важные файлы
- `docker-compose.yml` - Полная настройка среды разработки
- `frontend/nginx.conf` - Конфигурация Nginx для reverse proxy
- `backend/init.sql` - Инициализация схемы базы данных
- `ssl/README.md` - Инструкции по настройке SSL сертификатов

### Соображения безопасности
- **Никогда не коммитьте секреты** в систему контроля версий
- Используйте переменные окружения для чувствительной конфигурации
- Измените пароли по умолчанию и секретные ключи в продакшене
- SSL сертификаты должны быть правильно настроены для HTTPS

### Устранение неполадок
- **Конфликты портов**: Убедитесь, что порты 3000, 8000, 5432, 80, 443 доступны
- **Проблемы с SSL**: Проверьте директорию `ssl/` и валидность сертификатов
- **Подключение к базе данных**: Убедитесь, что PostgreSQL запущен и доступен
- **Сборка Frontend**: Убедитесь, что версия Node.js соответствует спецификации `.nvmrc`

