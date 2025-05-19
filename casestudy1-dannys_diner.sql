SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.menu;
SELECT * FROM dannys_diner.members;

/* Que 1- What is the total amount each customer spent at the restaurant?*/
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY total_amount DESC;

/* Que 2- How many days has each customer visited the restaurant?*/
SELECT s.customer_id, COUNT(DISTINCT s.order_date) AS total_days
FROM dannys_diner.sales s
GROUP BY s.customer_id;

/* Q3- What was the first item from the menu purchased by each customer?*/
SELECT DISTINCT s.customer_id, s.order_date, m.product_name AS first_item
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
ORDER BY s.order_date 
LIMIT 3;

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
order by total_item desc;


/* Q5-Which item was the most popular for each customer?*/ 

SELECT DISTINCT ON(s.customer_id) s.customer_id, m.product_name, COUNT (*) AS most_popular 
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, product_name
ORDER BY s.customer_id, most_popular DESC;


/* Que 6- Which item was purchased first by the customer after they became a member?


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

/*Ques 8 - What is the total items and amount spent for each member before they became a member?*/
SELECT s.customer_id, SUM(m.price) total_amount, COUNT (s.product_id) AS total_items
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members r
ON s.customer_id = r.customer_id
WHERE s.order_date < r.join_date AND s.order_date <> r.join_date
GROUP BY s.customer_id
ORDER BY total_amount;

/*Que 9- If each $1 spent equates to 10 points and sushi has a 2x points 
multiplier - how many points would each customer have?
PostgreSQL uses CASE Instead of If statement in SQL. 
Line 90-94 calculates total points and insert total points
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


/* Que 10- In the first week after a customer joins the program (including 
their join date) they earn 2x points on all items, not just sushi 
- how many points do customer A and B have at the end of January?*/

SELECT s.customer_id, m.product_name, SUM(
           CASE 
               -- Double points in the first week after joining
               WHEN s.order_date BETWEEN r.join_date AND r.join_date + INTERVAL '6 days' 
               THEN m.price * 20
               -- Normal sushi bonus
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
AND s.customer_id IN('A','B')
GROUP by s.customer_id, m.product_name
ORDER BY total_points;

