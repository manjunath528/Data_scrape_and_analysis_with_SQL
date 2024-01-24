SELECT * from athlete_events;

/*
There are 2 csv files present in this  file. The data contains 120 years of olympics history. There are 2 daatsets 
1- athletes : it has information about all the players participated in olympics
2- athlete_events : it has information about all the events happened over the year.(athlete id refers to the id column in athlete table)


--1 which team has won the maximum gold medals over the years.

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

--6 find players who won gold medal in summer and winter olympics both.

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.




*/

--1 which team has won the maximum gold medals over the years.

SELECT  TOP 1 mn.team, SUM(CASE WHEN medal='Gold' THEN 1 ELSE 0 END) AS total_gold_medals 
FROM athlete_events ab 
INNER JOIN
athletes mn on ab.athlete_id = mn.id
GROUP BY team
ORDER BY total_gold_medals DESC;


--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

SELECT a.team ,a.total_silver_medals,year FROM (SELECT team, SUM(CASE WHEN medal='Silver' THEN 1 ELSE 0 END) AS total_silver_medals 
FROM athlete_events ab 
INNER JOIN 
athletes mn ON ab.athlete_id = mn.id
GROUP BY team) a
INNER JOIN
(SELECT team, year, SUM(CASE WHEN medal='Silver' THEN 1 ELSE 0 END) AS yearwise_s_medals
FROM athlete_events ab 
INNER JOIN 
athletes mn ON ab.athlete_id = mn.id
GROUP BY team,year) b
ON a.team= b.team
ORDER BY total_silver_medals DESC;


--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

SELECT  TOP 1 name , SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) as total_only_gold FROM(SELECT * FROM 
athlete_events a 
INNER JOIN
athletes b on a.athlete_id = b.id
WHERE medal = 'Gold' AND medal NOT IN ('Silver', 'Bronze')) a
GROUP BY name
ORDER BY total_only_gold DESC;



--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

SELECT year,total_gold, STRING_AGG(name,',') as name_list FROM (SELECT year, name, SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) as total_gold FROM
athlete_events a 
INNER JOIN
athletes b on a.athlete_id = b.id
WHERE medal = 'Gold'
GROUP BY year,name) ab
GROUP BY year,total_gold
ORDER BY total_gold DESC;


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

SELECT medal,year,sport  FROM (SELECT * , ROW_NUMBER() OVER(PARTITION BY medal ORDER BY year) as rnk FROM 
athlete_events a 
INNER JOIN
athletes b on a.athlete_id = b.id 
WHERE team = 'India') ab 
WHERE rnk = 1;


--6 find players who won gold medal in summer and winter olympics both.

SELECT name
FROM 
athlete_events a 
INNER JOIN
athletes b on a.athlete_id = b.id 
WHERE medal = 'Gold'
GROUP BY name
HAVING count(distinct season)=2;

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

SELECT year,name FROM
athlete_events a 
INNER JOIN
athletes b on a.athlete_id = b.id
WHERE medal in ('Gold','Silver','Bronze')
GROUP BY year,name;


--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
WITH ab AS (SELECT name, event, year FROM 
athlete_events a 
INNER JOIN
athletes b on a.athlete_id = b.id
WHERE medal = 'Gold' AND year >= 2000 AND season = 'Summer'
GROUP BY name,event,year)
select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from ab) A
where year=prev_year+4 and year=next_year-4


