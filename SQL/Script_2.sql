-- practice 1
select f.title, l.name
from film f
join language l on f.language_id  = l.language_id;

select f.title , a.first_name , a.last_name 
from film f
join film_actor f_a on f.film_id = f_a.film_id 
join actor  a on f_a.actor_id = a.actor_id 
where f.film_id = 508;
-- practice 2
select count(f.title)
from film f
join film_actor f_a on f.film_id = f_a.film_id 
join actor  a on f_a.actor_id = a.actor_id 
where f.film_id = 384;
-- practice 3
select f.title, count(f_a.actor_id)
from film f
join film_actor f_a on f.film_id = f_a.film_id
group by f.title having count(f_a.actor_id) >= 10;
-- practice 4
select f.title , a.first_name , a.last_name, a.first_name || ' ' || a.last_name as "name"
count("name") over(partition by "name")
from film f
join film_actor f_a on f.film_id = f_a.film_id 
join actor  a on f_a.actor_id = a.actor_id 
order by a.first_name;
select f.title, f.description, a.first_name || ' ' || a.last_name as actor_name,
count(f.film_id) over (partition by a.actor_id ) as films_count
from film f
join film_actor fa on fa.film_id = f.film_id 
join actor a on a.actor_id = fa.actor_id; 


