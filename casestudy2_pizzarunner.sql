--CHALLENGE WEEK 2-
-- linkk- https://8weeksqlchallenge.com/case-study-2/

SET search_path = pizza_runner;
/*DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);*/

INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  
  DROP TABLE IF EXISTS customer_orders;
-- created the customer_orders as raw data from the  case study. 
  CREATE TABLE customer_orders_raw (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders_raw
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

  --Note-28/06 Reviewed with Najeeb- Created a clean customer_orders using the AS keyword, 
  --  CASE -- WHEN to replace the exclusions and extras columns 

 DROP TABLE IF EXISTS customer_orders;
  CREATE TABLE customer_orders AS
 SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN exclusions IS null OR exclusions LIKE 'null' THEN ''
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' THEN ''
	  ELSE extras
	  END AS extras,
	order_time
FROM customer_orders_raw;

--SELECT * FROM customer_orders


--23/05 The customer_orders updated-- I changed the exclusion and extras datatype From 'VARCHAR' to array 'INT[]', then inserted '{}'into the extras and exclusions columns.
-- Najeeb adviced to use the CASE-- WHEN option rather than changing the exclusions and 
--extras data type. see note 1 28/06 above
 DROP TABLE IF EXISTS customer_orders;
 CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" INTEGER[],
  "extras" INTEGER[],
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '{}', '{}', '2020-01-01 18:05:02'),
  ('2', '101', '1', '{}', '{}', '2020-01-01 19:00:52'),
  ('3', '102', '1', '{}', '{}', '2020-01-02 23:51:23'),
  ('3', '102', '2', '{}', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '{4}', '{}', '2020-01-04 13:23:46'),
  ('4', '103', '1', '{4}', '{}', '2020-01-04 13:23:46'),
  ('4', '103', '2', '{4}', '{}', '2020-01-04 13:23:46'),
  ('5', '104', '1', '{null}', '{1}', '2020-01-08 21:00:29'),
  ('6', '101', '2', '{null}', '{null}', '2020-01-08 21:03:13'),
  ('7', '105', '2', '{null}', '{1}', '2020-01-08 21:20:29'),
  ('8', '102', '1', '{null}', '{null}', '2020-01-09 23:54:33'),
  ('9', '103', '1', '{4}', '{1, 5}', '2020-01-10 11:22:59'),
  ('10', '104', '1', '{null}', '{null}', '2020-01-11 18:34:49'),
  ('10', '104', '1', '{2, 6}', '{1, 4}', '2020-01-11 18:34:49');


  SELECT * from pizza_runner.customer_orders;

 
/*--Note for runner_orders
 CASE 
  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)*/

DROP TABLE IF EXISTS runner_orders_raw;
CREATE TABLE runner_orders_raw (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),  
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders_raw
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

--UPDATED runner_orders table data type columns(pickup_time to TIMESTAMP,distance to FLOAT8
-- For distance remove the 'km'. 

DROP TABLE IF EXISTS runner_orders_rawupdated;
CREATE TABLE runner_orders_rawupdated (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" TIMESTAMP,
  "distance" FLOAT8,
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);


INSERT INTO runner_orders_rawupdated
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', NULL, NULL, 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4', '15 minute', 'null'),
  ('9', '2', NULL, NULL, 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10', '10minutes', 'null');

--SELECT * FROM pizza_runner.runner_orders_rawupdated

-- 29/06 Correction and clean table
DROP TABLE IF EXISTS runner_orders_clean;
CREATE TABLE runner_orders_clean AS
SELECT order_id, 
runner_id,
pickup_time,
distance,
  CASE 
  WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
  WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
  WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
  WHEN duration = 'null' THEN ''
  ELSE duration 
  END AS duration,
  CASE
    WHEN cancellation = 'null' THEN ''
    ELSE cancellation
    END AS cancellation
FROM runner_orders_rawupdated;

--SELECT * FROM runner_orders_clean;




DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);

INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);

INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);

INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
/*I had challenges filling the missing values for customer_orders
and runner_order I used COALESCE to fill in missing values but that
didn't work i.e
UPDATE your_table
SET exclusions = COALESCE(exclusions, 'N/A'),
    extras = COALESCE(extras, 'N/A')
WHERE exclusions IS NULL OR extras IS NULL;
The above query didn't replace the missing values because they are some data values.
SOLUTION - The assumed missing values were 'null', '', and IS NULL. They are not 
blank spaces. The below update set the 'null', '', and IS NULL to 'N/A'
N.B- Difficulty using one line of code */

