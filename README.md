# Песок - Трекер задач

Приложение для отслеживания задач по онбордингу сотрудников.

## Стек технологий

- **Frontend**: HTML, CSS, JavaScript (ванильный)
- **Backend**: Golang
- **База данных**: PostgreSQL 15
- **Веб-сервер**: Nginx
- **Контейнеризация**: Docker, Docker Compose

## Структура проекта

```
/workspace
├── backend/           # Go бэкенд
│   ├── main.go       # Основной код приложения
│   ├── go.mod        # Go модуль
│   └── Dockerfile    # Docker образ для бэкенда
├── frontend/          # Статический фронтенд
│   ├── index.html    # Основная страница
│   ├── login.html    # Страница входа
│   └── favicon.png   # Иконка
├── nginx/            # Конфигурация Nginx
│   └── default.conf  # Конфиг сервера
├── scripts/          # Скрипты БД
│   └── init.sql      # Инициализация БД
├── docker-compose.yml # Docker Compose конфигурация
├── Dockerfile.db     # Docker образ для PostgreSQL
└── Dockerfile.nginx  # Docker образ для Nginx
```

## Быстрый старт

### Запуск приложения

```bash
docker-compose up --build
```

Приложение будет доступно по адресу: http://localhost

### Остановка приложения

```bash
docker-compose down
```

### Остановка с удалением данных

```bash
docker-compose down -v
```

## Пользователи по умолчанию

| Логин   | Пароль      |
|---------|-------------|
| Stalker | 16084636    |
| Bob     | z53Z2OsJ1   |
| Apple   | z53Z2OsJ2   |
| Admin   | z53Z2OsJ67  |

## Переменные окружения

### Backend
- `DB_HOST` - хост базы данных (по умолчанию: postgres)
- `DB_PORT` - порт базы данных (по умолчанию: 5432)
- `DB_USER` - пользователь БД (по умолчанию: sanduser)
- `DB_PASSWORD` - пароль БД (по умолчанию: sandpass123)
- `DB_NAME` - имя базы данных (по умолчанию: sandtracker)
- `PORT` - порт бэкенда (по умолчанию: 8080)

### Database
- `POSTGRES_DB` - имя базы данных (по умолчанию: sandtracker)
- `POSTGRES_USER` - пользователь БД (по умолчанию: sanduser)
- `POSTGRES_PASSWORD` - пароль БД (по умолчанию: sandpass123)

## API Endpoints

### Аутентификация
- `POST /api/login` - Вход в систему

### Пески (списки задач)
- `GET /api/sand-lists` - Получить все списки
- `POST /api/sand-lists` - Создать новый список
- `PUT /api/sand-lists/{id}` - Обновить список
- `DELETE /api/sand-lists/{id}` - Удалить список
- `PATCH /api/sand-lists/{id}/checkboxes` - Обновить чекбоксы

## Архитектура

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│    Nginx    │────▶│   Backend   │
│  (Browser)  │◀────│   (Port 80) │◀────│  (Port 8080)│
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │  PostgreSQL │
                                        │  (Port 5432)│
                                        └─────────────┘
```

Nginx выступает в роли reverse proxy:
- Статические файлы (frontend) обслуживаются напрямую
- API запросы проксируются на Go бэкенд

## Разработка

### Сборка образов заново

```bash
docker-compose build --no-cache
```

### Просмотр логов

```bash
docker-compose logs -f
```

### Логи конкретного сервиса

```bash
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f nginx
```

## Безопасность

- Пароли хранятся в хешированном виде (SHA256)
- Сессии истекают через 1 час
- RLS (Row Level Security) включен для всех таблиц

## Лицензия

Приватный проект
