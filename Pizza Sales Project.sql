-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(pizzas.price * orders_details.quantity),
            2) AS Total_revenue
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id;
    

-- Identify the highest-priced pizza.    

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS Pizza_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY Pizza_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS Total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS Total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category;


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Order_hour,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY Order_hour;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id) AS Pizzas
FROM
    pizza_types
GROUP BY category;

use pizza;
-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(daily_quantity), 0) AS average_quantity_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS daily_quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS daily_totals;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza category to total revenue.

SELECT 
    pizza_types.category,
    round(SUM(orders_details.quantity * pizzas.price) / (SELECT 
    ROUND(SUM(pizzas.price * orders_details.quantity),
            2) 
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id) * 100,2) as Percentage_Contibution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category;

-- Analyze the cumulative revenue generated over time.

SELECT 
    order_date,
    revenue,
    ROUND(SUM(revenue) OVER (ORDER BY order_date),2) AS cum_revenue
FROM
    (SELECT 
        orders.order_date,
        ROUND(SUM(orders_details.quantity * pizzas.price),2) AS revenue
    FROM 
        orders
    JOIN 
        orders_details ON orders.order_id = orders_details.order_id
    JOIN 
        pizzas ON orders_details.pizza_id = pizzas.pizza_id
    GROUP BY 
        orders.order_date
    ) AS sales;
    
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category    

SELECT 
    category,
    name,
    Total_revenue,
    Ranking
FROM (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(orders_details.quantity * pizzas.price) AS Total_revenue,
        RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(orders_details.quantity * pizzas.price) DESC) AS Ranking
    FROM 
        pizza_types
    JOIN 
        pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN 
        orders_details ON pizzas.pizza_id = orders_details.pizza_id
    GROUP BY 
        pizza_types.category, pizza_types.name
) AS ranked_pizzas
WHERE 
    Ranking <= 3;


