--- 1. Инструкция SELECT, использующая предикат сравнения. 
--- Найти всех исполнителей у которых более 100 подписчиков
select login, followers 
from mservice.musician 
where followers > 100
order by followers desc

--- 2. Инструкция SELECT, использующая предикат BETWEEN.
--- Найти все треки, выпущенные в период с 2010 до 2020
select *
from mservice.track
where year_of_issue between 2010 and 2020
order by year_of_issue asc

--- 3. Инструкция SELECT, использующая предикат LIKE.
--- Найти всех продюсеров, в поле about которых встречается слово "число"
select login, about
from mservice.producer
where about like '%число%'

--- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
--- Найти длительность всех треков, которые слушают совершеннолетние пользователи
select id, duration
from mservice.track t
where duration in (
	select duration
	from (mservice.account a join mservice.user_track ut on a.login = ut.id_user)
	join mservice.track t2 on t2.id = ut.id_track
	where a.birthdate > '2006-01-01'
	)
	
--- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом. 
--- Найти всех пользователей не подписанных ни на одного музыканта
select login, name, surname, patronic 
from mservice.account a
where not exists(select * 
	from mservice.user_mus
	where id_user = a.login)
	
--- 6. Инструкция SELECT, использующая предикат сравнения с квантором. 
--- Найти все треки длительностью более 60 секунд, количество прослушиваний которых больше, чем у всех треков длительностью менее 60 сек
select id, count_listening, duration
from mservice.track
where count_listening > all(select count_listening 
	from mservice.track where duration < 60) 
	and duration > 60
	
--- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов. 
--- Поссчитать суммарное количество прослушиваний исполнителя по всем трекам
select login, sum(count_listening)
from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
group by login

	
--- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
--- Вывести таблицу с атрибутами: логин исполнителя, максимальная длительность трека, минимальная длительность трека
select login, (select max(duration)
	from (mservice.musician m2 join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
	where m.login = m2.login) as max_dur,
	(select min(duration)
	from (mservice.musician m2 join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
	where m.login = m2.login) as min_dur
from mservice.musician m

--- 9. Инструкция SELECT, использующая простое выражение CASE.
--- Назначить всем пользователям с именем 'Алина' специальное предложение
select login, name, surname, patronic,
	case name
		when ('Алина') then true
		else false
	end as present
from mservice.account 

--- 10. Инструкция SELECT, использующая поисковое выражение CASE.
--- Разбить аккаунту продюссеров по количеству подписчиков
select login, followers,
	case 
		when followers > 900 then 'VIP'
		when followers > 600 then 'premium'
		else 'default'
	end as acc_level
from mservice.producer

--- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
--- Создание таблицы музыкант-трек, в которой треки моложе 2020 года
select login, id, year_of_issue into mservice.new_table
from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
where t.year_of_issue > 2020

--- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM. 
--- Вывести пару пользователь-музыкант, чьи имена совпадают
select distinct a.login, a.name, a.surname, mus.login, mus.name, mus.surname
from mservice.account a join mservice.user_mus um on a.login = um.id_user join (
	select login, name, surname, patronic
	from mservice.musician m 	
) as mus on mus.name = a.name 

--- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
--- Найти пользователей, которые слушают треки 2012 года у исполнителей с 26 подписчиками
select login, name, surname, patronic
from mservice.account
where login in (
	select id_user
	from mservice.user_track ut join mservice.track t on ut.id_track = t.id
	where year_of_issue = 2012 
	and t.id in (
		select id_track
		from mservice.mus_track mt join mservice.musician m on m.login = mt.id_mus
		where m.followers = 26
		)
	)

--- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
--- Вывести среднее по количеству прослушиваний у исполнителя и сумма прослушиваний
select login, avg(count_listening) as avg_listening, sum(count_listening) as sum_listening
from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
group by login
	

--- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
--- Получить таблицу исполнителей, количество прослушиваний на треке которого больше среднего количества прослушиваний треков
select login, avg(count_listening) as avg_listening
from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
group by login
having avg(count_listening) > (select avg(count_listening) as AVG_L from mservice.track)

--- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений. 
--- Однострочная вставка
insert into mservice.musician (login, name, surname, patronic, followers, about)
values ('ayalorther', 'Дмитрий', 'Фер', 'Арменович', 0, null)

--- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
--- Многострочная вставка 
insert into mservice.mus_prod (id_mus, id_prod)
select 'ayalorther', login
from mservice.producer m
where m.followers < 300

--- 18. Простая инструкция UPDATE.
--- Уменьшить количество подписчиков на 99.999990% всем продюссерам
update mservice.musician 
set followers = cast(followers * 0.1 as integer)

--- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET. 
--- Увеличить количество подписчиков всем музыкантам, у которых 0 подписчиков
update mservice.musician 
set followers = (select cast(avg(followers) as integer)
				 from mservice.musician 
				 where followers < 12)
where followers = 0

--- 20. Простая инструкция DELETE.
--- Удалить того, кого добавил
delete from mservice.musician
where login = 'ayalorther'

--- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE. 
--- Удалить то, что добавил
delete from mservice.mus_prod 
where id_mus in (select id_mus
				 from mservice.mus_prod
				 where id_mus = 'aylorther')
				 
--- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение.
--- ОТВ получения таблицы исполнителей, количество прослушиваний на треке которого больше среднего количества прослушиваний треков
with otv as (
	select login, avg(count_listening) as avg_listening
	from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
	group by login
	having avg(count_listening) > (select avg(count_listening) as AVG_L from mservice.track)
)
select * from otv

--- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
--- Рекурсивная функция, вычисляющая факториал
with recursive otv as (
	select 1 as i, 1 as factorial
	union
	select i + 1 as i, factorial * (i + 1) as factorial
	from otv
	where i < 10
)
select * from otv

--- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER().
--- С помощью агрегатных функций вывести среднее и сумму по прослушиваниям треков исполнителя
select distinct id_track, id_mus, count_listening, year_of_issue,
	avg(count_listening) over(partition by login order by year_of_issue) as avg_listening,
	sum(count_listening) over(partition by login order by year_of_issue) as total_listening
from (select distinct *
	  from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track)
order by id_mus, year_of_issue

--- 25. Оконные фнкции для устранения дублей.
---Придумать запрос, в результате которого в данных появляются полные дубли. Устранить дублирующиеся строки с использованием функции ROW_NUMBER().
insert into mservice.track (id, count_listening, duration, lyrics, year_of_issue)
select id + 5000, count_listening, duration, lyrics, year_of_issue
from mservice.track 

delete from mservice.track 
where id not in (
	select id
	from (
		select row_number() over (partition by lyrics order by id) 
		as cnt, id, count_listening, duration, lyrics, year_of_issue
		from mservice.track t 
	) where cnt = 1
	order by id
)

--- Защита ЛР
--- Вывести всех продюссеров, которые связаны с музыкантами, написавшими самые долгие треки
select login, name, surname, patronic
from mservice.producer p 
where p.login in (
	select p.login
	from (mservice.musician m join mservice.mus_prod mp on m.login = mp.id_mus) join mservice.producer p on p.login = mp.id_prod
	where m.login in (
		select m.login
		from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) join mservice.track t on t.id = mt.id_track
		where t.duration = (select max(duration) from mservice.track)
	)
)


