from musservice import MusicianService

def menu():
    print("Меню:")
    print("1 - Выполнить скалярный запрос")
    print("2 - Выполнить запрос с несколькими соединениями (JOIN)")
    print("3 - Выполнить запрос с ОТВ(CTE) и оконными функциями")
    print("4 - Выполнить запрос к метаданным")
    print("5 - Вызвать скалярную функцию (написанную в третьей лабораторной работе)")
    print("6 - Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе)")
    print("7 - Вызвать хранимую процедуру (написанную в третьей лабораторной работе)")
    print("8 - Вызвать системную функцию или процедуру")
    print("9 - Создать таблицу в базе данных, соответствующую тематике БД")
    print("10 - Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.")
    print("0 - Завершение работы")
    print("Введите номер действия, которое необходимо выполнить: ", end="")


db = MusicianService()
action = -1
while action != 0:
    menu()
    action = int(input())
    if action == 1:
        db.scalar_request()
    elif action == 2:
        db.some_joins_request()
    elif action == 3:
        db.otv_over_request()
    elif action == 4:
        db.meta_request('track')
    elif action == 5:
        db.scalar_func_request()
    elif action == 6:
        db.manyops_table_func_request()
    elif action == 7:
        db.store_procedure_request()
    elif action == 8:
        db.system_func_request()
    elif action == 9:
        db.create_func_request()
        continue
    elif action == 10:
        db.insert_func_request()
        continue
    else:
        continue
    db.print_result()