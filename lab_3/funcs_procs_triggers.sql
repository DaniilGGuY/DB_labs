--- 1. Функция, которая по имени, фамилии и отчеству генерирует ФИО
drop function if exists mservice.concat_fio(a text, b text, c text)

create or replace function mservice.concat_fio(a text, b text, c text) returns text as $$
begin
  return concat(a, ' ', b, ' ', c);
end;
$$ language plpgsql

select login, mservice.concat_fio(mservice.account."name", mservice.account.surname, mservice.account.patronic) as FIO
from mservice.account


--- 2. Функция получения таблицы исполнителей, количество прослушиваний на треке которого больше среднего количества прослушиваний треков
drop function if exists mservice.gether_than_middle()

create or replace function mservice.gether_than_middle() returns table(login text, avg_listening numeric) as $$
begin
  	return query 
    select m.login, avg(count_listening) as avg_listening
    from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
    group by m.login
	having avg(count_listening) > (select avg(count_listening) as AVG_L from mservice.track);
end;
$$ language plpgsql

select * from mservice.gether_than_middle()


--- 3. Функция возвращает id и количество прослушиваний на треках, количество прослушиваний на которых больше среднего количества 
--- прослушиваний по всем трекам
drop function if exists mservice.added_tracks()

create or replace function mservice.added_tracks() returns table(id int, count_listening int) as $$
declare mean_val numeric;
begin
	select avg(t.count_listening)
	into mean_val
	from mservice.track t;

	return query
	select t.id, t.count_listening
	from mservice.track t
	where t.count_listening > mean_val;
end;
$$ language plpgsql

select * from mservice.added_tracks()


--- 4. Рекурсивная функция, подсчитывающая факториал 
drop function if exists mservice.recursive_func(n int)

create or replace function mservice.recursive_func(n int) returns table(i_ int, factorial_ int) as $$
begin
	return query
	with recursive otv as (
		select 0 as i, 1 as factorial
		union
		select i + 1 as i, factorial * (i + 1) as factorial
		from otv
		where i < n
	)
	select otv.i as i_, otv.factorial as factorial_ from otv;
end;
$$ language plpgsql

select * from mservice.recursive_func(5)


--- 5. Хранимая процедура увеличивает количество подписчиков у музыкантов на 1
drop procedure if exists mservice.add_subscribers()

create or replace procedure mservice.add_subscribers() as $$
begin
 	update mservice.musician
	set followers = followers + 1;
end;
$$ language plpgsql

call mservice.add_subscribers()


--- 6. Рекурсивная хранимая процедура, которая рекурсивно увеличивает количество прослушиваний каждого трека
drop procedure if exists mservice.fix_listenings(start_id int, finish_id int)

create or replace procedure mservice.fix_listenings(start_id int, finish_id int) as $$
begin 
	if start_id < finish_id then
		update mservice.track
		set count_listening = count_listening + 1 
		where id between start_id and finish_id;
		call mservice.fix_listenings(start_id + 1, finish_id);
	end if;
end;
$$ language plpgsql

call mservice.fix_listenings(1, 10)


--- 7. Хранимая процедура с курсором, которая выполняет группировку аккаунтов продюссера по типу в соответствии с количеством подписчиков
drop procedure if exists mservice.acc_type()

alter table mservice.producer 
	add column account_type text;

alter table mservice.producer 
	drop column account_type;

create or replace procedure mservice.acc_type() as $$
declare subs_col int;
declare type_acc text;
declare login_prod text;
declare cur_id cursor for select login, followers, account_type from mservice.producer where followers > 500;
begin
	open cur_id;
	loop
		fetch cur_id into login_prod, subs_col, type_acc;
		exit when not found;
		case 
			when subs_col > 980 then type_acc = 'VIP';
			when subs_col > 900 then type_acc = 'premium';
			else type_acc = 'default';
		end case;
		update mservice.producer
		set account_type = type_acc
		where login = login_prod;
	end loop;
	close cur_id;
end;
$$ language plpgsql

call mservice.acc_type()


--- 8. Хранимая процедура доступа к метаданным, которая формирует таблицу "имя столбца"-"тип столбца" по имени таблицы
drop procedure if exists mservice.meta_data(tablename text)

create table if not exists mservice.table_info (
	column_name text,
	data_type text
);

drop table if exists mservice.table_info;

create or replace procedure mservice.meta_data(tablename text) as $$
begin
	insert into mservice.table_info
	select column_name, data_type from information_schema.columns where table_name = tablename;
end;
$$ language plpgsql

call mservice.meta_data('track')


--- 9. Триггер AFTER, который устанавливает поле 'followers' всем новым музыкантам, у которых это поле NULL, в 0 
drop trigger if exists mus_update on mservice.musician 

drop function if exists mservice.insert_mus()

create or replace function mservice.insert_mus() returns trigger as $$
begin
	if new.followers is null then
		update mservice.musician set followers = 0 where login = new.login;
	end if;
	return new;
end;
$$ language plpgsql

create or replace trigger mus_update
after insert on mservice.musician
for each row 
execute function mservice.insert_mus();

insert into mservice.musician (login, name, surname, patronic, followers, about)
values ('asdfghjkl', 'Андрей', 'Андреев', 'Андреевич', null, null)

delete from mservice.musician where login = 'asdfghjkl'


--- 10. Триггер INSTEAD OF. Который вместо обновления перевыпущенного трека делает добавление нового значения
drop trigger if exists reedition on mservice.track

drop function if exists mservice.reedite_year()

create or replace function mservice.reedite_year() returns trigger as $$
declare max_id int;
begin
	max_id = max(id) from mservice.track;
	if old.year_of_issue <> new.year_of_issue then
		insert into mservice.track (id, count_listening, duration, lyrics, year_of_issue)
		values (max_id + 1, old.count_listening, old.duration, old.lyrics, new.year_of_issue);
	end if;
	return new;
end;
$$ language plpgsql

drop view if exists mservice.track_view;

create view mservice.track_view
as select * from mservice.track

create or replace trigger reedition
instead of update on mservice.track_view 
for each row 
execute function mservice.reedite_year();

update mservice.track_view 
set year_of_issue = 2018 where id = 2