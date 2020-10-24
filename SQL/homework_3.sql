select * from staff s2;

SELECT c.store_id, count(c.customer_id)
FROM customer c
group by c.store_id
having count(c.customer_id) >= 300;

select cu.first_name || ' ' || cu.last_name as customer_name, city.city
from customer cu
join address a on cu.address_id = a.address_id
join city on a.city_id = city.city_id;
--add
SELECT c.store_id, count(c.customer_id)
FROM customer c
group by c.store_id
having count(c.customer_id) >= 300;
--
select staff.first_name || ' ' || staff.last_name as staff_name, city.city
from staff
join address a on staff.address_id = a.address_id
join city on a.city_id = city.city_id
where staff.store_id = 
(SELECT c.store_id
FROM customer c
group by c.store_id
having count(c.customer_id) >= 300);
--

