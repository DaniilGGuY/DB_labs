import psycopg2

class MusicianService:
    def __init__(self):
        print("Подключение к базе данных...")
        self.__conn = psycopg2.connect(dbname="postgres",
                                      user="postgres",
                                      password="postgres123",
                                      host="localhost")
        print("Подключение выполнено успешно.")
        self.__cursor = self.__conn.cursor()
        print("Готов к работе.")

    def __del__(self):
        print("Отключение от базы данных...")
        self.__cursor.close()
        self.__conn.close()
        print("Отключено.\nВыход...")

    def print_result(self):
        for i in self.__cursor:
            print(i)

    def scalar_request(self):
        # Найти всех исполнителей у которых более 100 подписчиков
        sql_request = """
            select login, followers
            from mservice.musician
            where followers > 100
            order by followers desc"""
        self.__cursor.execute(sql_request)

    def some_joins_request(self):
        # Посчитать суммарное количество прослушиваний исполнителя по всем трекам
        sql_request = """
            select login, sum(count_listening)
            from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) 
                join mservice.track t on t.id = mt.id_track
            group by login"""
        self.__cursor.execute(sql_request)

    def otv_over_request(self):
        # С помощью агрегатных функций вывести среднее и сумму по прослушиваниям треков исполнителя
        sql_request = """
            with otv as (
	            select distinct id_track, id_mus, count_listening, year_of_issue,
	                avg(count_listening) over(partition by login order by year_of_issue) as avg_listening,
	                sum(count_listening) over(partition by login order by year_of_issue) as total_listening
                from (select distinct *
	                  from (mservice.musician m join mservice.mus_track mt on m.login = mt.id_mus) 
	                    join mservice.track t on t.id = mt.id_track)
                order by id_mus, year_of_issue
            )
            select * from otv"""
        self.__cursor.execute(sql_request)

    def meta_request(self, table_name):
        # Доступ к информационной схеме, которая формирует таблицу "имя столбца"-"тип столбца"
        # по имени таблицы
        sql_request = """
            select column_name, data_type 
            from information_schema.columns 
            where table_name = \'%s\';""" % table_name
        self.__cursor.execute(sql_request)

    def scalar_func_request(self):
        # Функция, которая по имени, фамилии и отчеству формирует ФИО
        sql_request = """
            create or replace function mservice.concat_fio(a text, b text, c text) returns text as $$
            begin
              return concat(a, ' ', b, ' ', c);
            end;
            $$ language plpgsql;
            select login, mservice.concat_fio(mservice.account."name", 
                                              mservice.account.surname, 
                                              mservice.account.patronic) as FIO
            from mservice.account;"""
        self.__cursor.execute(sql_request)

    def manyops_table_func_request(self):
        # Функция возвращает id и количество прослушиваний на треках, количество прослушиваний
        # на которых больше среднего количества прослушиваний по всем трекам
        sql_request = """
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
            $$ language plpgsql;
            select * from mservice.added_tracks();"""
        self.__cursor.execute(sql_request)

    def store_procedure_request(self):
        # Хранимая процедура увеличивает количество подписчиков у музыкантов на 1
        sql_request = """
            create or replace procedure mservice.add_subscribers() as $$
            begin
                update mservice.musician
                set followers = followers + 1;
            end;
            $$ language plpgsql;
            call mservice.add_subscribers();
            select * from mservice.musician;"""
        self.__cursor.execute(sql_request)

    def system_func_request(self):
        # Вызов системной функции, выводящей версию postgres
        sql_request = """select * from version()"""
        self.__cursor.execute(sql_request)

    def create_func_request(self):
        # Создание таблицы доходов музыканта
        sql_request = """
            create table if not exists mservice.mus_earnings (
                id int,
                login text,
                track_id integer,
                salary integer
            );
            alter table mservice.mus_earnings
                add constraint mus_earn_pk primary key(id),
                add constraint mus_earn_mfk foreign key(login) references mservice.musician(login),
                add constraint mus_earn_tfk foreign key(track_id) references mservice.track(id);"""
        self.__cursor.execute(sql_request)
        self.__conn.commit()

    def insert_func_request(self):
        # Вставка элементов
        sql_request = """
            insert into mservice.mus_earnings (id, login, track_id, salary)
            values 
            (1, 'konondrozdov', 2045, 1000),
            (2, 'konondrozdov', 30, 10000),
            (3, 'kostinjuri', 1364, 20000),
            (4, 'gterenteva', 295, 1000000);"""
        self.__cursor.execute(sql_request)
        self.__conn.commit()