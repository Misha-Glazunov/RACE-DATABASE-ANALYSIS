1.
WITH CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        RANK() OVER (PARTITION BY c.class ORDER BY AVG(r.position)) AS rank
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
)
SELECT 
    car_name,
    car_class,
    average_position,
    race_count
FROM CarStats
WHERE rank = 1
ORDER BY average_position;

2.
WITH CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        cl.country AS car_country,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        ROW_NUMBER() OVER (ORDER BY AVG(r.position), c.name) AS rn
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
)
SELECT 
    car_name,
    car_class,
    average_position,
    race_count,
    car_country
FROM CarStats
WHERE rn = 1;

3.
WITH ClassAvg AS (
    SELECT 
        c.class,
        AVG(r.position) AS avg_pos
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
MinClass AS (
    SELECT MIN(avg_pos) AS min_avg FROM ClassAvg
),
ClassRaces AS (
    SELECT 
        c.class,
        COUNT(DISTINCT r.race) AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
)
SELECT 
    c.name AS car_name,
    c.class AS car_class,
    AVG(r.position) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country,
    cr.total_races
FROM Cars c
JOIN Results r ON c.name = r.car
JOIN Classes cl ON c.class = cl.class
JOIN ClassAvg ca ON c.class = ca.class
JOIN ClassRaces cr ON c.class = cr.class
WHERE ca.avg_pos = (SELECT min_avg FROM MinClass)
GROUP BY c.name, c.class, cl.country, cr.total_races
ORDER BY car_class;

4.
WITH CarStats AS (
    SELECT 
        c.name,
        c.class,
        AVG(r.position) AS avg_pos,
        COUNT(r.race) AS race_count,
        cl.country,
        AVG(AVG(r.position)) OVER (PARTITION BY c.class) AS class_avg,
        COUNT(*) OVER (PARTITION BY c.class) AS class_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
)
SELECT 
    name AS car_name,
    class AS car_class,
    avg_pos AS average_position,
    race_count,
    country AS car_country
FROM CarStats
WHERE avg_pos < class_avg AND class_count >= 2
ORDER BY car_class, average_position;

5.
WITH CarStats AS (
    SELECT 
        c.class,
        c.name,
        AVG(r.position) AS avg_pos,
        COUNT(r.race) AS race_count,
        cl.country,
        CASE WHEN AVG(r.position) > 3.0 THEN 1 ELSE 0 END AS is_low
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
),
ClassLow AS (
    SELECT 
        class,
        SUM(is_low) AS low_count
    FROM CarStats
    GROUP BY class
),
MaxLow AS (
    SELECT MAX(low_count) AS max_low FROM ClassLow
),
ClassRaces AS (
    SELECT 
        c.class,
        COUNT(DISTINCT r.race) AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
)
SELECT 
    cs.name AS car_name,
    cs.class AS car_class,
    cs.avg_pos AS average_position,
    cs.race_count,
    cs.country AS car_country,
    cr.total_races,
    cl.low_count AS low_position_count
FROM CarStats cs
JOIN ClassLow cl ON cs.class = cl.class
JOIN ClassRaces cr ON cs.class = cr.class
JOIN MaxLow ml ON cl.low_count = ml.max_low
WHERE cl.low_count = ml.max_low AND cs.is_low = 1
ORDER BY cl.low_count DESC;
