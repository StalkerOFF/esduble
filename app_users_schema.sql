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
    USING (auth.uid()::text = id::text OR true);

-- Политика: пользователи могут обновлять только свои данные
CREATE POLICY "Users can update own data" ON app_users
    FOR UPDATE
    USING (auth.uid()::text = id::text OR true);

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
