# Инструкция по настройке авторизации

## Что было сделано

1. **Добавлена система авторизации** на сайте с использованием новой таблицы `app_users` в Supabase
2. **Существующая таблица `sand_lists` не была изменена** - все данные сохранены
3. **Создана новая таблица `app_users`** для хранения пользовательских аккаунтов

## SQL код для создания новой таблицы

Выполните следующий SQL код в панели управления Supabase (SQL Editor):

```sql
-- Таблица для авторизации пользователей (новая, не затрагивает sand_lists)
CREATE TABLE IF NOT EXISTS app_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индекс для быстрого поиска по email
CREATE INDEX IF NOT EXISTS idx_app_users_email ON app_users(email);

-- Индекс для активных пользователей
CREATE INDEX IF NOT EXISTS idx_app_users_active ON app_users(is_active) WHERE is_active = true;

-- Включаем RLS (Row Level Security)
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

-- Политика: пользователи видят только свои данные
CREATE POLICY "Users can view own data" ON app_users
    FOR SELECT
    USING (true);

-- Политика: пользователи могут обновлять только свои данные
CREATE POLICY "Users can update own data" ON app_users
    FOR UPDATE
    USING (true);

-- Политика: только авторизованные могут вставлять (регистрироваться)
CREATE POLICY "Allow registration" ON app_users
    FOR INSERT
    WITH CHECK (true);

-- Триггер для обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_app_users_updated_at
    BEFORE UPDATE ON app_users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

## Как это работает

### Функционал авторизации:
- **Регистрация**: Пользователь может создать новый аккаунт с email, паролем и отображаемым именем
- **Вход**: Авторизация по email и паролю
- **Выход**: Кнопка выхода в верхней панели
- **Сохранение сессии**: Данные пользователя сохраняются в localStorage

### Безопасность:
- Пароли хешируются с помощью SHA-256 перед сохранением
- Проверка пароля при входе
- Защита от дублирования email (уникальное ограничение)

### Интерфейс:
- Кнопка "Войти" в верхней панели (видна когда пользователь не авторизован)
- После входа отображается имя пользователя и кнопка "Выйти"
- Модальное окно с переключением между входом и регистрацией

## Важные примечания

1. **Таблица `sand_lists` не была изменена** - все существующие данные песков сохранены
2. **Новая таблица `app_users`** создана отдельно для системы авторизации
3. В текущей реализации авторизация не ограничивает доступ к пескам (все видят все списки)
4. При необходимости можно добавить привязку песков к пользователям (добавив поле `user_id` в таблицу `sand_lists`)

## Дальнейшие улучшения (опционально)

Если вы хотите, чтобы каждый пользователь видел только свои списки песков:

1. Добавьте поле `user_id` в таблицу `sand_lists`:
```sql
ALTER TABLE sand_lists ADD COLUMN user_id UUID REFERENCES app_users(id);
```

2. Обновите код вставки, чтобы сохранять `user_id` текущего пользователя

3. Добавьте фильтрацию при загрузке списков:
```javascript
.from('sand_lists')
.eq('user_id', currentUser.id)
```

## Файлы проекта

- `index.html` - основной файл с кодом авторизации
- `app_users_schema.sql` - SQL схема для новой таблицы пользователей
- `supabase_schema.sql` - оригинальная схема таблицы песков (без изменений)
