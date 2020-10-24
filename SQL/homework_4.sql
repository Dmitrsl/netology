create schema if not exists homework;
set search_path to homework;

-- show search_path;
-- drop table homework.lang;


-- таблица язык (в смысле английский, французский и тп)
create table if not exists lang (
    lang_id serial PRIMARY key,
    lang_name varchar(16) unique not null);
   
insert into lang (lang_name) values
    ('Russian'),
    ('English'),
    ('French'),
    ('Belorussian'),
    ('Chinese');

select * from lang;
-- таблица народность (в смысле славяне, англосаксы и тп)
create table if not exists nationality (
    nationality_id serial PRIMARY key,
    nationality_name varchar(32) unique not null);
   
insert into nationality (nationality_name) values
    ('Russian nationality'),
    ('English nationality'),
    ('French nationality'),
    ('Belorussian nationality'),
    ('Chinese nationality');

select * from nationality;

-- связь языка и народности
create table if not exists lang_nationality (
    nationality_id serial references nationality(nationality_id),
    lang_id serial references lang(lang_id));
insert into lang_nationality (nationality_id, lang_id) values
    (1, 1),
    (1, 2),
    (2, 2),
    (3, 3),
    (4, 4),
    (4, 2),
    (4, 4),
    (5, 2),
    (5, 5);
select * from lang_nationality;

-- таблица страны (в смысле Россия, Германия и тп)
create table if not exists countries (
    countries_id serial PRIMARY key,
    countries_name varchar(16) unique not null);
   
insert into countries (countries_name) values
    ('RUS'),
    ('GBR'),
    ('FRA'),
    ('BLR'),
    ('CHN'),
    ('USA');

select * from countries;

-- связь народности и страны
create table if not exists nationality_counrties (
    nationality_id serial,
    countries_id serial,
    foreign key (nationality_id) references nationality(nationality_id),
    foreign key (countries_id) references countries(countries_id)
    );

insert into nationality_counrties (nationality_id, countries_id) values
    (1, 1), 
    (2, 2), (2, 6),
    (3, 3),
    (4, 1), (4, 4),
    (5, 5), (5, 6);
select * from nationality_counrties;

-- присвоить внешние ключи для столбцов существующей таблицы
alter table nationality_counrties add constraint  nationality_counrties foreign key (countries_id) references countries(countries_id);








