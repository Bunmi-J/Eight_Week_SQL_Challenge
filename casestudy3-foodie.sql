--CASE STUDY 3 - FOODIE
-- A Customer Journey
/*Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

--Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!*/


1.Customer_id 1 started the trial period on 2020-08-01 but downgraded to basic after 7 day trial on 2020- 08-01
2.Customer_id 2 started the trial period on 2020-09-20 but upgraded to pro annual after 7 day trial on 2020-09-27
3.Customer_id 11 started the trial period on 2020-11-19 but churn after 7 day trial on 2020-11-26
4.Customer_id 13 started the trial period on 2020-12-15,downgraded to basic after 7 day trial on 2020-12-22,
then upgraded to pro monthly after 3 months & 7days on the 2021-03-29
5.Customer_id 15 started the trial period on 2020-03-17,upgraded to pro monthly after 7 day trial on 2020-03-24,
then churn after 1 month & 5days on the 2020-04-29
6.Customer_id 16 started the trial period on 2020-05-31,downgraded to basic after 7 day trial on 2020-06-07,
then upgraded to pro annual after 4 months & 14days on the 2020-04-29
7.Customer_id 18 starts the trial period on 2020-07-06 but upgraded to pro monthly after 7 day trial on 2020-07-13
8.Customer_id 19 starts the trial period on 2020-06-22 but upgraded to pro monthly after 7 day trial on 2020-06-29
then upgraded to pro annual on 2020-08-29 exactly 2 months after

SELECT customer_id, s.plan_id, plan_name, start_date
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE customer_id IN(1, 2, 11, 13, 15, 16, 18, 19);

-- B. Data Analysis Questions
/* Que 1- How many customers has Foodie-Fi ever had?*/
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;

/* Que 2 -What is the monthly distribution of trial plan start_date values for our 
dataset - use the start of the month as the group by value*/

SELECT DATE_TRUNC('month', s.start_date) AS month_start,
       COUNT(*) AS trial_starts
FROM subscriptions s
WHERE s.plan_id = 0
GROUP BY month_start
ORDER BY month_start;

/* Que 3-What plan start_date values occur after the year 2020 for our dataset? 
Show the breakdown by count of events for each plan_name*/
SELECT p.plan_name, COUNT(*) AS year_start_after_2020
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE start_date > '2020-12-31'
GROUP BY p.plan_name
ORDER BY year_start_after_2020 DESC;

/*Que 4 What is the customer count and percentage of customers who have churned 
rounded to 1 decimal place?*/

SELECT COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) AS churned_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END)::NUMERIC / 
        COUNT(DISTINCT customer_id) * 100, 1
    ) AS churn_percentage
FROM subscriptions;


/* Que 5 READUP-How many customers have churned straight after their initial free trial
- what percentage is this rounded to the nearest whole number?*/

SELECT COUNT(DISTINCT customer_id) AS total_trial_customers,
    COUNT(DISTINCT customer_id) FILTER (WHERE next_plan = 4) AS churned_after_trial,
    ROUND(
        COUNT(DISTINCT customer_id) FILTER (WHERE next_plan = 4)::NUMERIC / 
        COUNT(DISTINCT customer_id) * 100, 0
    ) AS churn_percentage
FROM (
    SELECT customer_id, plan_id, 
           LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
    FROM subscriptions
) s
WHERE plan_id = 0;

/*Que 6 READUP-What is the number and percentage of customer plans after their 
initial free trial?*/
SELECT p.plan_name, COUNT(*) AS plan_count,
    ROUND(
        COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 1
    ) AS plan_percentage
FROM (
    SELECT customer_id, plan_id, start_date,
           LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
    FROM subscriptions
) s
JOIN plans p ON s.next_plan = p.plan_id
WHERE s.plan_id = 0 -- Only consider customers whose first plan was a trial
GROUP BY p.plan_name
ORDER BY plan_count DESC;

/* Que 7- What is the customer count and percentage breakdown of all 5 plan_name 
values at 2020-12-31?*/
WITH cte_next_date AS (
    SELECT customer_id, plan_id, start_date,
           LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_date
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
),
plans_breakdown AS (
    SELECT plan_id, 
           COUNT(DISTINCT customer_id) AS total_customers,
           (SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE start_date <= '2020-12-31') AS total_all_customers
    FROM cte_next_date
    WHERE next_date IS NULL -- Only consider the latest plan before 2021
    GROUP BY plan_id
)
SELECT p.plan_name, pb.total_customers, 
       ROUND(pb.total_customers::NUMERIC / pb.total_all_customers * 100, 1) AS percentage
FROM plans_breakdown pb
LEFT JOIN plans p ON p.plan_id = pb.plan_id
ORDER BY pb.plan_id;

/*Que 8- How many customers have upgraded to an annual plan in 2020?*/
SELECT COUNT(DISTINCT customer_id) AS annual_upgrade
FROM subscriptions 
WHERE plan_id = 3 AND start_date <= '2020-12-31'
ORDER BY annual_upgrade;

/*Que 9- READUP -How many days on average does it take for a customer to an annual plan
from the day they join Foodie-Fi?*/
-- 1st ERROR:  cannot cast type interval to numeric