UPDATE pizza_runner.customer_orders
SET exclusions = '{}'   
WHERE exclusions IS NULL OR exclusions = '{null}';

UPDATE pizza_runner.customer_orders
SET exclusions = COALESCE(exclusions, '{}');


--WHERE exclusions IN('null', '');


UPDATE pizza_runner.customer_orders
SET extras = 'N/A'   
WHERE extras IN ('null', '');

UPDATE pizza_runner.customer_orders
SET extras = 'N/A'   
WHERE extras IS NULL;

UPDATE pizza_runner.runner_orders
SET pickup_time = 'N/A'
WHERE pickup_time = 'null';

UPDATE pizza_runner.runner_orders
SET distance = 'N/A'
WHERE distance = 'null';

UPDATE pizza_runner.runner_orders
SET duration = 'N/A'
WHERE duration = 'null';

UPDATE pizza_runner.runner_orders
SET cancellation = 'N/A'
WHERE cancellation IN ('null', '');

UPDATE pizza_runner.runner_orders
SET cancellation = 'N/A'
WHERE cancellation IS NULL;

	

SELECT * FROM pizza_runner.runner_orders;
select extras from pizza_runner.customer_orders WHERE extras IS NULL
SELECT * FROM pizza_runner.customer_orders;

/*TRUNCATE TABLE pizza_runner.customer_orders;*/
/*
How many Vegetarian and Meatlovers were ordered by each customer?
What was the maximum number of pizzas delivered in a single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?
*/

/*  PIZZA METRICS
Que 1 - How many pizzas were ordered?*/
SELECT COUNT(pizza_id) AS total_pizza_ordered FROM pizza_runner.customer_orders;

/* Que 2 -How many unique customer orders were made?*/
SELECT COUNT(DISTINCT order_id) AS unique_customers FROM pizza_runner.customer_orders;

/* Que 3 -How many successful orders were delivered by each runner?*/
SELECT COUNT(DISTINCT order_id) AS successful_delivery, runner_id 
FROM runner_orders_clean
WHERE pickup_time IS NOT NULL
GROUP BY runner_id
ORDER BY successful_delivery DESC;

/* Que 4 -How many of each type of pizza was delivered?*/
WITH pizza_type_delivered AS(
  SELECT pizza_id, COUNT(*) AS pizza_type
  FROM pizza_runner.customer_orders customerorders
  JOIN pizza_runner.runner_orders_clean runnerorders
  ON customerorders.order_id = runnerorders.order_id
  WHERE pickup_time IS NOT NULL
  GROUP BY pizza_id
  ORDER BY pizza_type DESC)
SELECT pizza_id, pizza_type
FROM pizza_type_delivered;

/* Que 5 -How many Vegetarian and Meatlovers were ordered by each customer?*/
SELECT  customer_id, COUNT(*) AS pizza_count, pizza_name
FROM pizza_runner.customer_orders customerorders
JOIN pizza_runner.pizza_names pizzaname
ON customerorders.pizza_id = pizzaname.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

/* Que 6 -What was the maximum number of pizzas delivered in a single order?*/
WITH ma_pizza_delivered AS(
  SELECT customerorders.order_id, COUNT(pizza_id) AS total_pizza
  FROM pizza_runner.customer_orders customerorders
  JOIN pizza_runner.runner_orders_clean runnerorders
  ON customerorders.order_id = runnerorders.order_id
  WHERE pickup_time IS NOT NULL
  GROUP BY customerorders.order_id
  ORDER BY total_pizza DESC)

SELECT MAX(total_pizza) AS maximumpizza
FROM ma_pizza_delivered;



/* Que 7 -For each customer, how many delivered pizzas had at least 1 change
and how many had no changes?*/


-- correction after reading re. need to review filling missing values to get accurate fig.
WITH pizza_change_delivered AS(
SELECT customerorders.customer_id, customerorders.order_id,
    CASE WHEN exclusions = '' AND extras = '' THEN 'no_change'
    --ELSE 'change' END AS pizza_change
    WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 'change'
    WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 'change'
       END AS pizza_change
FROM pizza_runner.customer_orders customerorders
JOIN pizza_runner.runner_orders_clean runnerorders
ON customerorders.order_id = runnerorders.order_id
WHERE pickup_time IS NOT NULL)
--GROUP BY customer_id
--ORDER BY pizza_change;
SELECT customer_id, pizza_change, COUNT(pizza_change) AS no_delivered
FROM pizza_change_delivered
WHERE pizza_change = 'no_change' OR pizza_change = 'change'
GROUP BY customer_id, pizza_change
ORDER BY customer_id

