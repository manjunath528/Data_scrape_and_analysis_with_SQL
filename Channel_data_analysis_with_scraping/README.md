# Youtube Video Data Analysis with Scraping

## Data Scraping

I have scraped the data by using the API key , here I have decided to do the data analysis on the youtube channel.

To do the data analysis we need to get the attributes like video_id , views for that video , likes and date of posted .

So I decided to get the all the relevant details that are need for my analysis.

I have used the jupyter notebook to scrape the data that we want. Using the libraries like build from the googleapiclinet.discovery and all other regular libraires.

Finally our dataset contains the attributes:

- 1 . Title
- 2 . Published date
- 3 . Views 
- 4 . Likes
- 5 . Favorites
- 6 . Month

## SQL Queries

- 1 . Write a query to print the top 10 viewed videos along with the views.

       SELECT TOP 10 * FROM Video_details_krish
       ORDER BY Views DESC;

   Results:

    ![Screenshot 2024-04-02 at 4 17 57 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/7996d840-1252-420d-82ba-c612e95429de)


      
- 2 . Write a query to print month in which he posted most videos and less videos.

        WITH ab AS (SELECT DATEPART(YEAR,Published_date) 
        AS year, Month ,COUNT(0) AS 
        total_videos_per_month FROM
        Video_details_krish
        GROUP BY DATEPART(YEAR,Published_date),Month),
        mn AS (SELECT *, DENSE_RANK() OVER(ORDER BY   
        total_videos_per_month DESC,year,Month) AS  
        rnk_desc,
        DENSE_RANK() OVER(ORDER BY    
        total_videos_per_month ASC,year,Month) AS 
        rnk_asc FROM ab)
        SELECT year,Month, total_videos_per_month FROM 
        mn 
        where rnk_desc = 1 OR rnk_asc = 1;

   Results:
    
    ![Screenshot 2024-04-02 at 4 22 51 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/c2c3ae63-6c9a-4f49-8bfd-6a1c504d936c)

- 3 . Write a query to get total videos of each year and the videos per year is more than 100.

       SELECT DATEPART(YEAR,Published_date) AS year , COUNT
       (1) AS total_videos_per_year
       FROM Video_details_krish
       GROUP BY DATEPART(YEAR,Published_date)
       HAVING COUNT(1) > 100;

   Results:

    ![Screenshot 2024-04-02 at 5 43 59 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/cc7f7c0f-a487-4371-a918-26de34bb02ef)

- 4 . Add a column to the table the column should show the rate where rate_percent is considered as the likes per the Views.
    
      ALTER TABLE Video_details_krish ADD rate DECIMAL ;

      UPDATE Video_details_krish
      SET rate = (Likes*1.0/Views)*100;
   
   Results:
    
    ![Screenshot 2024-04-02 at 6 43 38 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/e4df44f6-dc06-4a8e-8600-037535695491)

- 5 . Write a query to get the previous posted videos only if he has posted the previous day.

        WITH ab AS (SELECT *, LAG(Published_date) OVER(ORDER 
        BY Published_date) as prev_date FROM    
        Video_details_krish)
        SELECT * , 
        CASE 
        WHEN DATEDIFF(day,prev_date,Published_date) = 1 
        THEN LAG(Title) OVER(ORDER BY Published_date)
        ELSE NULL
        END AS prev_video
        FROM ab;

   Results:

    ![Screenshot 2024-04-02 at 5 56 17 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/d288a697-9ef4-49f6-965e-e33daa978b9b)
   
- 6 . Write a query to get all days with video titles if he posted more than two videos.

      WITH ab AS (SELECT CAST(Published_date AS DATE) AS 
      date_p,COUNT(0) AS total_c FROM Video_details_krish
      GROUP BY CAST(Published_date AS DATE)
      HAVING COUNT(0) >1) 
      SELECT * FROM Video_details_krish 
      WHERE CAST(Published_date AS DATE) IN (SELECT date_p 
      FROM ab)
      ORDER BY Published_date;

   Results:
   
    ![Screenshot 2024-04-02 at 6 00 17 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/6599f439-f899-44e1-865c-34a215175576)

 
- 7 . Create a column which says type of learning based on the title key words.

      ALTER TABLE Video_details_krish ADD Type_of_learning 
      VARCHAR(50);

      UPDATE Video_details_krish
      SET Type_of_learning = 
      CASE 
      WHEN Title LIKE '%Machine Learning%' THEN 'Machine 
      Learning' 
      WHEN Title LIKE '%ML%'  THEN 'Machine Learning'
      WHEN Title LIKE '%Deep Learning%'  THEN 'Deep Learning'
      WHEN Title LIKE '%Data Science%'  THEN 'Data Science'
      WHEN Title LIKE '%AI%'  THEN 'AI' 
      WHEN Title LIKE '%Artificial Intelligence%' THEN 'AI'
      WHEN Title LIKE '%Natural Language%' THEN 'NLP'
      WHEN Title LIKE '%NLP%' THEN 'NLP'
      WHEN Title LIKE '%Data Analytics%' THEN 'Data 
      Analytics'
      WHEN Title LIKE '%Data Analyst%' THEN 'Data Analytics'
      WHEN Title LIKE '%Python%'THEN 'Python'
      WHEN Title LIKE '%SQL%'THEN 'SQL'
      ELSE 'Other' END;

   Results:
    
    ![Screenshot 2024-04-02 at 6 47 32 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/0d6c9a3c-4d45-4718-b9eb-0c048b03f976)

- 8 . Write a query to get the on which category he created more videos other than other category.

        SELECT TOP 1 Type_of_learning , COUNT(1) AS 
        total_videos_count FROM Video_details_krish
        WHERE Type_of_learning != 'Other'
        GROUP BY Type_of_learning
        ORDER BY COUNT(1) DESC ;

   Results:
      
    ![Screenshot 2024-04-02 at 6 35 59 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/cdf72994-a969-4e94-9a6e-6c574116d61d)

- 9 . Write a query to get the on which category he got likes per vidoes rate morethan 1500.

      SELECT Type_of_learning , (SUM(Likes)/COUNT(1)) AS 
      like_per_video_ratio 
      FROM Video_details_krish
      GROUP BY Type_of_learning
      HAVING (SUM(Likes)/COUNT(1)) > 1500
      ORDER BY like_per_video_ratio DESC;

   Results:
    
    ![Screenshot 2024-04-02 at 6 38 46 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/eb36e430-52a1-4916-8e9f-2bc2c8069ef4)
