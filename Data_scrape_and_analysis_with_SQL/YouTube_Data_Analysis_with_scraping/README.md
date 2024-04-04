# Youtube Video Data Analysis with Scraping

## Data Scraping

I have scraped the data by using the API key , here I have decided to do the data analysis on the selected youtube channels and their posts data. 

To do the data analysis, we need the two tables like channel_details and the video details . Here I have created the one to many relationship between the channel_details and the video_datails. 

So I decided to get the all the relevant details that are need for my analysis.

I have used the jupyter notebook to scrape the data that we want. Using the libraries like build from the googleapiclinet.discovery and all other regular libraires.

Finally our channel_details table contains the attributes :
- 1 . Name 
- 2 . Subscribers
- 3 . Total_views
- 4 . total_videos
- 5 . id 

And the video_details table contains the attributes :

- 1 . Title
- 2 . Published date
- 3 . Views 
- 4 . Likes
- 5 . Month
- 6 . playlist_id

## SQL Queries

- 1 . Write a query to find the top 2 channel names who got better likes per views ratio.

      SELECT  TOP 2 a.playlist_id,b.    
      channel_name,SUM(likes)*1.0/SUM(a.
      views)      
      AS likes_per_views FROM 
      all_video_details AS a   
      INNER JOIN 
      channel_details AS b 
      ON a.playlist_id = b.id
      GROUP BY a.playlist_id,b.channel_name
      ORDER BY likes_per_views DESC;

   Results:

    ![Screenshot 2024-04-03 at 4 07 57 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/506e2986-d9d8-46c3-89aa-2c7f210cdf7d)

      
- 2 . Write a query to find the top watched video for each channel.

        WITH ab AS (SELECT *,DENSE_RANK() OVER(PARTITION BY 
        channel_name ORDER BY a.views DESC)AS rnk FROM
        all_video_details AS a   
        INNER JOIN 
        channel_details AS b 
        ON a.playlist_id = b.id) 
        SELECT channel_name, title, views FROM ab
        WHERE rnk = 1;

   Results:
    
    ![Screenshot 2024-04-03 at 4 12 58 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/6afd43c1-cc13-4f88-a92e-b9034b94a676)

- 3 . Write a query to find the top watched video for each channel for each year.

       WITH ab AS (SELECT *,DENSE_RANK() OVER(PARTITION BY 
       channel_name,DATEPART(year,published_date) ORDER BY 
       a.views DESC)AS rnk FROM
       all_video_details AS a   
       INNER JOIN 
       channel_details AS b 
       ON a.playlist_id = b.id) 
       SELECT channel_name,DATEPART(year,published_date) AS  
       year , title, views FROM ab
       WHERE rnk = 1;

   Results:

    ![Screenshot 2024-04-03 at 4 16 39 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/33e5b240-7dc8-471a-916f-1a7c37480081)

- 4 . Write a query to find who has better reach in vidoes year wise (reach is considered as increase in his views per year).
    
      SELECT channel_name,DATEPART(year,published_date) AS 
      year,SUM(views) AS yearwise_views FROM 
      all_video_details AS a   
      INNER JOIN 
      channel_details AS b 
      ON a.playlist_id = b.id
      GROUP BY channel_name,DATEPART(year,published_date)
      ORDER BY year;
   
   Results:
    
    ![Screenshot 2024-04-03 at 4 20 08 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/a526c83e-429a-4036-b0f5-9052a997bb54)

- 5 . Write a query to find the top watched video in each month of 2023 for each channel.

       SELECT * FROM (SELECT *, ROW_NUMBER() OVER
       (PARTITION   BY  channel_name,DATEPART(month,
       published_date) ORDER BY views DESC) AS rnk FROM 
       all_video_details AS a   
       INNER JOIN 
       channel_details AS b 
       ON a.playlist_id = b.id
       WHERE DATEPART(year,published_date) = 2023) ab 
       WHERE rnk = 1
       ORDER BY published_date ASC, views DESC;

   Results:

    ![Screenshot 2024-04-03 at 4 24 06 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/dc02c4d1-34e4-49d7-9f76-6b21ba298c5a)
   
- 6 . Write a query to find the who made more videos in the each month of the 2023 year and total video count per month.

      WITH ab AS (SELECT channel_name, DATEPART(MONTH,
      published_date)AS month, COUNT(title) AS total_videos 
      FROM 
      all_video_details AS a   
      INNER JOIN 
      channel_details AS b 
      ON a.playlist_id = b.id 
      WHERE DATEPART(year,published_date) = 2023
      GROUP BY channel_name, DATEPART(MONTH,published_date))
      SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION   
      BY month ORDER BY total_videos DESC) AS rnk 
      FROM ab) mn 
      WHERE rnk =1;

   Results:
   
    ![Screenshot 2024-04-03 at 4 33 43 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/05b174d2-cf9c-4317-821f-be825aa0139f)

 