8. /*How many pizzas were delivered that had both exclusions and extras?*/


--correction
WITH pizza_change_delivered AS(
  SELECT customerorders.customer_id, customerorders.order_id,
  CASE WHEN exclusions != '' AND extras != '' THEN 'change'
        END AS pizza_change
        --END AS pizza_change
  FROM pizza_runner.customer_orders customerorders
  JOIN pizza_runner.runner_orders_clean runnerorders
  ON customerorders.order_id = runnerorders.order_id
  WHERE pickup_time IS NOT NULL)
SELECT COUNT(pizza_change) AS changes
FROM pizza_change_delivered

/*Que 9 -What was the total volume of pizzas ordered for each hour of the day?*/
SELECT order_time,
    EXTRACT(HOUR FROM order_time) AS order_hour,
    TO_CHAR(order_time, 'Day') AS order_day,
    COUNT(*) AS total_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY order_time, order_hour, order_day
ORDER BY order_time DESC;

/* Que 10 -What was the volume of orders for each day of the week?*/
SELECT 
    TO_CHAR(order_time, 'Day') AS order_day,
    COUNT(*) AS total_orders
FROM pizza_runner.customer_orders
GROUP BY order_day
ORDER BY total_orders DESC;

/* B. Runner and Customer Experience*/

/* Que 1 -How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/

SELECT DATE_TRUNC('week', registration_date) AS week_start,
COUNT(runner_id) AS runners_signed_up
FROM pizza_runner.runners
WHERE registration_date >= '2021-01-01'
GROUP BY week_start
ORDER BY week_start;


/* Que 2 -What was the average time in minutes it took for each runner to arrive at the 
Pizza Runner HQ to pickup the order?*/
--ERROR

SELECT runner_id,
    AVG(EXTRACT(EPOCH FROM (pickup_time - order_time)) / 60) 
    AS avg_arrival_time_minutes
FROM runner_orders_clean r
JOIN customer_orders c ON r.order_id = c.order_id
WHERE pickup_time IS NOT NULL
GROUP BY runner_id
ORDER BY avg_arrival_time_minutes ASC;

/* Que 3 -Is there any relationship between the number of pizzas and how
long the order takes to prepare?*/

SELECT r.order_id, COUNT(pizza_id) AS total_pizzas, 
       	   EXTRACT(EPOCH FROM (pickup_time - order_time)) / 60 AS prep_time_minutes
FROM runner_orders r
JOIN customer_orders c ON r.order_id = c.order_id
WHERE pickup_time IS NOT NULL
GROUP BY r.order_id, prep_time_minutes
ORDER BY total_pizzas DESC;

/* Que 4 -What was the average distance travelled for each customer?*/
SELECT c.customer_id, AVG(r.distance) AS avg_distance_km
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY avg_distance_km DESC;

/* Que 5-What was the difference between the longest
and shortest delivery times for all orders?*/

SELECT 
    MAX(duration) AS longest_delivery_minutes,
    MIN(duration) AS shortest_delivery_minutes,
    MAX(duration) - MIN(duration) AS time_difference_minutes
FROM runner_orders
WHERE duration > INTERVAL '0 minutes' 
AND cancellation NOT LIKE '%Cancellation%';

/*Que 6 -What was the average speed for each runner for each delivery and do
you notice any trend for these values?*/

SELECT 
    runner_id,
    order_id,
    distance / (EXTRACT(EPOCH FROM duration) / 3600) AS avg_speed_kmh -- Convert seconds to hours
FROM runner_orders
WHERE distance IS NOT NULL 
AND duration > INTERVAL '0 minutes'
ORDER BY runner_id, order_id;

/*Que 7 -What is the successful delivery percentage for each runner?*/

SELECT 
    runner_id, 
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN cancellation IS NULL OR cancellation = '' THEN 1 END) AS successful_deliveries,
    ROUND(
        (COUNT(CASE WHEN cancellation IS NULL OR cancellation = '' THEN 1 END) * 100.0) / COUNT(*), 
        2
    ) AS success_percentage
FROM runner_orders
GROUP BY runner_id
ORDER BY success_percentage DESC;

--C Ingredient Optimisation

SET search_path = pizza_runner;

