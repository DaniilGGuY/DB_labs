create schema if not exists jsonwork;



--- Загрузка таблицы в JSON-файл (Задание 1)
copy (
	select array_to_json(array_agg(row_to_json(a))) from mservice.account a 
) to 'D:\Study\DB_labs\lab_5\data\account.json';



--- Загрузка данных из JSON-файла в новую таблицу (Задание 2)
create table if not exists jsonwork.account (
	login text,
	password text,
	name text,
	surname text,
	patronic text,
	birthdate date,
	subscribe bool,
	phone text,
	mail text
);

alter table jsonwork.account
	add constraint unique_log_user primary key (login),
	alter column password set not null,
	alter column name set not null,
	alter column surname set not null,
    add constraint correct_email check (mail ~ '^[\w\-\.]+@([\w\-]+\.)+[\w\-]+$');

create temp table t ( t json );
copy t from 'D:\Study\DB_labs\lab_5\data\account.json';

insert into jsonwork.account
select (json_populate_record(null::jsonwork.account, json_array_elements(t))).* from t;

select * from jsonwork.account
order by login;

drop table if exists t;

drop table if exists jsonwork.account;



--- Создание таблицы, в которой есть атрибуты с типом JSON (Задание 3)
alter table jsonwork.account add column passport json;

update jsonwork.account set passport = '{"seria":"4658", "number":"855672"}' where login = 'adam_2008';
update jsonwork.account set passport = '{"seria":"4669", "number":"187293"}' where login = 'adam_54';
update jsonwork.account set passport = '{"seria":"5674", "number":"234513"}' where login = 'adam_92';
update jsonwork.account set passport = '{"seria":"3451", "number":"819328"}' where login = 'adam1991';
update jsonwork.account set passport = '{"seria":"8910", "number":"768491"}' where login = 'adamgolubev';
update jsonwork.account set passport = '{"seria":"9811", "number":"999999"}' where login = 'adrian_22';
update jsonwork.account set passport = '{"seria":null, "number":null}' where login = 'adrian_64';


--- Извлечь XML/JSON фрагмент из XML/JSON документа (Задание 4.1)
select login, birthdate, passport as passport 
from jsonwork.account
where passport is not null;

--- Извлечь значения конкретных узлов или атрибутов XML/JSON документа (Задание 4.2)
select login, birthdate, (passport->>'seria')::integer as seria, (passport->>'number')::integer as number
from jsonwork.account
where passport is not null;

--- Выполнить проверку существования узла или атрибута (Задание 4.3)
select login, birthdate, (passport->>'seria')::integer as seria, (passport->>'number')::integer as number
from jsonwork.account
where passport is not null and passport->>'seria' is not null and passport->>'number' is not null;

--- Изменить XML/JSON документ (Задание 4.4)
update jsonwork.account set passport = '{"seria":null, "number":null}' 
where passport is null;

--- Разделить XML/JSON документ на несколько строк по узлам (Задание 4.5)
drop table if exists jsonwork.acc_json;

create table if not exists jsonwork.acc_json
(
    data json
);

copy jsonwork.acc_json(data) from 'D:\Study\DB_labs\lab_5\data\account.json';

select json_array_elements(data) from jsonwork.acc_json;