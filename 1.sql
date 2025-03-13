-- Создаю таблицу events
CREATE TABLE IF NOT EXISTS events (
    userId INT,             -- Уникальный идентификатор пользователя
    eventName VARCHAR(50),  -- Тип события (register, download и т. д.)
    time TIMESTAMP,         -- Время события
    product VARCHAR(50)     -- Продукт
);

-- Очистка таблицы перед добавлением данных
TRUNCATE TABLE events;

-- Вставка тестовых данных для проверки запроса
INSERT INTO events (userId, eventName, time, product)
VALUES
    -- Пользователи, зарегистрировавшиеся после 2023-03-01
    (1, 'register', '2023-03-06 10:00:00', NULL),
    (1, 'download', '2023-03-07 11:00:00', 'p1'),
    
    (2, 'register', '2023-03-06 12:00:00', NULL),
    (2, 'download', '2023-03-07 14:00:00', 'p2'),
    
    (3, 'register', '2023-03-08 08:30:00', NULL),
    
    (4, 'register', '2023-03-13 15:00:00', NULL),
    (4, 'download', '2023-03-14 16:30:00', 'p3'),

    (5, 'register', '2023-03-13 17:00:00', NULL),

    (6, 'register', '2023-03-20 18:00:00', NULL),
    (6, 'download', '2023-03-21 19:00:00', 'p2'),
    
    (7, 'register', '2023-03-20 20:00:00', NULL),

    -- Пользователь, который зарегистрировался, но загрузку не сделал
    (8, 'register', '2023-03-22 14:00:00', NULL);

-- Анализ когорт и расчет конверсии в первую загрузку

WITH registration_dates AS (
    -- Определяем дату регистрации каждого пользователя
    SELECT 
        userId,
        DATE_TRUNC('week', MIN(time)) AS reg_week  -- Округляем дату регистрации до недели
    FROM events
    WHERE eventName = 'register' AND time >= '2023-03-01'
    GROUP BY userId
),

first_download AS (
    -- Определяем дату первой загрузки приложения пользователем
    SELECT 
        userId, 
        DATE_TRUNC('week', MIN(time)) AS download_week  -- Округляем дату загрузки до недели
    FROM events
    WHERE eventName = 'download'
    GROUP BY userId
),

cohort_analysis AS (
    -- Объединяем данные о регистрации и первой загрузке
    SELECT 
        r.reg_week,
        COUNT(r.userId) AS total_users,  -- Количество пользователей в когорте
        COUNT(d.userId) FILTER (WHERE d.download_week = r.reg_week) AS downloaded_users  -- Число пользователей, скачавших приложение в неделю регистрации
    FROM registration_dates r
    LEFT JOIN first_download d ON r.userId = d.userId
    GROUP BY r.reg_week
)

-- Рассчитываем конверсию (CR) и выводим результат
SELECT 
    reg_week AS week,  -- Неделя когорты
    total_users AS users,  -- Количество пользователей в когорте
    ROUND(
        COALESCE(downloaded_users * 100.0 / NULLIF(total_users, 0), 0), 2
    ) AS CR  -- Конверсия (в процентах)
FROM cohort_analysis
ORDER BY week;
