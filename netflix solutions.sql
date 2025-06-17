-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
select type, count(type)
from netflix_pro
group by type;


--2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_pro
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

--Alternatively
with abi1 as (
with abi2 as(
with abi3 as(
select rating, count(rating) as ct
from netflix_pro
where type = 'Movie'
group by rating
order by count(rating) desc)
select *, rank() over (order by ct desc) as ranking from abi3)
select rating from abi2 where ranking = 1),

abi4 as(
with abi5 as(
with abi6 as(
select rating, count(rating) as ct
from netflix_pro
where type = 'TV Show'
group by rating
order by count(rating) desc)
select *, rank() over (order by ct desc) as ranking from abi6)
select rating from abi5 where ranking = 1)

select * from abi1
union all
select * from abi4;


--3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix_pro
WHERE release_year = 2020 AND type = 'Movie';

--Alternatively
with avi as (
select type, title
from netflix_pro
where release_year = 2020)
select * from avi
where type = 'Movie';

--4. Find the top 5 countries with the most content on Netflix

SELECT UNNEST(STRING_TO_ARRAY(COUNTRY, ',')) as stat, count(*) as num
from netflix_pro
group by stat
order by num desc
Limit 5;

--Alternatively
with viv3 as(
with viv as (
select UNNEST(STRING_TO_ARRAY(COUNTRY, ',')) as stats, count(title) as viv2
from netflix_pro
group by stats
order by count(title) desc)
select *,
rank() over (order by viv2 desc) as ranking
from viv)
select * from viv3
where ranking <=5;
 

--5. Identify the longest movie

select * from 
 (select distinct title as movie,
  split_part(duration,' ',1):: numeric as duration 
  from netflix_pro
  where type ='Movie') as subquery
where duration = (select max(split_part(duration,' ',1):: numeric) from netflix_pro)

--Alternatively
with avi6 as
(select duration as dur
from netflix_pro
where type = 'Movie')
select max((split_part(dur, ' ', 1))::numeric)
from avi6


--6. Find content added in the last 5 years
select * from netflix_pro
where To_date(date_added, 'Month DD, YYYY') >= Current_Date - Interval '5 Years'


--Alternatively
with new_date as
(select * , To_date(date_added, 'Month DD, YYYY') as real_date
from netflix_pro)
select * from new_date
where real_date >= Current_Date - Interval '5 Years'

--Alternatively
with final_data as
(with splitwise as 
(select title, split_part(date_added, ',' , 1) as date_month,
       split_part(date_added, ',' , 2) as years
from netflix_pro)
select title, trim(years) as trimmed_years
from splitwise)
select * from final_data
where trimmed_years = '2021';


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select type, title from netflix_pro
where director Like '%Rajiv Chilaka%'

--Alternatively
with new_director as
(select title, UNNEST(STRING_TO_ARRAY(director, ',')) as dir
from netflix_pro)
select * from new_director
where dir = 'Rajiv Chilaka'


--8. List all TV shows with more than 5 seasons
select *
from netflix_pro
where type = 'TV Show'
AND split_part(duration, ' ', 1)::bigint > 5;

--Alternatively
with avi2 as
(with avi1 as
(select * from netflix_pro
where type = 'TV Show')
select * , split_part(duration, ' ', 1)::BIGINT as splitted
from avi1)
select * from avi2 where splitted >5;

--9. Count the number of content items in each genre
Select UNNEST(string_to_array(listed_in, ',')) as genre, 
       count(show_id) as total_content
from netflix_pro
group by 1;

--Alternatively
with avi4 as
(select UNNEST(string_to_array(listed_in, ',')) as genre
from netflix_pro)
select genre, count(genre) as count1
from avi4
group by genre
order by count1 desc;



--10.Find each year and the average numbers of content release in India on netflix. 
---return top 5 year with highest avg content release!
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix_pro WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix_pro
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

--Alternatively
with avi5 as
(select release_year, count(*) as total_content 
from netflix_pro
where country Like '%India%'
group by release_year
order by total_content desc)
select *, round(total_content::numeric/(select sum(total_content) from avi5) * 100, 2) as avg
from avi5
Limit 5;


--11. List all movies that are documentaries
select * from netflix_pro
where listed_in like '%Documentaries%'
      And type = 'Movie'


--12. Find all content without a director
select * from netflix_pro
where director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix_pro
where casting Like '%Salman Khan%'
  AND to_date(date_added, 'Month DD, YYYY') > current_date - interval '10 years'

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select count(*) as con, UNNEST(string_to_array(casting, ',')) as actors
from netflix_pro
where type = 'Movie' and country like '%India%'
group by actors
order by con desc
Limit 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
---the description field. Label content containing these keywords as 'Bad' and all other 
---content as 'Good'. Count how many items fall into each category.
with avi7 as
(select title,
case
when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
else 'Good'
End as Friendliness
from netflix_pro)
select friendliness, count(*) 
from avi7
group by friendliness


