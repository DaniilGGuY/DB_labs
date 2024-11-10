create extension plpython3u;



--- 1. Определяемая пользователем скалярная функция CLR, которая выполняет конкатенацию фамилии, имени и отчества пользователя
drop function if exists mservice.concat_fio(a text, b text, c text);

create or replace function mservice.concat_fio(a text, b text, c text) returns text as $$
return a + ' ' + b + ' ' + c
$$ language plpython3u;

select login, mservice.concat_fio(mservice.account."name", mservice.account.surname, mservice.account.patronic) as FIO
from mservice.account;



--- 2. Пользовательская агрегатная функция CLR, которая ищет медианное значение
drop function if exists mservice._insert(vals numeric(20, 2)[], new_val numeric(20, 2));

drop function if exists mservice._median(vals numeric(20, 2)[]);

create or replace function mservice._insert(vals numeric(20, 2)[], new_val numeric(20, 2)) returns numeric(20, 2)[] as $$
vals.append(new_val)
return vals
$$ language plpython3u;

create or replace function mservice._median(vals numeric(20, 2)[]) returns numeric(20, 2) as $$
n = len(vals)
if n == 0:
	return 0
if n % 2 == 0:
	return (vals[n // 2] + vals[n // 2 - 1]) / 2
return vals[n // 2]
$$ language plpython3u;

create or replace aggregate mservice.med (
	sfunc = mservice._insert,
	basetype = numeric(20, 2),
	stype = numeric(20, 2)[],
	initcond = '{}',
  	finalfunc = mservice._median
);

select login, mservice.med(count_listening), avg(count_listening)
from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
group by login
order by login;



--- 3. Определяемая пользователем табличная функция CLR, которая получает таблицу исполнителей, количество подписчиков которых больше среднего 
--- количества подписчиков
drop function if exists mservice.gether_than_middle();

create or replace function mservice.gether_than_middle() returns table(login text, followers numeric) as $$
rq = "select login, followers from mservice.musician"
musician = plpy.execute(rq)
avg_total = 0
total_musicians = len(musician)
for i in musician:
	avg_total += i['followers']
avg_total /= total_musicians
res = list()
for i in musician:
	if i['followers'] > avg_total:
		res.append((i['login'], i['followers']))
return res
$$ language plpython3u;

select * from mservice.gether_than_middle();



--- 4. Хранимая процедура CLR, которая увеличивает количество подписчиков у случайно выбранных музыкантов на 1
drop procedure if exists mservice.add_subscribers();

create or replace procedure mservice.add_subscribers() as $$
import random
rq = "select login from mservice.musician"
arr = plpy.execute(rq)
random.shuffle(arr)
for i in range(len(arr) // 2):
	rq = "update mservice.musician set followers = followers + 1 where login = '" + arr[i]['login'] + "'"
	plpy.execute(rq)
$$ language plpython3u;

call mservice.add_subscribers();



--- 5. Триггер CLR AFTER, который устанавливает поле 'followers' всем новым музыкантам, у которых это поле NULL, в 0 
drop trigger if exists mus_update on mservice.musician;

drop function if exists mservice.insert_mus();

create or replace function mservice.insert_mus() returns trigger as $$
if TD["new"]["followers"] is None:
	TD["new"]["followers"] = 0
return "MODIFY"
$$ language plpython3u;

create or replace trigger mus_update
before insert on mservice.musician
for each row 
execute function mservice.insert_mus();

insert into mservice.musician (login, name, surname, patronic, followers, about)
values ('asdfghjkl', 'Андрей', 'Андреев', 'Андреевич', null, null)

delete from mservice.musician where login = 'asdfghjkl'



--- 6. Определяемый пользователем тип CLR - карточка музыканта
drop function if exists mservice.get_musician_tracks(login text);

drop type if exists mservice.mus_card;

create type mservice.mus_card as (
	login text,
	id integer,
	count_listening integer,
	duration integer,
	lyrics text,
	year_of_issue integer
);

create or replace function mservice.get_musician_tracks(login text) returns mservice.mus_card[] as $$
class mtracks:
	def __init__(self, login, id, cl, dur, lyr, yoi):
		self.login = login
		self.id = id
		self.count_listening = cl
		self.duration = dur
		self.lyrics = lyr
		self.year_of_issue = yoi

rq = '''
select id, count_listening, duration, lyrics, year_of_issue
from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
where login = $1;
'''
res = plpy.prepare(rq, ["text"]).execute([login])
card = list()
for i in range(len(res)):
	mus = res[i]
	card.append(mtracks(login, mus['id'], mus['count_listening'], mus['duration'], mus['lyrics'], mus['year_of_issue']))
return card
$$ language plpython3u;

select * from mservice.get_musician_tracks('anatoli97');
