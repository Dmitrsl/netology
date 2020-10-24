select f.title, a.first_name || ' ' || a.last_name as name, row_number() OVER (PARTITION BY f.title) as num_films
from film  f
join film_actor fa on f.film_id = fa.film_id 
join actor a on fa.actor_id  = a.actor_id;

WITH cte_film AS (
select  s.first_name || ' ' || s.last_name as staff_name, p.payment_id 
from staff s
join payment p on s.staff_id  = p.staff_id
)
select distinct cte_film.staff_name, count(cte_film.staff_name) over (partition  by cte_film.staff_name) from cte_film;