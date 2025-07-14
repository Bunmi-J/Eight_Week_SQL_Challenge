SELECT * FROM dannys_diner.sales;

/*SELECT * FROM dannys_diner.menu;
SELECT * FROM dannys_diner.members;

/* Que 1- What is the total amount each customer spent at the restaurant?*/
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY total_amount DESC;

/* Que 2- How many days has each customer visited the restaurant?*/
SELECT customer_id, COUNT(DISTINCT order_date) AS total_days
FROM dannys_diner.sales 
GROUP BY customer_id;

/* Q3- What was the first item from the menu purchased by each customer?*/
SELECT DISTINCT s.customer_id, s.order_date, m.product_name AS first_item
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
ORDER BY s.order_date 
LIMIT 3;

/*Corrected Ans after review*/
WITH first_item AS(

SELECT s.customer_id, s.order_date, m.product_name,
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM first_item
WHERE rank = 1
GROUP BY customer_id, product_name;


/*correct Ans*/
SELECT DISTINCT ON (s.customer_id) s.customer_id, s.order_date, m.product_name
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
ORDER BY s.customer_id, s.order_date ASC;

/* Q4 -What is the most purchased item on the menu and how many times was it purchased by all customers?*/
SELECT count (s.product_id) AS total_item, m.product_name
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
order by total_item desc
LIMIT 1;


/* Q5-Which item was the most popular for each customer?*/ 

SELECT DISTINCT ON(s.customer_id) s.customer_id, m.product_name, COUNT (*) AS most_popular 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, product_name
ORDER BY s.customer_id, most_popular DESC;

/* correction after review*/
WITH popular_item AS(
    SELECT s.customer_id, m.product_name, COUNT(*) AS item_count,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*)DESC) AS rank_popular
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, item_count 
FROM popular_item
WHERE rank_popular = 1;
--GROUP BY customer_id,product_name, item_count;

 

/* Que 6- Which item was purchased first by the customer after they became a member?*/


SELECT s.customer_id, s.order_date, m.product_name
FROM dannys_diner.sales s
JOIN dannys_diner.members mb ON s.customer_id = mb.customer_id
JOIN dannys_diner.menu m ON s.product_id = m.product_id
WHERE s.order_date >= mb.join_date
ORDER BY s.customer_id, s.order_date
LIMIT 1;

--correction after reading more about subquery and CTE
SELECT customer_id, order_date, join_date, product_name
FROM -- subquery
    (SELECT s.customer_id, s.order_date, mb.join_date, m.product_name,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS order_rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.members mb
    ON s.customer_id = mb.customer_id
    JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
    WHERE order_date > join_date
    )
     AS loyal_members
WHERE order_rank = 1;

-- using CTE with question 6
WITH loyal_members AS
    (SELECT s.customer_id, s.order_date, mb.join_date, m.product_name,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS order_rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.members mb
    ON s.customer_id = mb.customer_id
    JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
    WHERE s.order_date > mb.join_date
    )
    
SELECT customer_id, order_date, join_date, product_name
FROM loyal_members     
WHERE order_rank = 1;





Que 10- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/

SELECT s.customer_id, s.product_id, m.product_name, r.join_date
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members r
ON s.customer_id = r.customer_id
WHERE s.order_date = r.join_date;

/* Que 7- Which item was purchased just before the customer became a member?*/
SELECT s.customer_id, m.product_name, s.order_date, r.join_date
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members r
ON s.customer_id = r.customer_id
WHERE s.order_date < r.join_date AND s.order_date <> r.join_date
ORDER BY r.join_date DESC;

--correction after reading CTE
WITH loyal_members AS
    (SELECT s.customer_id, s.order_date, mb.join_date, m.product_name,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS order_rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.members mb
    ON s.customer_id = mb.customer_id
    JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
    WHERE s.order_date < mb.join_date 
    AND order_date != join_date
    )
    
