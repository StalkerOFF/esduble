# 🔐 Авторизация на сайте "Песок - Трекер задач"

## Что реализовано

### 1. **Полная блокировка без авторизации**
- Без входа в систему **никакие данные не отображаются**
- Весь интерфейс размыт и заблокирован
- Данные из Supabase **не загружаются** до успешной авторизации
- При выходе данные очищаются из памяти

### 2. **Защита от просмотра через консоль (F12)**
- Перехвачены методы `console.log`, `console.warn`, `console.error`, `console.info`
- Блокируется вывод чувствительных данных (`sandLists`, `currentUser`)
- Переменные не доступны для прямого чтения через консоль

### 3. **4 предустановленных админа**
Только эти пользователи могут войти (регистрация запрещена по умолчанию):

| Email | Пароль |
|-------|--------|
| admin1@sandtracker.ru | Admin123! |
| admin2@sandtracker.ru | Admin123! |
| admin3@sandtracker.ru | Admin123! |
| admin4@sandtracker.ru | Admin123! |

### 4. **Управление доступом через SQL**

```sql
-- ЗАПРЕТИТЬ регистрацию (только 4 админа) - ПО УМОЛЧАНИЮ
UPDATE auth_settings 
SET is_registration_allowed = false, allowed_emails = ARRAY[]::TEXT[] 
WHERE id = 1;

-- РАЗРЕШИТЬ регистрацию всем
UPDATE auth_settings SET is_registration_allowed = true WHERE id = 1;

-- Белый список (только указанные email)
UPDATE auth_settings 
SET is_registration_allowed = false,
    allowed_emails = ARRAY['user@company.com', 'another@company.com'] 
WHERE id = 1;

-- Посмотреть текущие настройки
SELECT * FROM auth_settings WHERE id = 1;

-- Посмотреть всех пользователей
SELECT email, display_name, role, is_active, last_login FROM app_users;

-- Заблокировать пользователя
UPDATE app_users SET is_active = false WHERE email = 'user@example.com';

-- Разблокировать пользователя
UPDATE app_users SET is_active = true WHERE email = 'user@example.com';

-- Добавить нового админа вручную (с паролем Admin123!)
INSERT INTO app_users (email, password_hash, display_name, role, is_active)
VALUES ('newadmin@sandtracker.ru', 'c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec', 'Новый админ', 'admin', true);
```

## Установка

### Шаг 1: Выполните SQL схему
1. Откройте панель Supabase → SQL Editor
2. Вставьте содержимое файла `app_users_schema.sql`
3. Нажмите "Run"

⚠️ **Важно:** Таблица `sand_lists` остаётся без изменений!

### Шаг 2: Откройте сайт
- Без авторизации вы увидите экран с сообщением "🔐 Авторизация требуется"
- Все данные размыты и недоступны
- Нажмите "Войти в систему"

### Шаг 3: Войдите как админ
- Email: `admin1@sandtracker.ru` (или admin2-4)
- Пароль: `Admin123!`

## Как это работает

### Без авторизации:
1. ✅ Экран заблокирован overlay-элементом
2. ✅ Интерфейс размыт (blur + opacity)
3. ✅ Данные НЕ загружаются из Supabase
4. ✅ Консольные команды перехвачены
5. ✅ В localStorage нет чувствительных данных

### После авторизации:
1. ✅ Overlay скрывается
2. ✅ Интерфейс становится активным
3. ✅ Данные загружаются из Supabase
4. ✅ Отображается имя пользователя
5. ✅ Доступна кнопка "Выйти"

### При выходе:
1. ✅ Данные очищаются из памяти
2. ✅ localStorage очищается
3. ✅ Показывается экран авторизации
4. ✅ Интерфейс снова размывается

## Безопасность

### На уровне клиента:
- ✅ Блокировка UI до авторизации
- ✅ Перехват console.* методов
- ✅ Очистка памяти при выходе
- ✅ Хранение токена только в localStorage

### На уровне базы данных (RLS):
- ✅ Row Level Security включён
- ✅ Политика на чтение настроек
- ✅ Политика на регистрацию по whitelist
- ✅ Изоляция данных пользователей

## Примечания

- ⚠️ **Никакие изменения в таблице `sand_lists` не вносились**
- 🔒 Регистрация запрещена по умолчанию
- 👥 Только 4 предустановленных админа могут войти
- 📝 Для добавления пользователей используйте SQL или белый список
