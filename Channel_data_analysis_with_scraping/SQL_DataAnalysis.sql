/*
1.Write a query to print the top 10 viewed videos along with the views
2.Write a query to print month in which he posted most videos and less videos
3.Write a query to get total videos of each year more than 100
4.Add a column to the table the column should show the rate where rate_percent is considered as the likes per the views 
5.write a query to get the previous posted video only if he has posted the previous day 
6.Write a query to get all days with video titles if he posted more than two videos
7.Create a column which says type of learning based on the title key words 
8.Write a query to get the on which category he created more videos other than other category
9. Write a query to get the on which category he got likes per vidoes rate morethan 1500
*/

/* 1.Write a query to print the top 10 viewed videos along with the views */

SELECT TOP 10 * FROM Video_details_krish
ORDER BY Views DESC;

/* 2.Write a query to print month in which he posted most videos and less videos */

WITH ab AS (SELECT DATEPART(YEAR,Published_date) AS year, Month ,COUNT(0) AS total_videos_per_month FROM
Video_details_krish
GROUP BY DATEPART(YEAR,Published_date),Month),
mn AS (SELECT *, DENSE_RANK() OVER(ORDER BY total_videos_per_month DESC,year,Month) AS rnk_desc,
DENSE_RANK() OVER(ORDER BY total_videos_per_month ASC,year,Month) AS rnk_asc FROM ab)
SELECT year,Month, total_videos_per_month FROM mn 
where rnk_desc = 1 OR rnk_asc = 1;

/* 3.Write a query to get total videos of each year is more than 100 */

SELECT DATEPART(YEAR,Published_date) AS year , COUNT(1) AS total_videos_per_year
FROM Video_details_krish
GROUP BY DATEPART(YEAR,Published_date)
HAVING COUNT(1) > 100;

/* 4.Add a column to the table the column should show the rate where rate_percent is considered as the likes per the views */
ALTER TABLE Video_details_krish ADD rate DECIMAL ;

UPDATE Video_details_krish
SET rate = (Likes*1.0/Views)*100;

/* 5.write a query to get the previous posted videos only if he has posted the previous day */

WITH ab AS (SELECT *, LAG(Published_date) OVER(ORDER BY Published_date) as prev_date FROM Video_details_krish)
SELECT * , 
CASE 
WHEN DATEDIFF(day,prev_date,Published_date) = 1 
THEN LAG(Title) OVER(ORDER BY Published_date)
ELSE NULL
END AS prev_video
FROM ab;

/* 6.Write a query to get all days with video titles if he posted more than two videos */

WITH ab AS (SELECT CAST(Published_date AS DATE) AS date_p,COUNT(0) AS total_c FROM Video_details_krish
GROUP BY CAST(Published_date AS DATE)
HAVING COUNT(0) >1) 
SELECT * FROM Video_details_krish 
WHERE CAST(Published_date AS DATE) IN (SELECT date_p FROM ab)
ORDER BY Published_date;

/* 7. Create a column which says type of learning based on the title key words */
ALTER TABLE Video_details_krish ADD Type_of_learning VARCHAR(50);

UPDATE Video_details_krish
SET Type_of_learning = 
CASE 
WHEN Title LIKE '%Machine Learning%' THEN 'Machine Learning' 
WHEN Title LIKE '%ML%'  THEN 'Machine Learning'
WHEN Title LIKE '%Deep Learning%'  THEN 'Deep Learning'
WHEN Title LIKE '%Data Science%'  THEN 'Data Science'
WHEN Title LIKE '%AI%'  THEN 'AI' 
WHEN Title LIKE '%Artificial Intelligence%' THEN 'AI'
WHEN Title LIKE '%Natural Language%' THEN 'NLP'
WHEN Title LIKE '%NLP%' THEN 'NLP'
WHEN Title LIKE '%Data Analytics%' THEN 'Data Analytics'
WHEN Title LIKE '%Data Analyst%' THEN 'Data Analytics'
WHEN Title LIKE '%Python%'THEN 'Python'
WHEN Title LIKE '%SQL%'THEN 'SQL'
ELSE 'Other' END;

/* 8.Write a query to get the on which category he created more videos other than other category */

SELECT TOP 1 Type_of_learning , COUNT(1) AS total_videos_count FROM Video_details_krish
WHERE Type_of_learning != 'Other'
GROUP BY Type_of_learning
ORDER BY COUNT(1) DESC ;

/* 9. Write a query to get the on which category he got likes per vidoes rate morethan 1500 */

SELECT Type_of_learning , (SUM(Likes)/COUNT(1)) AS like_per_video_ratio 
FROM Video_details_krish
GROUP BY Type_of_learning
HAVING (SUM(Likes)/COUNT(1)) > 1500
ORDER BY like_per_video_ratio DESC;

