-- ---------------------------------------------------
-- Movie Budget vs Revenue Analysis (TMDb dataset)
-- All queries written in SQLite
-- ---------------------------------------------------

SELECT *
FROM tmdb
LIMIT 20;

-- Row count
SELECT COUNT(*) FROM tmdb;

--Budget and revenue summary
SELECT
	MIN(budget), MAX(budget), AVG(budget),
	MIN(revenue), MAX(revenue), AVG(revenue)
FROM tmdb;

--Zero budget and revenue counts
SELECT 
	COUNT(*) AS zero_budget
FROM tmdb
WHERE budget = 0;

SELECT 
	COUNT(*) AS zero_revenue
FROM tmdb
WHERE revenue = 0;

-- Top 20 highest revenue 
SELECT title, budget, revenue, SUBSTR(release_date, 1, 4) AS release_year, genres
FROM tmdb
ORDER BY revenue DESC
LIMIT 20;

--Top 20 by Absolute Profit
SELECT title, revenue - budget AS profit, budget, revenue
FROM tmdb
WHERE budget >= 1000 and revenue > 0
ORDER by profit DESC 
LIMIT 20;

-- Top 20 films sorted by ROI with a budget of at least 1000 budget 
SELECT title, budget, revenue, genres, ROUND(CAST((revenue-budget) AS FLOAT) / budget, 2) as roi
FROM tmdb
WHERE budget > 1000 and revenue > 0
ORDER BY roi DESC 
LIMIT 20;

--ROI by decade
SELECT 
  SUBSTR(release_date, 1, 4) / 10 * 10 AS decade,
  COUNT(*) AS film_count,
  ROUND(AVG(CAST((revenue - budget) AS FLOAT) / NULLIF(budget, 0)), 2) AS avg_roi
FROM tmdb
WHERE budget > 1000 AND revenue > 0 AND release_date IS NOT NULL
GROUP BY decade
ORDER BY decade;

--Genre ROI
SELECT
  TRIM(
    CASE
      WHEN INSTR(genres, ',') > 0 THEN SUBSTR(genres, 1, INSTR(genres, ',') - 1)
      ELSE genres
    END
  ) AS primary_genre,
  COUNT(*) AS film_count,
  ROUND(100.0 * AVG(CAST((revenue - budget) AS FLOAT) / NULLIF(budget, 0)), 2) AS avg_roi
FROM tmdb
WHERE budget >= 1000 AND revenue > 0 AND genres IS NOT NULL
GROUP BY primary_genre
HAVING film_count > 5
ORDER BY avg_roi DESC;

-- average runtime of films, grouped by their primary genre
SELECT
  TRIM(
    CASE
      WHEN INSTR(genres, ',') > 0 THEN SUBSTR(genres, 1, INSTR(genres, ',') - 1)
      ELSE genres
    END
  ) AS primary_genre,
  ROUND(AVG(runtime), 2) AS avg_runtime
FROM tmdb
WHERE runtime > 0
GROUP BY primary_genre
ORDER BY avg_runtime DESC;

-- Runtime v Revenue
SELECT
  (CAST(runtime / 10 AS INTEGER)) * 10 AS runtime_bin,
  COUNT(*) AS film_count,
  ROUND(AVG(revenue), 2) AS avg_revenue
FROM tmdb
WHERE runtime > 0 AND revenue > 0
GROUP BY runtime_bin
HAVING film_count > 1
ORDER BY runtime_bin;