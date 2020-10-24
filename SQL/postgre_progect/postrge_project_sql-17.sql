select * from airports_data;
-- В каких городах больше одного аэропорта?
select a.city ->> 'ru' as city, count(a.airport_name)
from airports_data a
group by a.city
having count(a.airport_name) > 1;

-- В каких аэропортах есть рейсы, которые обслуживаются самолетами с максимальной дальностью перелетов?

with range_max as(
    select a_d."range"
    from aircrafts_data a_d
    order by "range" desc limit 1)
select distinct 
    a_d.model ->> 'ru' as model_name,
    a_d."range",
    a.airport_name ->> 'ru' as airport_
from aircrafts_data a_d
join flights f on f.aircraft_code = a_d.aircraft_code
join airports_data a on a.airport_code = f.arrival_airport or airport_code = f.departure_airport
where "range" = (select * from range_max);

-- Были ли брони, по которым не совершались перелеты?
select t.book_ref, t_f.flight_id, b.boarding_no 
from tickets t 
join ticket_flights t_f using(ticket_no)
join boarding_passes b using(ticket_no)
where t.book_ref is null;


-- Самолеты каких моделей совершают наибольший % перелетов?
with summ as (select count (*) from flights)
select a_d.model ->> 'ru' as model_name, round(100 * count(*)/(select * from summ)::numeric, 1)  as perc
from flights f
join aircrafts_data a_d using(aircraft_code)
group by a_d.model
order by perc desc;
-- Тут можно проценты не считать, а сделать вывод по количеству рейсов

-- Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом?
drop view bookings.business_amount_;
drop view bookings.econimy_amount_;
create or replace view econimy_amount_ as 
	select f.flight_id, tf.amount, tf.fare_conditions, f.departure_airport || ' - ' || f.arrival_airport  as e_route
	from ticket_flights tf 
	join flights f using(flight_id)
	join airports_data a on a.airport_code = f.arrival_airport
	where tf.fare_conditions = 'Economy';
create or replace view business_amount_ as 
	select f.flight_id, tf.amount, tf.fare_conditions, f.departure_airport || ' - ' || f.arrival_airport as b_route
	from ticket_flights tf 
	join flights f using(flight_id)
	join airports_data a on a.airport_code = f.arrival_airport
	where tf.fare_conditions = 'Business';
select ba.flight_id, ba.b_route, ba.amount business_amount, ea.amount econimy_amount
from business_amount_ ba 
join econimy_amount_ ea using(flight_id)
where ba.amount < ea.amount;

-- Узнать максимальное время задержки вылетов самолетов
select max(f.actual_departure - f.scheduled_departure)
from flights f
WHERE f.actual_departure is not null;

-- Между какими городами нет прямых рейсов*?
create or replace view cities_ as 
	select a.city || ' - ' || b.city as routes
	from airports a,airports b
	where a.city != b.city;
create or replace view  existing as 
    select distinct a.city as departure_city,
    b.city as arrival_city
    from  flights f
    join airports a on f.departure_airport = a.airport_code
    join airports b on f.arrival_airport = b.airport_code;
(select ci.routes from cities_ ci) except (select er.departure_city || ' - ' || er.arrival_city as routes from existing er);
-- С готовыми вьюшками
(select ci.departure_city || ' - ' || ci.arrival_city as routes from cities ci) except (select er.departure_city || ' - ' || er.arrival_city as routes from existing_routes er);

-- Между какими городами пассажиры делали пересадки*?
drop view transfers;
create MATERIALIZED VIEW IF NOT EXISTS  transfers as 
	select distinct tf.ticket_no, max(f.scheduled_departure) - min(f.scheduled_arrival) as transfer_time, 
	(
	(select unnest(regexp_split_to_array(STRING_AGG(f.departure_airport, ' '), '\s+'))) except (select unnest(regexp_split_to_array(STRING_AGG(f.arrival_airport , ' '), '\s+')))
	) as airport_code
	from ticket_flights tf
	join flights f using(flight_id)
	group by tf.ticket_no
	having (EXTRACT(minute from max(f.scheduled_departure) - min(f.scheduled_arrival)) > 0) and (
	EXTRACT(day from max(f.scheduled_departure) - min(f.scheduled_arrival)) < 1)
	and (not regexp_split_to_array(STRING_AGG(f.departure_airport, ' '), '\s+') @> regexp_split_to_array(STRING_AGG(f.arrival_airport , ' '), '\s+'));
select distinct city ->> 'ru' city
from transfers t 
join airports_data a_d using(airport_code);

-- Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы **
-- Кратчайшее расстояние между двумя точками A и B на земной поверхности (если принять ее за сферу) определяется зависимостью:
-- d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b)},
-- где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы данных пунктов, 
-- d — расстояние между пунктами, измеряемое в радианах длиной дуги большого круга земного шара.
-- Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
-- L = d·R, где R = 6371 км — средний радиус земного шара.
-- Для расчета расстояния между пунктами, расположенными в разных полушариях (северное-южное, восточное-западное) , знаки (±) у соответствующих параметров (широты или долготы) должны быть разными. 

create extension if not exists cube;
create extension if not exists earthdistance;

DROP FUNCTION earthdistance;
CREATE OR REPLACE function earthdistance(point, point)
RETURNS double precision 
AS '
select round(6371 * (acos( sin(radians($1[1])) * sin(radians($2[1])) + cos(radians($1[1])) * cos(radians($2[1])) * cos(radians($1[0] - $2[0]))) ));
-- select sin(60);
'
LANGUAGE sql ;
select distinct 
ap_d.airport_name ->> 'ru'  dep_airport, ap_a.airport_name ->> 'ru'  arr_airport,
ad.model ->> 'ru' model, ad."range",
earthdistance(ap_d.coordinates, ap_a.coordinates)
from flights f
join aircrafts_data ad using(aircraft_code)
join airports_data ap_d on f.departure_airport = ap_d.airport_code 
join airports_data ap_a on ap_a.airport_code = f.arrival_airport ;




