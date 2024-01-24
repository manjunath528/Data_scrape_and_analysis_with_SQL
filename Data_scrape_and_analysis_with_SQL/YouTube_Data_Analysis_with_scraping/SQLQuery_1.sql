/*  
1. Write a query to find the top 2 channel names who got better likes per views ratio
2. Write a query to find the top watched video for each channel
3. Write a query to find the top watched video for each channel for each year 
4. Write a query to find who has better reach in vidoes year wise (reach is considered as increase in his views per year) 
5. Write a query to find the top watched video in each month of 2023 for each channel
6. Write a query to find the who made more videos in the each month of the 2023 year and total video count per month
7. Write a query to find the percentage of each channel highest viewed video got upon total views
8. Write a query to find which channel_id took less time to reach the 5k,10k likes for his video
9. Write a query to find channel names who got his lowest watched video after 2 months he created
10. Write a query to find the time difference between the each channel's lowest watched and highest watched video and also the direction of increment
*/

SELECT * FROM all_video_details;
SELECT * FROM  channel_details;

ALTER TABLE channel_details
DROP COLUMN S_No;

EXEC sp_rename 'channel_details.playlist_id', 'id', 'COLUMN';

/* 1. Write a query to find the top 2 channel names who got better likes per views ratio */

SELECT  TOP 2 a.playlist_id,b.channel_name,SUM(likes)*1.0/SUM(a.views) AS likes_per_views FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id
GROUP BY a.playlist_id,b.channel_name
ORDER BY likes_per_views DESC;

/* 2. Write a query to find the top watched video for each channel */

WITH ab AS (SELECT *,DENSE_RANK() OVER(PARTITION BY channel_name ORDER BY a.views DESC)AS rnk FROM
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id) 
SELECT channel_name, title, views FROM ab
WHERE rnk = 1;

/* 3. Write a query to find the top watched video for each channel for each year */

WITH ab AS (SELECT *,DENSE_RANK() OVER(PARTITION BY channel_name,DATEPART(year,published_date) ORDER BY a.views DESC)AS rnk FROM
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id) 
SELECT channel_name,DATEPART(year,published_date) AS year , title, views FROM ab
WHERE rnk = 1;

/* 4. Write a query to find who has better reach in vidoes year wise (reach is considered as increase in his views per year) */

SELECT channel_name,DATEPART(year,published_date) AS year,SUM(views) AS yearwise_views FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id
GROUP BY channel_name,DATEPART(year,published_date)
ORDER BY year;

/* 5. Write a query to find the top watched video in each month of 2023 for each channel */

SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY  channel_name,DATEPART(month,published_date) ORDER BY views DESC) AS rnk FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id
WHERE DATEPART(year,published_date) = 2023) ab 
WHERE rnk = 1
ORDER BY published_date ASC, views DESC;


/* 6. Write a query to find the who made more videos in the each month of the 2023 year and total video count per month */

WITH ab AS (SELECT channel_name, DATEPART(MONTH,published_date)AS month, COUNT(title) AS total_videos FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id 
WHERE DATEPART(year,published_date) = 2023
GROUP BY channel_name, DATEPART(MONTH,published_date))
SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY month ORDER BY total_videos DESC) AS rnk 
FROM ab) mn 
WHERE rnk =1;

/*  7. Write a query to find the percentage of each channel highest viewed video got upon total views */

WITH sp AS (SELECT *, SUM(views) OVER(PARTITION BY channel_name)AS total_video_views FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id),
ab AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY views DESC) AS rnk FROM sp),
mn AS (SELECT * FROM ab WHERE rnk = 1)
SELECT *, (views*1.0/total_video_views)*100 AS percentage_of_views FROM mn;


/* 8. Write a query to find which channel_id took less time to reach the 5k,10k likes for his video */

WITH mn AS (SELECT * FROM ((SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY published_date) as rnk FROM
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id) a
WHERE rnk =1)
UNION
(SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY published_date) as rnk FROM
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id
WHERE likes >=5000) a
WHERE rnk =1)
UNION
(SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY published_date) as rnk FROM
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id
WHERE likes >= 10000) a
WHERE rnk =1))ab),
ss AS (SELECT *, LEAD(published_date) OVER(PARTITION BY channel_name ORDER BY published_date) as lag1 ,
LEAD(published_date,2) OVER(PARTITION BY channel_name ORDER BY published_date) as lag2 FROM mn)
SELECT * FROM(SELECT *, ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY morethan5K DESC) AS rnk FROM 
(SELECT channel_name, DATEDIFF(day,published_date, lag1) AS morethan5K, DATEDIFF(day,published_date,lag2) AS morethan10K FROM
ss )abc)abcd
WHERE rnk =1
ORDER BY morethan5K;

/* 9. Write a query to find channel names who got his lowest watched video after 2 months he created */

SELECT * FROM (SELECT *, MIN(published_date) OVER (PARTITION BY channel_name) AS min_published_date, ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY likes) as rnk FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id) ab
WHERE rnk =1 AND DATEDIFF(DAY,min_published_date,published_date) >= 60;


/* 10. Write a query to find the time difference between the each channel's lowest watched and highest watched video and also the direction of increment
*/

WITH abc AS(SELECT * FROM (SELECT *,
ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY likes) as rnk FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id
UNION
SELECT *,
ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY likes DESC) as rnk FROM 
all_video_details AS a   
INNER JOIN 
channel_details AS b 
ON a.playlist_id = b.id) mn
WHERE rnk =1)
SELECT channel_name, DATEDIFF(day,published_date,high_viewed_post_date) AS diff_in_landh_days FROM
(SELECT * , LEAD(published_date) OVER(PARTITION BY channel_name ORDER BY likes) as high_viewed_post_date FROM abc)abcd
WHERE high_viewed_post_date IS NOT NULL;
