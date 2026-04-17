# 🔐 Авторизация и Администрирование

## 📋 Что реализовано

### 1. Новая таблица `app_users` (не трогает `sand_lists`)
- Хранение пользователей с хешированными паролями
- Поля: email, password_hash, display_name, role, is_active, last_login

### 2. Таблица настроек `auth_settings`
- Управление регистрацией (включить/выключить)
- Белый список email для регистрации

### 3. 4 предустановленных админа
| Логин | Пароль | Роль |
|-------|--------|------|
| admin1@sandtracker.ru | Admin123! | admin |
| admin2@sandtracker.ru | Admin123! | admin |
| admin3@sandtracker.ru | Admin123! | admin |
| admin4@sandtracker.ru | Admin123! | admin |

### 4. Режимы доступа
- **Запрет регистрации** - только предустановленные пользователи
- **Белый список** - регистрация только для указанных email
- **Открытая регистрация** - любой может зарегистрироваться

---

## 🚀 Установка

### Шаг 1: Выполните SQL в Supabase

1. Откройте [Supabase Dashboard](https://supabase.com/dashboard)
2. Перейдите в **SQL Editor**
3. Скопируйте и выполните содержимое файла `app_users_schema.sql`

```sql
-- Выполните весь файл app_users_schema.sql
-- Он создаст:
-- - таблицу app_users
-- - таблицу auth_settings  
-- - 4 админских аккаунта
-- - политики безопасности
```

### Шаг 2: Настройте доступ

По умолчанию регистрация **ЗАПРЕЩЕНА** - могут войти только 4 админа.

Для управления используйте команды ниже:

```sql
-- ✅ Разрешить регистрацию всем
UPDATE auth_settings SET is_registration_allowed = true WHERE id = 1;

-- ✅ Запретить регистрацию (только админы)
UPDATE auth_settings 
SET is_registration_allowed = false, allowed_emails = ARRAY[]::TEXT[] 
WHERE id = 1;

-- ✅ Белый список email
UPDATE auth_settings 
SET is_registration_allowed = false,
    allowed_emails = ARRAY['user1@company.com', 'user2@company.com']
WHERE id = 1;
```

---

## 👥 Управление пользователями

### Просмотр всех пользователей
```sql
SELECT id, email, display_name, role, is_active, created_at 
FROM app_users ORDER BY created_at DESC;
```

### Заблокировать пользователя
```sql
UPDATE app_users SET is_active = false WHERE email = 'user@example.com';
```

### Разблокировать пользователя
```sql
UPDATE app_users SET is_active = true WHERE email = 'user@example.com';
```

### Сделать пользователя админом
```sql
UPDATE app_users SET role = 'admin' WHERE email = 'user@example.com';
```

### Удалить пользователя
```sql
DELETE FROM app_users WHERE email = 'user@example.com';
```

---

## 🎯 Сценарии использования

### Сценарий 1: Только админы (рекомендуется)
```sql
UPDATE auth_settings 
SET is_registration_allowed = false, 
    allowed_emails = ARRAY[]::TEXT[]
WHERE id = 1;
```
✅ Могут войти: admin1-4@sandtracker.ru  
❌ Все остальные: не могут зарегистрироваться

### Сценарий 2: Закрытая компания
```sql
UPDATE auth_settings 
SET is_registration_allowed = false,
    allowed_emails = ARRAY[
        'ivanov@company.ru',
        'petrov@company.ru',
        'sidorov@company.ru'
    ]
WHERE id = 1;
```
✅ Могут зарегистрироваться: только из списка  
❌ Все остальные: не могут

### Сценарий 3: Открытая регистрация
```sql
UPDATE auth_settings SET is_registration_allowed = true WHERE id = 1;
```
✅ Может зарегистрироваться: любой

---

## 🔧 Как это работает

1. **При попытке регистрации:**
   - Проверяется таблица `auth_settings`
   - Если `is_registration_allowed = true` → регистрация разрешена
   - Если email в `allowed_emails` → регистрация разрешена
   - Иначе → ошибка "Регистрация запрещена"

2. **При входе:**
   - Проверяется email и пароль
   - Проверяется `is_active = true`
   - При успехе → обновление `last_login`

3. **RLS политики:**
   - Пользователи видят только свои данные
   - Регистрация контролируется через `auth_settings`

---

## 📁 Файлы

| Файл | Описание |
|------|----------|
| `app_users_schema.sql` | Создание таблиц и 4 админов |
| `index.html` | Обновлён с проверкой регистрации |

---

## ⚠️ Важно

- ✅ Таблица `sand_lists` **НЕ ИЗМЕНЕНА**
- ✅ Все старые данные сохранены
- ✅ Используется новая таблица `app_users`
- ✅ Пароли хешируются через SHA-256
- ✅ RLS защищает данные пользователей
