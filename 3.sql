-- Создаем таблицу событий
CREATE TABLE IF NOT EXISTS events (
    userId INT,            -- Уникальный идентификатор пользователя
    eventName VARCHAR(50), -- Тип события (register, download, buy и т. д.)
    time TIMESTAMP,        -- Время события
    product VARCHAR(50)    -- Продукт, связанный с событием 
);

TRUNCATE TABLE events;

INSERT INTO events (userId, eventName, time, product)
VALUES
    (21, 'register', '2023-02-15 10:00:00', NULL),
    (21, 'download', '2023-02-16 11:00:00', 'p1'),
    (21, 'buy', '2023-02-20 13:00:00', 'p1'),
    
    (22, 'register', '2023-02-20 09:00:00', NULL),
    (22, 'download', '2023-02-22 12:00:00', 'p2'),
    (22, 'buy', '2023-02-25 14:00:00', 'p2'),
    
    (23, 'register', '2023-02-22 11:00:00', NULL),
    (23, 'download', '2023-02-23 14:00:00', 'p3'),
    (23, 'buy', '2023-02-26 15:00:00', 'p3'),
    
    (24, 'register', '2023-03-01 10:00:00', NULL),
    (24, 'download', '2023-03-03 11:00:00', 'p4'),
    (24, 'buy', '2023-03-07 12:00:00', 'p4'),
    
    (25, 'register', '2023-03-02 08:00:00', NULL),
    (25, 'download', '2023-03-04 14:00:00', 'p5'),
    (25, 'buy', '2023-03-08 15:00:00', 'p5'),
    
    (26, 'register', '2023-03-05 10:00:00', NULL),
    (26, 'download', '2023-03-06 11:00:00', 'p6'),
    (26, 'buy', '2023-03-10 13:00:00', 'p6'),
    (27, 'register', '2023-03-06 08:00:00', NULL),
    (27, 'download', '2023-03-07 09:00:00', 'p1'),
    (27, 'pageVisit', '2023-03-08 10:00:00', 'p1'),
    
    (28, 'register', '2023-03-09 07:00:00', NULL),
    (28, 'download', '2023-03-10 09:00:00', 'p2'),
    
    (29, 'register', '2023-03-10 11:00:00', NULL),
    (29, 'download', '2023-03-11 13:00:00', 'p3'),
    (30, 'register', '2022-12-20 09:00:00', NULL),
    (30, 'download', '2022-12-21 10:00:00', 'p1'),
    (30, 'buy', '2022-12-22 14:00:00', 'p1'),
    
    (31, 'register', '2022-12-25 10:00:00', NULL),
    (31, 'download', '2022-12-26 11:00:00', 'p2'),
    (31, 'buy', '2022-12-28 12:00:00', 'p2'),
    
    (32, 'register', '2022-12-29 13:00:00', NULL),
    (32, 'download', '2022-12-30 14:00:00', 'p3'),
    (32, 'buy', '2023-01-02 11:00:00', 'p3'),
    
    (33, 'register', '2022-12-31 15:00:00', NULL),
    (33, 'download', '2023-01-01 16:00:00', 'p4'),
    (33, 'buy', '2023-01-03 13:00:00', 'p4'),
    
    (34, 'register', '2022-12-15 09:30:00', NULL),
    (34, 'download', '2022-12-17 10:30:00', 'p5'),
    (34, 'buy', '2022-12-20 12:00:00', 'p5'),
    
    (35, 'register', '2022-12-18 11:30:00', NULL),
    (35, 'download', '2022-12-20 14:00:00', 'p6'),
    (35, 'buy', '2022-12-22 15:00:00', 'p6'),
    (36, 'register', '2022-12-01 12:00:00', NULL),
    (36, 'download', '2022-12-02 13:00:00', 'p1'),
    (36, 'buy', '2022-12-03 14:00:00', 'p1'),
    
    (37, 'register', '2022-12-10 10:00:00', NULL),
    (37, 'download', '2022-12-12 11:00:00', 'p2'),
    (37, 'buy', '2022-12-15 12:00:00', 'p2'),
    
    (38, 'register', '2022-12-20 13:00:00', NULL),
    (38, 'download', '2022-12-22 14:00:00', 'p3'),
    (38, 'buy', '2022-12-25 15:00:00', 'p3'),
    
    (39, 'register', '2022-12-28 09:00:00', NULL),
    (39, 'download', '2022-12-29 10:00:00', 'p4'),
    (39, 'buy', '2023-01-02 11:00:00', 'p4'),
    (40, 'register', '2022-11-30 10:00:00', NULL),
    (40, 'download', '2023-01-01 12:00:00', 'p5'),
    (40, 'buy', '2023-01-03 13:00:00', 'p5');
-- SELECT * FROM events;

-- Основная логика
WITH registration_dates AS (
    -- Определяем дату регистрации для каждого пользователя (первая регистрация)
    SELECT 
        userId, 
        MIN(time)::DATE AS registered
    FROM events
    WHERE eventName = 'register' AND time >= '2023-01-01'::DATE
    GROUP BY userId
),
total_users_per_week AS (
    -- Подсчитываем количество пользователей, зарегистрированных в каждую неделю
    SELECT 
        DATE_TRUNC('week', registered) AS week, -- Определяем неделю регистрации
        COUNT(DISTINCT userId) AS total_users  -- Количество пользователей в этой неделе
    FROM registration_dates
    GROUP BY week
),
buyers_per_product AS (
    -- Определяем, какие продукты покупали пользователи в первую неделю после регистрации
    SELECT 
        DATE_TRUNC('week', r.registered) AS week,  -- Неделя регистрации
        p.product,                                -- Название продукта
        COUNT(DISTINCT r.userId) AS buyers       -- Количество уникальных покупателей
    FROM registration_dates r
    JOIN events p 
        ON r.userId = p.userId 
        AND p.eventName = 'buy' 
        AND p.time::DATE BETWEEN r.registered AND r.registered + INTERVAL '7 days' -- Фильтруем покупки в первую неделю
    WHERE p.product IS NOT NULL
    GROUP BY week, p.product
),
cr_data AS (
    -- Вычисляем конверсию в покупку (CR) для каждой недели
    SELECT 
        b.week,                 -- Неделя регистрации
        b.product,              -- Продукт
        t.total_users,          -- Общее число зарегистрированных пользователей в эту неделю
        b.buyers,               -- Число пользователей, купивших продукт
        ROUND(100.0 * b.buyers / NULLIF(t.total_users, 0), 2) AS cr  -- Конверсия (CR = % покупателей)
    FROM buyers_per_product b
    JOIN total_users_per_week t 
        ON b.week = t.week
),
best_week AS (
    -- Выбираем неделю с наибольшей конверсией (если несколько - берем первую)
    SELECT week
    FROM cr_data
    ORDER BY cr DESC
    LIMIT 1
),
top_products AS (
    -- Определяем топ-3 продукта по количеству покупателей в выбранной неделе
    SELECT 
        c.week, 
        c.product, 
        RANK() OVER (PARTITION BY c.week ORDER BY c.buyers DESC) AS rating  -- Присваиваем рейтинг по количеству покупателей
    FROM cr_data c
    JOIN best_week bw ON c.week = bw.week
)
-- Выводим итоговую таблицу с ТОП-3 продуктами
SELECT week, product, rating
FROM top_products
WHERE rating <= 3
ORDER BY week, rating;