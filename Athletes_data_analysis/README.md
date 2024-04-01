# Athletes Data Analysis

This is the analysis related to the Athletes historical data and it is made based on the two datasets. The two datasets are 

- 1 athletes(table)

   In this dataset we have information related to the athletes. Attributes in the this table are:
    
     - 1 . id
     - 2 . name 
     - 3 . sex
     - 4 . height
     - 5 . weight
     - 6 . team

- 2 athletes_events(table)

   In this datset we have information related to the events that are occured and the prizes won by the athletes. Columns in this table are:
     
   - 1 . athlete_id 
   - 2 . games
   - 3 . year
   - 4 . season 
   - 5 . city
   - 6 . sport
   - 7 . event
   - 8 . medal 

Here, the relationship betweeen the athlete and athlete_events is one to many . Id in the athlete table has one to many ralationship with the athlete_id in the athletes_events. 

Athletes table has the unique ids which means that there is no duplicated rows in the table. But in the athletes_events we may many athlete_ids, it is due to one athele may participate in many events or one athlete may get the many medals. 



## Analysis Quaries 

- 1 . Which team has won the maximum gold medals over the years.

      SELECT  TOP 1 mn.team, SUM(CASE WHEN   
      medal='Gold' THEN 1 ELSE 0 END) AS      
      total_gold_medals 
      FROM athlete_events ab 
      INNER JOIN
      athletes mn on ab.athlete_id = mn.id
      GROUP BY team
      ORDER BY total_gold_medals DESC;

   Results:
   
    ![Screenshot 2024-04-01 at 2 04 44 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/0ecb96e2-6727-468b-9850-5e00e5c4c99d)



- 2 . For each team print total silver medals and year 
   in which they won maximum silver medal.

   Output 3 columns team,total_silver_medals    
   year_of_max_silver

        
   
      SELECT a.team ,a.total_silver_medals,year FROM 
      (SELECT team, SUM(CASE WHEN medal='Silver' THEN 1 
      ELSE 0 END) AS total_silver_medals 
      FROM athlete_events ab 
      INNER JOIN 
      athletes mn ON ab.athlete_id = mn.id
      GROUP BY team) a
      INNER JOIN
      (SELECT team, year, SUM(CASE WHEN medal='Silver'  
      THEN 1 ELSE 0 END) AS yearwise_s_medals
      FROM athlete_events ab 
      INNER JOIN 
      athletes mn ON ab.athlete_id = mn.id
      GROUP BY team,year) b
      ON a.team= b.team
      ORDER BY total_silver_medals DESC;


   Results: 

    ![2](https://github.com/manjunath528/SQL_projects/assets/109943347/5241d976-b81a-4255-b947-217fb28aff38)


- 3 . Which player has won maximum gold medals  amongst the players which have won only gold medal (never won silver or bronze) over the years.

      SELECT  TOP 1 name , SUM(CASE WHEN medal = 'Gold' 
      THEN 1 ELSE 0 END) as total_only_gold FROM(SELECT * 
      FROM 
      athlete_events a 
      INNER JOIN
      athletes b on a.athlete_id = b.id
      WHERE medal = 'Gold' AND medal NOT IN ('Silver',  
      'Bronze')) a
      GROUP BY name
      ORDER BY total_only_gold DESC;

   
   Results:

    ![3](https://github.com/manjunath528/SQL_projects/assets/109943347/a4955a57-27e4-4636-9435-39dd335eccb2)

- 4 . In each year which player has won maximum gold medal . Write a query to print year,player name and no of golds won in that year . In case of a tie print comma separated player names.
               
      SELECT year,total_gold, STRING_AGG(name,',') as 
      name_list FROM (SELECT year, name, SUM(CASE WHEN medal 
      = 'Gold' THEN 1 ELSE 0 END) as total_gold FROM
      athlete_events a 
      INNER JOIN
      athletes b on a.athlete_id = b.id
      WHERE medal = 'Gold'
      GROUP BY year,name) ab
      GROUP BY year,total_gold
      ORDER BY total_gold DESC;

   Results:
     
    ![Screenshot 2024-04-01 at 3 01 41 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/15512d4b-5d75-49ee-b522-71459e3619de)


- 5 . In which event and year India has won its first gold medal,first silver medal and first bronze medal. Print 3 columns medal,year,sport.

      SELECT medal,year,sport  FROM (SELECT * , ROW_NUMBER() 
      OVER(PARTITION BY medal ORDER BY year) as rnk FROM 
      athlete_events a 
      INNER JOIN
      athletes b on a.athlete_id = b.id 
      WHERE team = 'India') ab 
      WHERE rnk = 1;
   
   Results:

    ![Screenshot 2024-04-01 at 3 05 52 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/c1d1a646-96b1-4491-89e4-fdc6d79a4bdc)


- 6 . Find players who won gold medal in summer and winter olympics both.

      SELECT name
      FROM 
      athlete_events a 
      INNER JOIN
      athletes b on a.athlete_id = b.id 
      WHERE medal = 'Gold'
      GROUP BY name
      HAVING count(distinct season)=2;

   Results:
    
    ![Screenshot 2024-04-01 at 3 09 31 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/e29e44db-ef0f-480b-8d1c-cbbad16558b0)



- 7 . Find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

       
      SELECT year,name FROM
      athlete_events a 
      INNER JOIN
      athletes b on a.athlete_id = b.id
      WHERE medal in ('Gold','Silver','Bronze')
      GROUP BY year,name;
   
   Results:

    ![Screenshot 2024-04-01 at 3 13 32 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/d27cf1a7-7001-4ea6-9393-fa4c44baca91)
      

- 8 . Find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. Assume summer olympics happens every 4 year starting 2000. print player name and event name.

      WITH ab AS (SELECT name, event, year FROM 
      athlete_events a 
      INNER JOIN
      athletes b on a.athlete_id = b.id
      WHERE medal = 'Gold' AND year >= 2000 AND season 
      =      
      'Summer'
      GROUP BY name,event,year)
      select * from
      (select *, lag(year,1) over(partition by name,event    
      order by year ) as prev_year
      , lead(year,1) over(partition by name,event order by   
      year ) as next_year
      from ab) A
      where year=prev_year+4 and year=next_year-4

   
   Results:

    ![Screenshot 2024-04-01 at 3 16 01 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/aa4e871e-67bb-47c5-b195-f6682f8ca4f6)


   









         




      

