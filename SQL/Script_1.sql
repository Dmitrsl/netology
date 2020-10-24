select c.table_name, cu.column_name
from information_schema.table_constraints c
join information_schema.constraint_column_usage cu
where c.constraint_type = 'PRIMARY KEY';

select c.table_name, c.constraint_name, cu.column_name, co.data_type 
from information_schema.table_constraints c
join information_schema.constraint_column_usage cu on cu.table_name = c.table_name and cu.constraint_name = c.constraint_name 
join information_schema."columns" co on co.table_name = c.table_name and co.column_name = cu.column_name
where c.constraint_type = 'PRIMARY KEY' 