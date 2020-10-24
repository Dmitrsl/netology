select payment_date::date as payday, sum(p.amount)
from payment p 
group by payday;

select c.name, count(r.rental_id) as num_rental, sum(p.amount)
from category c
left join film_category fc using(category_id)
left join film f using(film_id)
join inventory i using(film_id)
join rental r using(inventory_id)
join payment p using(rental_id)
group by c.name
order by num_rental desc limit(5) offset(5);

select c.name, round(avg(f.rental_rate), 2) as "средний"
from category c
left join film_category fc using(category_id)
left join film f using(film_id)
group by c.name
order by "средний" desc;


select  c.first_name, c.last_name,  'Email adress is: ' || c.email, sum(p.amount)
from customer c
join rental r using(customer_id)
join payment p using(customer_id)
where extract(month from r.rental_date::date) = 5
and extract(day from r.rental_date::date) between 24 and 29
group by c.customer_id
order by sum desc limit 5;