SELECT customer_id, order_date, join_date, product_name
FROM loyal_members     
WHERE order_rank = 1;


/*Ques 8 - What is the total items and amount spent for each member before they became a member?*/

SELECT s.customer_id, SUM(m.price) AS total_amount, COUNT (s.product_id) AS total_items
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members r
ON s.customer_id = r.customer_id
WHERE s.order_date < r.join_date AND s.order_date <> r.join_date
GROUP BY s.customer_id
ORDER BY total_amount;

--query written using CTE
WITH totalitem_before_membership AS(
    SELECT s.customer_id, SUM(m.price) AS total_amount, COUNT(s.product_id) AS total_items, r.join_date
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
    JOIN dannys_diner.members r
    ON s.customer_id = r.customer_id
    WHERE s.order_date < r.join_date AND s.order_date <> r.join_date
    GROUP BY s.customer_id, r.join_date
    )
SELECT total_items, total_amount
FROM totalitem_before_membership;

/*Que 9- If each $1 spent equates to 10 points and sushi has a 2x points 
multiplier - how many points would each customer have?
PostgreSQL uses CASE Instead of If statement in SQL. 
Line 201-205 calculates total points and insert total points
*/

SELECT s.customer_id, m.product_name, SUM(
           CASE 
               WHEN m.product_name = 'Sushi' THEN m.price * 20  -- 2x points for sushi
               ELSE m.price * 10  -- Normal points for other items
           END
       ) AS total_points

FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP by s.customer_id, m.product_name
ORDER BY total_points;

--correction after reading CTE. Careful when using aggregate function i.e SUM within
-- inner query and outer curry. You can calculate total point in the inner query, then
-- use SUM in the outer query 

WITH total_points_earn AS(
SELECT s.customer_id, m.product_name, (
           CASE 
               WHEN m.product_name = 'Sushi' THEN m.price * 20  -- 2x points for sushi
               ELSE m.price * 10  -- Normal points for other items
           END
       ) AS total_points

FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id)
--GROUP BY s.customer_id, m.product_name
--ORDER BY total_points)

SELECT customer_id, SUM(total_points) AS totalpoints
FROM total_points_earn
GROUP BY customer_id
ORDER BY totalpoints DESC;


/* Que 10- In the first week after a customer joins the program (including 
their join date) they earn 2x points on all items, not just sushi 
- how many points do customer A and B have at the end of January?*/

SELECT s.customer_id, m.product_name, SUM(
           CASE 
               -- Double points in the first week after joining
               WHEN s.order_date BETWEEN r.join_date AND r.join_date + INTERVAL '6 day' 
               THEN m.price * 20
               -- Normal sushi bonus
               --WHEN m.product_name = 'Sushi' THEN m.price * 20
               -- Normal points for other items
               ELSE m.price * 10
           END
       ) AS total_points


FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members r
ON s.customer_id = r.customer_id
WHERE s.order_date <= '2021-01-31'
AND s.customer_id IN('A','B')
GROUP by s.customer_id, m.product_name
ORDER BY total_points;

--correction after reading CTE
WITH totalpoint_in_january AS(
    SELECT s.customer_id, m.product_name, (
           CASE 
               -- Double points in the first week after joining
               WHEN s.order_date BETWEEN r.join_date AND r.join_date +  6  
               THEN m.price * 20
               -- Normal points for other period
              WHEN m.product_name = 'Sushi' THEN m.price * 20
               -- Normal points for other items
               ELSE m.price * 10
          END
       ) AS total_points

    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
    JOIN dannys_diner.members r
    ON s.customer_id = r.customer_id
    WHERE s.order_date <= '2021-01-31'
    AND s.customer_id IN('A','B'))
    --GROUP by s.customer_id, m.product_name
   -- ORDER BY total_points)

SELECT customer_id, SUM(total_points) AS january_point
FROM totalpoint_in_january
GROUP BY customer_id
ORDER BY january_point DESC;
*/

