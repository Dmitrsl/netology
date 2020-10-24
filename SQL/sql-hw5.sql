explain analyze
select r.customer_id , count(r.inventory_id )
from rental r
left join inventory i on r.inventory_id = i.inventory_id 
left join film f on f.film_id = i.film_id 
where 'Behind the Scenes' = any (f.special_features)
group by r.customer_id;