- 7 . Write a query to find the percentage of each channel highest viewed video got upon total views

      WITH sp AS (SELECT *, SUM(views) OVER(PARTITION BY 
      channel_name)AS total_video_views FROM 
      all_video_details AS a   
      INNER JOIN 
      channel_details AS b 
      ON a.playlist_id = b.id),
      ab AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY 
      channel_name ORDER BY views DESC) AS rnk FROM sp),
      mn AS (SELECT * FROM ab WHERE rnk = 1)
      SELECT *, (views*1.0/total_video_views)*100 AS    
      percentage_of_views FROM mn;

   Results:
    
    ![Screenshot 2024-04-03 at 4 54 42 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/bd94c0ee-fa23-4194-961b-ce93edf13842)

- 8 . Write a query to find which channel_id took less time to reach the 5k,10k likes for his video.

        WITH mn AS (SELECT * FROM ((SELECT * FROM (SELECT *, 
        ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY 
        published_date) as rnk FROM
        all_video_details AS a   
        INNER JOIN 
        channel_details AS b 
        ON a.playlist_id = b.id) a
        WHERE rnk =1)
        UNION
        (SELECT * FROM (SELECT *, ROW_NUMBER() OVER
        (PARTITION BY channel_name ORDER BY published_date) 
        as rnk FROM
        all_video_details AS a   
        INNER JOIN 
        channel_details AS b 
        ON a.playlist_id = b.id
        WHERE likes >=5000) a
        WHERE rnk =1)
        UNION
        (SELECT * FROM (SELECT *, ROW_NUMBER() OVER
        (PARTITION BY channel_name ORDER BY published_date) 
        as rnk FROM
        all_video_details AS a   
        INNER JOIN 
        channel_details AS b 
        ON a.playlist_id = b.id
        WHERE likes >= 10000) a
        WHERE rnk =1))ab),
        ss AS (SELECT *, LEAD(published_date) OVER(PARTITION 
        BY channel_name ORDER BY published_date) as lag1 ,
        LEAD(published_date,2) OVER(PARTITION BY   
        channel_name ORDER BY published_date) as lag2 FROM 
        mn)
        SELECT * FROM(SELECT *, ROW_NUMBER() OVER(PARTITION 
        BY channel_name ORDER BY morethan5K DESC) AS rnk 
        FROM 
        (SELECT channel_name, DATEDIFF(day,published_date,   
        lag1) AS morethan5K, DATEDIFF(day,published_date,
        lag2) AS morethan10K FROM
        ss )abc)abcd
        WHERE rnk =1
        ORDER BY morethan5K;

   Results:
    ![Screenshot 2024-04-03 at 5 24 19 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/853daa68-3267-4215-af89-b8da7bea6d30)



- 9 . Write a query to find channel names who got his lowest watched video after 2 months he created.

      SELECT * FROM (SELECT *, MIN(published_date) OVER 
      (PARTITION BY channel_name) AS min_published_date, 
      ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY 
      likes) as rnk FROM 
      all_video_details AS a   
      INNER JOIN 
      channel_details AS b 
      ON a.playlist_id = b.id) ab
      WHERE rnk =1 AND DATEDIFF(DAY,min_published_date,   
      published_date) >= 60;


   Results:
    
    ![Screenshot 2024-04-04 at 1 53 11 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/7a847f7a-f178-4fab-9787-469b5bf34f23)


- 10 . Write a query to find the time difference between the each channel's lowest watched and highest watched video and also the direction of increment.

     WITH abc AS(SELECT * FROM (SELECT *,
     ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY 
     likes) as rnk FROM 
     all_video_details AS a   
     INNER JOIN 
     channel_details AS b 
     ON a.playlist_id = b.id
     UNION
     SELECT *,
     ROW_NUMBER() OVER(PARTITION BY channel_name ORDER BY 
     likes DESC) as rnk FROM 
     all_video_details AS a   
     INNER JOIN 
     channel_details AS b 
     ON a.playlist_id = b.id) mn
     WHERE rnk =1)
     SELECT channel_name, DATEDIFF(day,published_date,
     high_viewed_post_date) AS diff_in_lowestandhighest_days   
     FROM
     (SELECT * , LEAD(published_date) OVER(PARTITION BY    
     channel_name ORDER BY likes) as high_viewed_post_date 
     FROM abc)abcd
     WHERE high_viewed_post_date IS NOT NULL;

     Results:

     ![Screenshot 2024-04-04 at 1 58 03 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/e51d9a35-3f02-4d68-abab-463ee048252c)



