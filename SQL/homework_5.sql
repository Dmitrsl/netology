-- сделайте запрос к таблице rental. 
-- Используя оконую функцию добавьте колонку с порядковым номером аренды для каждого пользователя (сортировать по rental_date)
with cte_rental as (
select *, row_number() OVER (PARTITION BY r.customer_id order by r.rental_date DESC) as num_renta
from rental r
)
select * from cte_rental;
--для каждого пользователя подсчитайте сколько он брал в аренду фильмов со специальным атрибутом Behind the Scenes
explain (analyze)
with cte_rental as (
select customer_id, f.special_features, row_number() OVER (PARTITION BY r.customer_id order by r.rental_date DESC) as num_renta
from rental r
join inventory inv using(inventory_id)
join  film f using(film_id)
where f.special_features  = array['Behind the Scenes'] --'Behind the Scenes' = any (f.special_features)
)
select  cte.customer_id, count(cte.customer_id) as count_behind
from  cte_rental cte
group by cte.customer_id
order by count_behind desc;
-- 1-1.2 ms
create view behind as
	with cte_rental as (
	select customer_id, f.special_features, row_number() OVER (PARTITION BY r.customer_id order by r.rental_date DESC) as num_renta
	from rental r
	join inventory inv using(inventory_id)
	join  film f using(film_id)
	where 'Behind the Scenes' = any (f.special_features)
	)
	select  cte.customer_id, count(cte.customer_id) as count_behind
	from  cte_rental cte
	group by cte.customer_id
	order by count_behind desc;
explain (analyze)
select * from behind;
--создайте материализованное представление с этим запросом
create materialized view behind_material as
	with cte_rental as (
	select customer_id, f.special_features, row_number() OVER (PARTITION BY r.customer_id order by r.rental_date DESC) as num_renta
	from rental r
	join inventory inv using(inventory_id)
	join  film f using(film_id)
	where 'Behind the Scenes' = any (f.special_features)
	)
	select  cte.customer_id, count(cte.customer_id) as count_behind
	from  cte_rental cte
	group by cte.customer_id
	order by count_behind desc;

select * from behind_material;
explain (analyze)
select * from behind_material;
--обновите материализованное представление
refresh materialized view behind_material;
explain analyze
select * from behind_material;
--напишите три варианта условия для поиска Behind the Scenes
select f.special_features from  film f
where array['Behind the Scenes'] && (f.special_features);

select f.special_features from  film f
where 'Behind the Scenes' = any (f.special_features);

select array_to_string(f.special_features,' ',' ') as n 
from  film f
where array_to_string(f.special_features,' ',' ') like '%Behind the Scenes%';

-- Здесь только Behind the Scenes
with cte as (
select *, unnest(f.special_features) as n from  film f
)
select cte.special_features 
from  cte 
where cte.special_features  = array['Behind the Scenes'];

select *, unnest(f.special_features) as n from  film f
where f.special_features  = array['Behind the Scenes'];