WITH first_subscription AS (
    SELECT customer_id, MIN(start_date) AS join_date
    FROM subscriptions
    GROUP BY customer_id
),
annual_plan_dates AS (
    SELECT customer_id, MIN(start_date) AS annual_plan_date
    FROM subscriptions
    WHERE plan_id = 3
    GROUP BY customer_id
)
SELECT ROUND(AVG(AGE(ap.annual_plan_date, fs.join_date))::NUMERIC, 0) AS avg_days_to_annual
FROM first_subscription fs
JOIN annual_plan_dates ap ON fs.customer_id = ap.customer_id;
--2nd
WITH first_subscription AS (
    SELECT customer_id, MIN(start_date) AS join_date
    FROM subscriptions
    GROUP BY customer_id
),
annual_plan_dates AS (
    SELECT customer_id, MIN(start_date) AS annual_plan_date
    FROM subscriptions
    WHERE plan_id = 3
    GROUP BY customer_id
)
SELECT ROUND(AVG(EXTRACT(DAY FROM AGE(ap.annual_plan_date, fs.join_date)))::NUMERIC, 0) AS avg_days_to_annual
FROM first_subscription fs
JOIN annual_plan_dates ap ON fs.customer_id = ap.customer_id;

/*Que 10 - Can you further breakdown this average value into 30 day periods
(i.e. 0-30 days, 31-60 days etc)*/

WITH first_subscription AS (
    SELECT customer_id, MIN(start_date) AS join_date
    FROM subscriptions
    GROUP BY customer_id
),
annual_plan_dates AS (
    SELECT customer_id, MIN(start_date) AS annual_plan_date
    FROM subscriptions
    WHERE plan_id = 3
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN days_to_annual BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN days_to_annual BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN days_to_annual BETWEEN 61 AND 90 THEN '61-90 days'
        WHEN days_to_annual BETWEEN 91 AND 120 THEN '91-120 days'
        WHEN days_to_annual BETWEEN 121 AND 150 THEN '121-150 days'
        WHEN days_to_annual BETWEEN 151 AND 180 THEN '151-180 days'
        ELSE '180+ days'
    END AS time_period,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 1) AS percentage
FROM (
    SELECT fs.customer_id, 
           EXTRACT(DAY FROM AGE(ap.annual_plan_date, fs.join_date)) AS days_to_annual
    FROM first_subscription fs
    JOIN annual_plan_dates ap ON fs.customer_id = ap.customer_id
) grouped_data
GROUP BY time_period
ORDER BY time_period;

/*Que 11 - How many customers downgraded from a pro monthly to a basic 
monthly plan in 2020?*/

SELECT COUNT(DISTINCT customer_id) AS downgraded_customers
FROM subscriptions
WHERE plan_id = 1 
AND customer_id IN (
    SELECT customer_id FROM subscriptions
    WHERE plan_id = 2 AND start_date < '2021-01-01'
)
AND start_date BETWEEN '2020-01-01' AND '2020-12-31';

--C. Challenge Payment Question
/*The Foodie-Fi team wants you to create a new payments table for the year 2020
that includes amounts paid by each customer in the subscriptions table*/

ALTER TABLE subscriptions
ADD column payment_date DATE,
ADD column amount NUMERIC(10, 2),
ADD column payment_order INT;

--update payment details
WITH subscription_payments AS (
    SELECT s.customer_id, s.plan_id, p.plan_name, s.start_date,
           generate_series(s.start_date, '2020-12-31', interval '1 month')::DATE AS payment_date,
           p.price AS amount,
           ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS payment_order
    FROM subscriptions s
    JOIN plans p ON s.plan_id = p.plan_id
    WHERE s.plan_id IN (1, 2, 3) -- Monthly plans
)
UPDATE subscriptions AS s
SET amount = sp.amount,
    payment_date = sp.payment_date,
    payment_order = sp.payment_order
FROM subscription_payments sp
WHERE s.customer_id = sp.customer_id
AND s.plan_id = sp.plan_id;


--This query creates generates a new payments table for the 2020
SELECT customer_id, s.plan_id, p.plan_name, s.payment_date, s.amount, s.payment_order
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.plan_id IN(1,2,3)
ORDER BY s.customer_id;

SELECT COUNT(*) AS TOTAL, plan_id
FROM subscriptions 
WHERE plan_id IN(0,1,2,3,4)
GROUP BY plan_id
ORDER BY total DESC;

--D1 How would you calculate the rate of growth for Foodie-Fi? we can use metrics like
--customer growth or revenue growth
--D2- What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
-- subcriber growth and retention growth- how many active subscribers and how many
--users continues to subscribe after trial period and for how long

/*D3 --What are some key customer journeys or experiences that you would analyse
further to improve customer retention?
Ans- 1000 canceled after trial period. 546 downgraded to basic, 539 upgraded to monthly pro and 258 upgraded to annual pro.
overall % of users cancelling after trial is high, the figure for both monthly 
and annual pro is higher than users that downgraded*/

SELECT COUNT(*) AS TOTAL, plan_id
FROM subscriptions 
WHERE plan_id IN(0,1,2,3,4)
GROUP BY plan_id
ORDER BY total DESC;

/* D4 -If the Foodie-Fi team were to create an exit survey shown to customers
who wish to cancel their subscription, what questions would you include in the 
survey? 
Ans-On a scale of 0 -10 where 0 is not at all satisfied and 10 is very satisfied
How satisfied are you with the service? How satisfied are you with the food
content? could you give reason for cancellation */

/* D5 What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
Ans- A month free after 6 months continuous subscriptions. Yearly bonus point 
or incentives for active loyal users.