/* Que 1 -What are the standard ingredients for each pizza?*/
--change column toppings from string to integer 
ALTER TABLE pizza_runner.pizza_recipes 
ALTER COLUMN toppings TYPE INTEGER[] 
USING string_to_array(toppings, ',')::INTEGER[]; --string_to_array splits the comma-separated string into an array

--Que 1
SELECT pn.pizza_name, 
       ARRAY_AGG(pt.topping_name) AS toppings --aggregates topping_name into an array
FROM pizza_recipes pr
JOIN pizza_names pn ON pr.pizza_id = pn.pizza_id
JOIN pizza_toppings pt ON pt.topping_id = ANY(pr.toppings)
GROUP BY pn.pizza_name;


-- QUE 2 - What was the most commonly added extra?
SELECT pt.topping_name, COUNT(*) AS frequency
FROM customer_orders c
JOIN pizza_toppings pt 
ON pt.topping_id = ANY(string_to_array(c.extras, ',')::integer[])
WHERE c.extras != 'N/A'
GROUP BY pt.topping_name
ORDER BY frequency DESC
LIMIT 1;

/* Que 3- What was the most common exclusion?*/
SELECT pt.topping_name, COUNT(*) AS frequency
FROM customer_orders c
JOIN pizza_toppings pt 
ON pt.topping_id = ANY(string_to_array(c.exclusions, ',')::integer[])
WHERE c.exclusions != 'N/A'
GROUP BY pt.topping_name
ORDER BY frequency DESC
LIMIT 1;

/* Que 4 -Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/

SELECT c.order_id,
       pn.pizza_name ||
       CASE WHEN c.exclusions != 'N/A' THEN ' - Exclude ' || 
            array_to_string((SELECT ARRAY_AGG(pt.topping_name) 
                             FROM pizza_toppings pt 
                             WHERE pt.topping_id = ANY(string_to_array(c.exclusions, ',')::integer[])), ', ') 
       ELSE '' END ||
       CASE WHEN c.extras <> 'N/A' THEN ' - Extra ' || 
            array_to_string((SELECT ARRAY_AGG(pt.topping_name) 
                             FROM pizza_toppings pt 
                             WHERE pt.topping_id = ANY(string_to_array(c.extras, ',')::integer[])), ', ') 
       ELSE '' END AS order_item
FROM customer_orders c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
ORDER BY c.order_id;

--Que 5- with ERROR:  invalid input syntax for type integer: "N/A" 
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

SELECT c.order_id,
       pn.pizza_name || ': ' || 
       array_to_string(
           ARRAY(
               SELECT 
                   CASE 
                       WHEN pt.topping_id = ANY(string_to_array(c.extras, ',')::integer[]) 
                            AND pt.topping_id = ANY(pr.toppings) 
                       THEN '2x' || pt.topping_name
                       ELSE pt.topping_name 
                   END
               FROM pizza_toppings pt
               WHERE pt.topping_id = ANY(pr.toppings)
                  OR pt.topping_id = ANY(string_to_array(c.extras, ',')::integer[])
               ORDER BY pt.topping_name
           ),
       ', ') AS ingredient_list
FROM customer_orders c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id;

SELECT co.order_id,
       pn.pizza_name || ': ' || 
       array_to_string(
           ARRAY(
               SELECT 
                   CASE 
                       WHEN pt.topping_id = ANY(NULLIF(string_to_array(co.extras, ',')::int[], '{}')) 
                            AND pt.topping_id = ANY(pr.toppings) 
                       THEN '2x' || pt.topping_name
                       ELSE pt.topping_name 
                   END
               FROM pizza_toppings pt
               WHERE pt.topping_id = ANY(pr.toppings)
                  OR pt.topping_id = ANY(NULLIF(string_to_array(co.extras, ',')::int[], '{}'))
               ORDER BY pt.topping_name
           ),
       ', ') AS ingredient_list
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id;

SELECT co.order_id,
       pn.pizza_name || ': ' || 
       array_to_string(
           ARRAY(
               SELECT 
                   CASE 
                       WHEN pt.topping_id = ANY(
                           COALESCE(NULLIF(string_to_array(co.extras, ',')::int[], '{}'), ARRAY[]::int[])
                       ) 
                       AND pt.topping_id = ANY(pr.toppings) 
                       THEN '2x' || pt.topping_name
                       ELSE pt.topping_name 
                   END
               FROM pizza_toppings pt
               WHERE pt.topping_id = ANY(pr.toppings)
                  OR pt.topping_id = ANY(
                      COALESCE(NULLIF(string_to_array(co.extras, ',')::int[], '{}'), ARRAY[]::int[])
                  )
               ORDER BY pt.topping_name
           ),
       ', ') AS ingredient_list
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id;

/* Que 6 -What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?*/

