-- total orders

select count(order_id) as total_orders from orders;

-- total revenue

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_rev
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- highest priced pizza

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- most common pizza ordered

SELECT 
    p.size, COUNT(od.order_detail_id) AS count_pizza
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY count_pizza DESC
LIMIT 1;

-- top 5 most ordered pizza along with their quantity

SELECT 
    pt.name, SUM(od.quantity) AS total_quan
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quan DESC
LIMIT 5;

-- total quantity of each pizza category ordered

select pt.category,sum(od.quantity) as total_quant
from order_details od join pizzas p on 
od.pizza_id=p.pizza_id join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id group by pt.category;

--  distribution of order by hour of the day

select hour(orders.order_time), count(order_id) 
from orders
group by hour(orders.order_time) ;

-- category-wise distribution of pizzas

select category,count(pizza_type_id) 
from pizza_types
group by category ;

-- average number of pizzas ordered per day

SELECT 
    ROUND(AVG(sum_quantity), 0) AS avg_order_quantity
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS sum_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS total_orders;
    
-- top 3 most ordered pizza based on revenue

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- percentage contribution of each pizza to total revenue

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price))
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- cumulative revenue generated over time

select order_date,
sum(revenue)over(order by order_date) as cumulative
from
(select orders.order_date,
sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on order_details.order_id=orders.order_id
group by orders.order_date)as sales;

--  top 3 most ordered pizza types based on revenue for each pizza category

select category,name,revenue
from
(select category,name,revenue,
rank()over(partition by category order by revenue desc) as rank_num
from
(select pizza_types.category,pizza_types.name,
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category,pizza_types.name)as a)as b
where rank_num<=3;

