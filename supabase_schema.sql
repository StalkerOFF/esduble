-- Создаем таблицу для списков песка
CREATE TABLE IF NOT EXISTS sand_lists (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    rop VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    work_type VARCHAR(20) NOT NULL CHECK (work_type IN ('офис', 'удаленка')),
    names TEXT NOT NULL,
    checkboxes JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индекс для сортировки по дате создания
CREATE INDEX IF NOT EXISTS idx_sand_lists_created_at ON sand_lists(created_at DESC);

-- Включаем RLS (Row Level Security)
ALTER TABLE sand_lists ENABLE ROW LEVEL SECURITY;

-- Создаем политику для разрешения всех операций анонимным пользователям
-- В продакшене рекомендуется настроить более строгие политики
CREATE POLICY "Allow all access to sand_lists" ON sand_lists
    FOR ALL
    USING (true)
    WITH CHECK (true);
