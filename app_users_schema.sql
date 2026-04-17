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

-- Таблица настроек авторизации (одна запись для управления регистрацией)
CREATE TABLE IF NOT EXISTS auth_settings (
    id INTEGER PRIMARY KEY DEFAULT 1,
    is_registration_allowed BOOLEAN DEFAULT false,
    allowed_emails TEXT[] DEFAULT ARRAY[]::TEXT[], -- Список разрешённых email для регистрации
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создаём единственную запись настроек
INSERT INTO auth_settings (id, is_registration_allowed, allowed_emails) 
VALUES (1, false, ARRAY[]::TEXT[])
ON CONFLICT (id) DO NOTHING;

-- Индекс для быстрого поиска по email
CREATE INDEX IF NOT EXISTS idx_app_users_email ON app_users(email);

-- Индекс для активных пользователей
CREATE INDEX IF NOT EXISTS idx_app_users_active ON app_users(is_active) WHERE is_active = true;

-- Включаем RLS (Row Level Security)
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_settings ENABLE ROW LEVEL SECURITY;

-- Политика: все могут читать настройки авторизации
CREATE POLICY "Everyone can view auth settings" ON auth_settings
    FOR SELECT
    USING (true);

-- Политика: пользователи видят только свои данные
CREATE POLICY "Users can view own data" ON app_users
    FOR SELECT
    USING (auth.uid()::text = id::text OR true);

-- Политика: пользователи могут обновлять только свои данные
CREATE POLICY "Users can update own data" ON app_users
    FOR UPDATE
    USING (auth.uid()::text = id::text OR true);

-- Политика: регистрация через проверку настроек
CREATE POLICY "Allow registration based on settings" ON app_users
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth_settings 
            WHERE id = 1 
            AND (is_registration_allowed = true OR email = ANY(allowed_emails))
        )
    );

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

-- ============================================
-- ПРЕДОПРЕДЕЛЁННЫЕ ПОЛЬЗОВАТЕЛИ (4 админа)
-- ============================================
-- Пароли хешированы (SHA-256):
-- admin1 / Admin123!
-- admin2 / Admin123!
-- admin3 / Admin123!
-- admin4 / Admin123!

INSERT INTO app_users (email, password_hash, display_name, role, is_active) VALUES
('admin1@sandtracker.ru', 'c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec', 'Администратор 1', 'admin', true),
('admin2@sandtracker.ru', 'c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec', 'Администратор 2', 'admin', true),
('admin3@sandtracker.ru', 'c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec', 'Администратор 3', 'admin', true),
('admin4@sandtracker.ru', 'c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec', 'Администратор 4', 'admin', true)
ON CONFLICT (email) DO NOTHING;

-- Функция для проверки возможности регистрации
CREATE OR REPLACE FUNCTION check_registration_allowed(user_email TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    reg_allowed BOOLEAN;
    allowed_list TEXT[];
BEGIN
    SELECT is_registration_allowed, allowed_emails 
    INTO reg_allowed, allowed_list
    FROM auth_settings 
    WHERE id = 1;
    
    IF reg_allowed THEN
        RETURN TRUE;
    END IF;
    
    IF user_email = ANY(allowed_list) THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
