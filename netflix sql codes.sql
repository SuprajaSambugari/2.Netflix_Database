--1. Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

--2. Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;



--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020;


--4. Find the Top 5 Countries with the Most Content on Netflix
select 
unnest(string_to_array(country,',')) as new_country,
count(show_id) as total_content
from netflix
group by 1 
order by 2 desc
limit 5


--5. Identify the Longest Movie with title
----select *  from netflix
--where 
--type='Movie'
--and
--duration=(select max(duration)from netflix)

select title,
max(CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1)as INT)) as maximun_length
from netflix
where type = 'Movie' and duration is not null
group by 1 
order by 2 desc
limit 5


--6. Find Content Added in the Last 5 Years
select * 
from netflix 
where 
to_date(date_added,'Month DD,YYYY') >= CURRENT_DATE-INTERVAL '5 years'



---7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select 
title,
type ,
director
from netflix 
where director like '%Rajiv Chilaka%'



--8. List All TV Shows with More Than 5 Seasons
---here we have text in the duration table and we can't perform < and > 
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT = 5;


--9. Count the Number of Content Items in Each Genre
select 
unnest(string_to_array(listed_in,','))as genre ,
count(*) as total
from netflix
group by 1


--10.Find each year and the average numbers of content release in India on netflix.
select 
extract(year from to_date(date_added,'month DD,YYYY')) as date,
count(*),
round(
count(*)::numeric/(select count(*) from netflix where country ='India')::numeric*100 
,2)as avg_content
from netflix
where country ='India'
group by 1


--11. List All Movies that are Documentaries
select * from netflix
where listed_in ilike '%Documentaries%'


--12. Find All Content Without a Director
select * from netflix
where director is null


--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select * from netflix
where casts ilike '%Salman khan%'
and release_year>extract(year from current_date)-10


--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;