

-- 1. Count the number of movies vs tv shows 
SELECT  
	type,count(*) as total_content
FROM NETFLIX
	GROUP BY type;

--2. Number of movies 
SELECT count(*) as total_movies 
	FROM NETFLIX 
	WHERE TYPE='Movie';


---3. Find the most common rating for movie and tv shows 
SELECT type,rating FROM
(SELECT TYPE, RATING, COUNT(*),
	rank() over (partition by type order by count(*) desc) as rankingorder
	FROM NETFLIX
	GROUP BY 1,2
	order by type,count(*) desc)
	as t1 
	where rankingorder=1;

--4. most common ratings regardless of type (i.e., combined for both movies and TV shows)
SELECT RATING, COUNT(*)
FROM NETFLIX
GROUP BY RATING
ORDER BY COUNT(*) DESC;

--5.List all the movies relaesed in the year 2020

SELECT type, title, release_year
FROM NETFLIX 
WHERE TYPE='Movie' AND RELEASE_YEAR=2020;

--6. find top 5 countries with most content on netflix 
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS NEWCOUNTRIES, count(show_id) as total_count
	from netflix
	group by NEWCOUNTRIES
	order by total_count desc
	limit 5 ;
--7. IDENTITY THE LONGEST MOVIE 
SELECT title, duration 
FROM netflix
WHERE type = 'Movie' and duration is NOT NULL and duration !=''
ORDER BY CAST(SUBSTR(duration, 1, LENGTH(duration) - 4) AS INTEGER) DESC
LIMIT 1;

SELECT date_added
FROM netflix
LIMIT 10;
-- 8.Find the content that added in last five years 
SELECT type, date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

SELECT type, unnest(string_to_array(director, ',')) as newdirector
    FROM netflix;
--9. Find all the movies by the director 'Rajiv Chilaka'
SELECT type, newdirector
FROM (
    SELECT type, unnest(string_to_array(director, ',')) as newdirector
    FROM netflix
) AS subquery
WHERE newdirector = 'Rajiv Chilaka';

-- we can also use like clause
SELECT * FROM NETFLIX 
WHERE DIRECTOR LIKE '%Rajiv Chilaka%';

--10. List all the TV SHOWS with more than 5 seasons 
SELECT type, duration
FROM NETFLIX
WHERE type = 'TV Show'
  AND CAST(SUBSTRING(duration FROM '^[0-9]+') AS INTEGER) > 5;

-- 11. Count the number of items in each genre 
SELECT unnest(string_to_array(listed_in,',')) as genre  , count(show_id) as total_count 
	from netflix
	group by genre;

--12. Find each year and the average number of content realease by india on netflix. 
WITH yearly_counts AS (
    SELECT 
        EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
        COUNT(*) AS total_releases
    FROM netflix
    WHERE country LIKE '%India%'
    GROUP BY year
)
SELECT 
    year,
    total_releases,
    AVG(total_releases) OVER () AS average_releases
FROM yearly_counts
ORDER BY average_releases DESC
LIMIT 5;


-- 13. list all the movies that are documentraties
SELECT * from netflix 
	where type='Movie' AND listed_in LIKE '%Documentaries%';
-- 14. find all the content without a director 
SELECT type , title 
	From netflix
WHERE director IS NULL OR director =' ';


-- 15. Find all the movies where actor 'Salman Khan appeared in last 10 years !

SELECT * from netflix 
	where type='Movie' AND casts LIKE '%Salman Khan%'
--AND TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '10 YEARS';
AND release_year >= EXTRACT (YEAR FROM CURRENT_DATE) - 10;

--16. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT UNNEST(STRING_TO_ARRAY(casts,',')) as newlist , count(*) as numbers from netflix
	GROUP BY newlist
	ORDER BY numbers desc 
	LIMIT 10 ;

--17. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

with new_table as (
SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix) 
	SELECT category , count(*) FROM new_table 
	GROUP BY category 
	;




	 