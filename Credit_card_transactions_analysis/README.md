# Credit Card Transaction Data Analysis in India

## Problem Statement

Here I have decided to do the credit card transcations of the different cities in the India. 

Table contains the following columns :

- 1 . transaction_id
- 2 . city
- 3 . transcation_date
- 4 . card_type
- 5 . exp_type
- 6 . gender
- 7 . amount

## SQL Queires

- 1 . Write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends.

      WITH ab AS (SELECT  city, SUM(amount) AS 
      total_spend
      FROM credit_card_transcations
      GROUP BY city),
      total_amount AS (SELECT SUM(CAST(amount AS bigint)
      ) AS total_amt FROM credit_card_transcations)
      SELECT TOP 5 ab.*, round(((total_spend*1.0)/  
      (SELECT total_amt FROM total_amount))*100,2) AS 
      percent_contribution FROM ab
      ORDER BY percent_contribution DESC;

    
     Results:

     ![Screenshot 2024-04-04 at 4 08 27 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/568f693f-e083-4735-ba96-48758f24531f)


- 2 . Write a query to print highest spend month and amount spent in that month for each card type.

      WITH ab AS (SELECT card_type,datepart(year,  
      transaction_date) AS spend_year,DATEPART(month,
      transaction_date) AS spend_month ,SUM(amount) as 
      total_spend_card
      FROM credit_card_transcations
      GROUP BY card_type,datepart(year,transaction_date),  
      DATEPART(month,transaction_date)),
      mn AS (SELECT *, DENSE_RANK() OVER(PARTITION BY 
      card_type ORDER BY  total_spend_card DESC) AS rnk FROM 
      ab)
      SELECT card_type,spend_year,spend_month,
      total_spend_card 
      FROM mn 
      WHERE rnk = 1;

     Results:

     ![Screenshot 2024-04-04 at 4 13 38 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/f15651ba-99cc-44dd-ba0d-fc26b1d740c6)


- 3 . Write a query to print the transaction details(all columns from the table) for each card type when it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type).

      WITH ab AS
      (SELECT *,SUM(amount) OVER(PARTITION BY card_type 
      ORDER BY transaction_date, transaction_id ROWS BETWEEN 
      unbounded preceding and current row) as ttl_amt_still
      FROM credit_card_transcations)
      SELECT * FROM (SELECT *, DENSE_RANK() OVER(PARTITION   
      BY card_type ORDER BY ttl_amt_still) AS rnk
      FROM ab
      WHERE ttl_amt_still >= 1000000) mn
      WHERE rnk = 1;

     Results:

     ![Screenshot 2024-04-04 at 4 16 43 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/a517b1c5-394a-40cc-b5ef-987f178b5f81)


- 4 . Write a query to find city which had lowest percentage spend for gold card type.

       WITH ab AS(SELECT city,SUM(CAST(amount AS bigint)) as 
       total_amt
       FROM credit_card_transcations 
       WHERE card_type = 'Gold'
       GROUP BY city) ,
       mn AS (SELECT SUM(amount) AS total_agg FROM    
       credit_card_transcations
       WHERE card_type = 'Gold'),
       dn AS (SELECT city,((total_amt*1.0)/(SELECT total_agg 
       FROM mn))*100 AS percentage_spent FROM ab)
       SELECT city FROM (SELECT * , DENSE_RANK() OVER(ORDER 
       BY percentage_spent) AS rnk FROM dn) aaa 
       WHERE rnk =1;

     Results:
       
     ![Screenshot 2024-04-04 at 4 32 23 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/bf606877-a9fa-447f-b2a2-79b28033430e)