SELECT pt.topping_name, COUNT(*) AS total_quantity
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON pt.topping_id = ANY(pr.toppings)
WHERE r.cancellation = 'N/A'  -- Only include delivered orders
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;

--D. Pricing and Ratings
/*
Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
*/

--Que 1 - If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?
--check answer ,it should be more than 30
SELECT SUM(
    CASE 
        WHEN pn.pizza_name = 'Meat Lovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
        ELSE 0
    END
) AS total_revenue
FROM customer_orders c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL OR r.cancellation IN('null', '');

-- Que 2  
--What if there was an additional $1 charge for any pizza extras?Add cheese is $1 extra

SELECT SUM(
    CASE 
        WHEN pn.pizza_name = 'Meat Lovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
        ELSE 0
    END 
    + COALESCE(array_length(c.extras, 1) * 1, 0) -- $1 per extra topping

) AS total_revenue
FROM customer_orders c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IN('null', '') OR r.cancellation IS NULL;


--Que 3
SELECT * FROM runner_ratings;
CREATE TABLE runner_ratings (
    rating_id SERIAL PRIMARY KEY,      -- Unique identifier for each rating
    order_id INT, --REFERENCES runner_orders(order_id) ON DELETE CASCADE,  -- Links to successful orders
    runner_id INT, --REFERENCES runner_orders(runner_id) ON DELETE CASCADE, -- Links to assigned runner
    customer_id INT, --REFERENCES customer_orders(customer_id) ON DELETE CASCADE, -- Links to customer
    rating INT CHECK (rating BETWEEN 1 AND 5),  -- Ratings between 1 and 5
    review TEXT,  -- Optional customer feedback
    rating_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- When the rating was submitted
);
--INSERT data into runner_ratings table

INSERT INTO runner_ratings (order_id, runner_id, customer_id, rating, review)
VALUES
    (1, 1, 101, 5, 'Fast delivery, great service!'),
    (2, 1, 101, 4, 'Good, but took a bit longer than expected.'),
    (3, 1, 101, 5, 'Amazing service, will order again!'),
    (4, 2, 103, 3, 'Okay service, but could be faster.'),
    (5, 1, 104, 4, 'Friendly runner, but arrived a few minutes late.'),
    (7, 2, 105, 5, 'Great timing, very polite!'),
    (8, 2, 105, 4, 'Quick and smooth delivery.'),
    (10, 1, 104, 5, 'Perfect service, highly recommended!');

-- Que 4 
-- Using your newly generated table - can you join all of the information 
-- together to form a table which has the following information for successful deliveries?

SELECT c.customer_id, c.order_id, r.runner_id, rr.rating, c.order_time, r.pickup_time, 
	   AGE(r.pickup_time, c.order_time) AS time_between_order_and_pickup,
       r.duration,
         ROUND(distance::NUMERIC / (EXTRACT(EPOCH FROM duration) / 3600), 2)
		 AS avg_speed_kmh, -- Calculates speed in km/h

	     COUNT(c.pizza_id) AS total_pizzas
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
JOIN runner_ratings rr ON c.order_id = rr.order_id
WHERE r.cancellation IN('null', '') OR r.cancellation IS NULL -- Filters successful deliveries
GROUP BY c.customer_id, c.order_id, r.runner_id, rr.rating, c.order_time, r.pickup_time, r.duration, r.distance;


-- Que 5 
--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with 
--no cost for extras and each runner is paid $0.30 per kilometre traveled 
-- how much money does Pizza Runner have left over after these deliveries?
SELECT 
    SUM(
        CASE 
            WHEN pn.pizza_name = 'Meat Lovers' THEN 12
            WHEN pn.pizza_name = 'Vegetarian' THEN 10
            ELSE 0
        END
    ) AS total_revenue,
    SUM(NULLIF(REPLACE(r.distance::TEXT, 'km', '')::NUMERIC, 0) * 0.30) AS total_runner_payments,
    (SUM(
        CASE 
            WHEN pn.pizza_name = 'Meat Lovers' THEN 12
            WHEN pn.pizza_name = 'Vegetarian' THEN 10
            ELSE 0
        END
    ) - SUM(NULLIF(REPLACE(r.distance::TEXT, 'km', '')::NUMERIC, 0) * 0.30)) AS final_profit
FROM customer_orders c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation = 'N/A'; -- Exclude canceled orders

