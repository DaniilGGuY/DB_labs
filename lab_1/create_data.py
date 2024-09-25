from PIL.ImageColor import colormap
from colorama import colorama_text
from faker import Faker
import random as r
import csv

def printf_cvs(data, file):
    with open(str(dir + file), "w", newline="", encoding='utf-8') as file:
        writer = csv.writer(file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for i in range(len(data)):
             writer.writerow(data[i])


faker_ru = Faker(locale='ru')

dir = 'data/'

count_els = 1000

table_user = [['login', 'password', 'name', 'surname', 'patronic', 'birthdate', 'subscribe', 'phone', 'mail']]
table_musician = [['login', 'name', 'surname', 'patronic', 'followers', 'about']]
table_producer = [['login', 'name', 'surname', 'patronic', 'followers', 'about']]
table_track = [['id', 'count_listening', 'duration', 'lyrics', 'year_of_issue']]
table_musician_producer = [['id_mus', 'id_prod']]
table_musician_track = [['id_mus', 'id_track']]
table_user_musician = [['id_user', 'id_mus']]
table_user_track = [['id_user', 'id_track']]
table_producer_track = [['id_prod', 'id_track']]

unique = set()
while len(unique) < count_els:
    user = faker_ru.simple_profile()
    prev_len = len(unique)
    unique.add(user['username'])
    if len(unique) > prev_len:
        string = list()
        string.append(user['username'])
        string.append(faker_ru.password())
        string += user['name'].split() if len(user['name'].split()) == 3 else user['name'].split()[1:]
        string.append(user['birthdate'])
        string.append(r.randint(0, 1))
        string.append(faker_ru.phone_number())
        string.append(user['mail'])
        table_user.append(string)

for i in range(count_els * 5):
    string = list()
    string.append(i)
    string.append(r.randint(10, 10**9))
    string.append(r.randint(0, 8) * 60 + r.randint(0, 59))
    string.append(faker_ru.text().replace('\n', ' '))
    string.append(r.randint(2004, 2024))
    table_track.append(string)

unique = set()
while len(unique) < count_els:
    user = faker_ru.simple_profile()
    prev_len = len(unique)
    unique.add(user['username'])
    if len(unique) > prev_len:
        string = list()
        string.append(user['username'])
        string += user['name'].split() if len(user['name'].split()) == 3 else user['name'].split()[1:]
        string.append(r.randint(1, 10**9))
        string.append(faker_ru.text().replace('\n', ' '))
        table_musician.append(string)

unique = set()
while len(unique) < count_els:
    user = faker_ru.simple_profile()
    prev_len = len(unique)
    unique.add(user['username'])
    if len(unique) > prev_len:
        string = list()
        string.append(user['username'])
        string += user['name'].split() if len(user['name'].split()) == 3 else user['name'].split()[1:]
        string.append(r.randint(1, 10**9))
        string.append(faker_ru.text().replace('\n', ' '))
        table_producer.append(string)

arr_track = [i[0] for i in table_track[1:]]
arr_musician = [i[0] for i in table_musician[1:]]
arr_producer = [i[0] for i in table_producer[1:]]
arr_user = [i[0] for i in table_user[1:]]

r.shuffle(arr_track)
r.shuffle(arr_musician)
r.shuffle(arr_producer)
r.shuffle(arr_user)

for i in range(count_els):
    a = r.randint(0, 9)
    b = r.randint(0, 9)
    for j in range(min(a, b) * 100, max(a, b) * 100):
        string = list()
        string.append(arr_musician[i])
        string.append(arr_producer[j])
        table_musician_producer.append(string)

for i in range(count_els):
    a = r.randint(0, 9)
    b = r.randint(0, 9)
    for j in range(min(a, b) * 100, max(a, b) * 100):
        string = list()
        string.append(arr_user[i])
        string.append(arr_musician[j])
        table_user_musician.append(string)

for i in range(count_els):
    a = r.randint(0, 50)
    b = r.randint(0, 50)
    for j in range(min(a, b) * 100, max(a, b) * 100):
        string = list()
        string.append(arr_user[i])
        string.append(arr_track[j])
        table_user_track.append(string)

for i in range(count_els):
    for j in range(i * 5, (i + 1) * 5):
        string = list()
        string.append(arr_musician[i])
        string.append(arr_track[j])
        table_musician_track.append(string)

r.shuffle(arr_track)
for i in range(count_els):
    for j in range(i * 5, (i + 1) * 5):
        string = list()
        string.append(arr_producer[i])
        string.append(arr_track[j])
        table_producer_track.append(string)

printf_cvs(table_user, 'user.csv')
printf_cvs(table_track, 'track.csv')
printf_cvs(table_musician, 'musician.csv')
printf_cvs(table_producer, 'producer.csv')
printf_cvs(table_musician_producer, 'mus-prod.csv')
printf_cvs(table_musician_track, 'mus-track.csv')
printf_cvs(table_user_track, 'user-track.csv')
printf_cvs(table_user_musician, 'user-mus.csv')
printf_cvs(table_producer_track, 'prod-track.csv')