- 5 . Write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel).

       WITH ab AS (SELECT city , exp_type, SUM(amount) 
       total_amount from credit_card_transcations
       GROUP BY city , exp_type),
       mn AS (SELECT *, RANK() OVER(PARTITION BY city ORDER 
       BY total_amount DESC) AS desn_rnk,
       RANK() OVER(PARTITION BY city ORDER BY total_amount ) 
       AS asc_rnk FROM ab)
       SELECT city, MAX(CASE WHEN desn_rnk = 1 THEN exp_type 
       END) AS highest_exp_type,
       MIN(CASE WHEN asc_rnk = 1 THEN exp_type END) AS 
       lowest_exp_type FROM mn
       GROUP BY city;

     Results:

     ![Screenshot 2024-04-04 at 4 35 52 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/4de622e9-a22e-42a6-875f-b635ddb3ff5e)


- 6 . Write a query to find percentage contribution of spends by females for each expense type.

      SELECT ab.exp_type, (total_f_amt*1.0/total_amt)
      *100 AS f_con_percent FROM 
      (SELECT  exp_type , SUM(amount) as total_f_amt 
      FROM credit_card_transcations
      WHERE gender = 'F'
      GROUP BY  exp_type) ab 
      INNER JOIN
      (SELECT  exp_type , SUM(amount) as total_amt 
      FROM credit_card_transcations
      GROUP BY  exp_type) mn
      ON ab.exp_type = mn.exp_type
      ORDER BY f_con_percent DESC;

    OR 
     
       select exp_type,
       sum(case when gender='F' then amount else 0 end)*1.0/
       sum(amount) as percentage_female_contribution
       from credit_card_transcations
       group by exp_type
       order by percentage_female_contribution desc;


     Results:
      
     ![Screenshot 2024-04-04 at 4 45 02 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/577314fe-578c-43a6-b058-258c52d246ad)


- 7 . Which card and expense type combination saw highest month over month growth in Jan-2014.

     WITH ab AS (SELECT card_type,exp_type, DATEPART(year, 
     transaction_date)AS year,DATEPART(month, 
     transaction_date) AS month,
     SUM(amount) AS total_amt FROM credit_card_transcations
     GROUP BY card_type,exp_type, DATEPART(year,   
     transaction_date), DATEPART(month, transaction_date)),
     mn AS (SELECT *, LAG(total_amt) OVER(PARTITION BY 
     card_type,exp_type ORDER BY year, month) AS lag FROM ab)
     SELECT * FROM (SELECT *, total_amt-lag as diff_fm_lag ,
     DENSE_RANK() OVER(ORDER BY total_amt-lag DESC) AS rnk 
     FROM mn 
     WHERE year = 2014 AND month = 1) nk 
     where rnk=1;

     Results:

     ![Screenshot 2024-04-04 at 4 47 33 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/507b2e2e-b616-4dd9-babb-2989c478e296)


- 8 . During weekends which city has highest total spend to total no of transcations ratio .

     SELECT top 1 city, SUM(amount)/COUNT(transaction_id) AS 
     ratio
     FROM credit_card_transcations
     WHERE DATENAME(weekday, transaction_date) IN 
     ('Saturday','Sunday')
     GROUP BY city
     ORDER BY ratio DESC;

     Results:
      
     ![Screenshot 2024-04-04 at 4 49 33 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/7e4953b3-2adc-4b6d-a1c5-fba4e892e427)


- 9 . Which city took least number of days to reach its 500th transaction after the first transaction in that city.

      WITH ab AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY 
      city ORDER BY transaction_date) AS rnk
      FROM credit_card_transcations),
      mn AS (SELECT city, MAX(CASE WHEN rnk = 500 THEN 
      transaction_date END) AS rnk_f, MAX(CASE WHEN rnk = 1  
      THEN transaction_date END) AS rnk_one
      FROM ab
      GROUP BY city)
      SELECT top 1 city ,DATEDIFF(DAY,rnk_one,rnk_f) AS 
      diff_days FROM mn
      where rnk_f is not null
      ORDER BY diff_days;

     Results:
      
     ![Screenshot 2024-04-04 at 4 52 03 PM Medium](https://github.com/manjunath528/SQL_projects/assets/109943347/efe1df08-6e17-4719-b505-c66e30deaab4)
       

      
