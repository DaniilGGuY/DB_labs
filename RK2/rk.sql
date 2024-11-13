create schema if not exists rk;

--- Создание таблиц и наложение ограничений
create table if not exists rk.teacher (
	id integer,
	name text,
	surname text,
	patronic text,
	degrees text,
	job text,
	cafedra_id integer
);

alter table if exists rk.teacher
	add constraint uid_teacher primary key (id);

create table if not exists rk.cafedra (
	id integer,
	title text,
	description text
);

alter table if exists rk.cafedra
	add constraint uid_cafedra primary key (id);

create table if not exists rk.subject (
	id integer,
	title text,
	count_hours integer,
	semestr integer,
	rating numeric(20, 2)
);

alter table if exists rk.subject
	add constraint uid_subject primary key (id);
	
create table if not exists rk.teachsubj (
	id_teacher integer,
	id_subject integer
);

alter table if exists rk.teachsubj
	add constraint t_id_constraint foreign key (id_teacher) references rk.teacher(id),
	add constraint s_id_constraint foreign key (id_subject) references rk.subject(id);
	
--- Заполнение таблиц значениями
insert into rk.teacher (id, name, surname, patronic, degrees, job, cafedra_id)
values 
(1, 'Иван', 'Иванов', 'Иванович', 'доцент', 'Информатика', 1),
(2, 'Петр', 'Петров', 'Петрович', 'доцент', 'Теория информации', 2),
(3, 'Андрей', 'Смирнов', 'Сергеевич', 'завкаф', 'Математический анализ', 3),
(4, 'Андрей', 'Куров', 'Владимирович', 'зам завкаф', 'Компьютерная графика', 1),
(5, 'Сергей', 'Алексеев', 'Дмитриевич', 'доцент', 'Английский', 4),
(6, 'Сергей', 'Иванов', 'Филиппович', 'доцент', 'Правоведение', 5),
(7, 'Филипп', 'Филиипов', 'Андреевич', 'доцент', 'История', 6),
(8, 'Глеб', 'Кузьмин', 'Сергеевич', 'доцент', 'Компьютерная графика', 7),
(9, 'Иван', 'Андреев', 'Глебович', 'доцент', 'Информатика', 8),
(10, 'Константин', 'Верченко', 'Евгеньевич', 'аспирант', 'Информатика', 8);

insert into rk.cafedra (id, title, description)
values 
(1, 'ИУ7', 'Программная инженерия'),
(2, 'ИУ6', 'Защита информации'),
(3, 'ФН12', 'Математика и статистика'),
(4, 'Л2', 'Иностранные языки'),
(5, 'ЮР', 'Юридический'),
(6, 'СГН3', 'История России'),
(7, 'ИУ9', 'Прикладная математика и информатика'),
(8, 'ИУ1', 'Программирование ракетных модулей'),
(9, 'ФН4', 'Физика'),
(10, 'Э8', 'Безопасность жизнедеятельности');

insert into rk.subject (id, title, count_hours, semestr, rating)
values
(1, 'Информатика', 40, 1, 4.5),
(2, 'Теория информации', 20, 5, 5),
(3, 'Математический анализ', 50, 1, 3.5),
(4, 'Компьютерная графика', 40, 4, 1),
(5, 'Английский', 80, 1, 4.7),
(6, 'Правоведение', 20, 3, 4.3),
(7, 'История', 20, 2, 4),
(8, 'Физика', 45, 2, 3.7),
(9, 'Химия', 20, 1, 2.3),
(10, 'ОБЖ', 22, 6, 4.9);

insert into rk.teachsubj (id_teacher, id_subject)
values
(1, 1),
(1, 2),
(1, 4),
(2, 2),
(2, 1),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(6, 10),
(6, 9),
(7, 7),
(7, 4),
(8, 4),
(9, 8),
(9, 1),
(10, 1);

--- SELECT предикат сравнения + квантор. Вывести id и названия всех предметов, количество часов которых больше количества часов всех тех предметов,
--- рейтинг которых меньше 3
select id, title
from rk.subject 
where count_hours > all(select count_hours 
	from rk.subject where rating < 3) ;
	
--- SELECT с агрегатными функциями. Вывести суммарное количество часов по всем предметам, максимальное и минимальное
select sum(count_hours), max(count_hours), min(count_hours)
from rk.subject;

--- Новая локальная таблица. Вывести ФИО преподавателей доцентов
with otv as (
	select name, surname, patronic
	from rk.teacher 
	where degrees = 'доцент'
)
select * from otv;

--- Хранимая процедура с входным параметром таблицей, удаляющая дубликаты из таблицы
insert into rk.cafedra (id, title, description)
values 
(11, 'ИУ7', 'Программная инженерия'),
(12, 'ИУ6', 'Защита информации'),
(13, 'ФН12', 'Математика и статистика'),
(14, 'Л2', 'Иностранные языки'),
(15, 'ЮР', 'Юридический'),
(16, 'СГН3', 'История России'),
(17, 'ИУ9', 'Прикладная математика и информатика'),
(18, 'ИУ1', 'Программирование ракетных модулей'),
(19, 'ФН4', 'Физика'),
(20, 'Э8', 'Безопасность жизнедеятельности');

create or replace procedure rk.remove_duplicates(tablename text) as $$
begin 
	delete from rk.cafedra
	where id not in (
		select id
		from (
			select row_number() over (partition by title, description order by id asc) 
			as cnt, id, title, description
			from rk.cafedra
		) where cnt > 1
		order by id
	);
end;
$$ language plpgsql;

call rk.remove_duplicates('cafedra');