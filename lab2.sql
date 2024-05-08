-1
-- Сделать запрос для получения атрибутов из указанных таблиц, применив фильтры по указанным условиям:
-- Таблицы: Н_ЛЮДИ, Н_СЕССИЯ.
-- Вывести атрибуты: Н_ЛЮДИ.ОТЧЕСТВО, Н_СЕССИЯ.УЧГОД.
-- Фильтры (AND):
-- a) Н_ЛЮДИ.ФАМИЛИЯ < Петров.
-- b) Н_СЕССИЯ.ЧЛВК_ИД > 105948q.
-- Вид соединения: RIGHT JOIN
SELECT "Н_ЛЮДИ"."ОТЧЕСТВО", "Н_СЕССИЯ"."УЧГОД", "Н_ЛЮДИ"."ФАМИЛИЯ", "Н_ЛЮДИ"."ИД"
FROM "Н_ЛЮДИ"
RIGHT JOIN "Н_СЕССИЯ" ON "Н_ЛЮДИ"."ИД" = "Н_СЕССИЯ"."ЧЛВК_ИД"
WHERE "Н_ЛЮДИ"."ФАМИЛИЯ" < 'Петров' AND "Н_СЕССИЯ"."ЧЛВК_ИД" > 105948;
-- 1(2 вариант сравнения по длине)
SELECT "Н_ЛЮДИ"."ОТЧЕСТВО", "Н_СЕССИЯ"."УЧГОД", "Н_ЛЮДИ"."ФАМИЛИЯ", "Н_ЛЮДИ"."ИД"
FROM "Н_ЛЮДИ"
RIGHT JOIN "Н_СЕССИЯ" ON "Н_ЛЮДИ"."ИД" = "Н_СЕССИЯ"."ЧЛВК_ИД"
WHERE LENGTH("Н_ЛЮДИ"."ФАМИЛИЯ") < LENGTH('Петров') AND "Н_СЕССИЯ"."ЧЛВК_ИД" > 105948;

--Сделать запрос для получения атрибутов из указанных таблиц, применив фильтры по указанным условиям:
--Таблицы: Н_ЛЮДИ, Н_ВЕДОМОСТИ, Н_СЕССИЯ.
--Вывести атрибуты: Н_ЛЮДИ.ИД, Н_ВЕДОМОСТИ.ЧЛВК_ИД, Н_СЕССИЯ.ЧЛВК_ИД.
--Фильтры (AND):
--a) Н_ЛЮДИ.ОТЧЕСТВО = Сергеевич.
--b) Н_ВЕДОМОСТИ.ЧЛВК_ИД = 142390.
--c) Н_СЕССИЯ.ЧЛВК_ИД < 105948q.
--Вид соединения: LEFT JOIN.

SELECT "Н_ЛЮДИ"."ИД", "Н_ВЕДОМОСТИ"."ЧЛВК_ИД", "Н_СЕССИЯ"."ЧЛВК_ИД"
FROM "Н_ЛЮДИ"
LEFT JOIN "Н_ВЕДОМОСТИ" ON "Н_ЛЮДИ"."ИД" = "Н_ВЕДОМОСТИ"."ЧЛВК_ИД"
LEFT JOIN "Н_СЕССИЯ" ON "Н_ЛЮДИ"."ИД" = "Н_СЕССИЯ"."ЧЛВК_ИД"
WHERE "Н_ЛЮДИ"."ОТЧЕСТВО" = 'Сергеевич'
AND "Н_ВЕДОМОСТИ"."ЧЛВК_ИД" = 142390 -- это условие все портит
AND "Н_СЕССИЯ"."ЧЛВК_ИД" < 105948;

-- 3
-- Вывести число студентов ФКТИУ, которые без ИНН.
-- Ответ должен содержать только одно число.
SELECT count(*)
FROM "Н_ЛЮДИ" AS people
WHERE EXISTS (
  SELECT *
  FROM "Н_УЧЕНИКИ"
    JOIN "Н_ПЛАНЫ" ON "Н_УЧЕНИКИ"."ПЛАН_ИД" = "Н_ПЛАНЫ"."ИД"
    JOIN "Н_ОТДЕЛЫ" ON "Н_ПЛАНЫ"."ОТД_ИД" = "Н_ОТДЕЛЫ"."ИД"
      and "Н_ОТДЕЛЫ"."КОРОТКОЕ_ИМЯ" = 'КТиУ'
  WHERE "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "people"."ИД"
);

--4
-- В таблице Н_ГРУППЫ_ПЛАНОВ найти номера планов, по которым обучается (обучалось) менее 2 групп на кафедре вычислительной техники.
-- Для реализации использовать подзапрос.

SELECT "Н_ГРУППЫ_ПЛАНОВ"."ПЛАН_ИД"
FROM "Н_ГРУППЫ_ПЛАНОВ"
JOIN (
    SELECT DISTINCT "Н_УЧЕНИКИ"."ГРУППА"
    FROM "Н_УЧЕНИКИ"
    JOIN "Н_ПЛАНЫ" ON "Н_УЧЕНИКИ"."ПЛАН_ИД" = "Н_ПЛАНЫ"."ИД"
    JOIN "Н_ОТДЕЛЫ" ON "Н_ПЛАНЫ"."ОТД_ИД" = "Н_ОТДЕЛЫ"."ИД"
    AND "Н_ОТДЕЛЫ"."КОРОТКОЕ_ИМЯ" = 'ВТ'

) AS group_counts ON "Н_ГРУППЫ_ПЛАНОВ"."ГРУППА" = group_counts."ГРУППА"
GROUP BY "Н_ГРУППЫ_ПЛАНОВ"."ПЛАН_ИД"
HAVING COUNT("Н_ГРУППЫ_ПЛАНОВ"."ПЛАН_ИД") < 2;





--5
-- Выведите таблицу со средним возрастом студентов во всех группах (Группа, Средний возраст),
-- где средний возраст больше среднего возраста в группе 3100.

SELECT "Н_УЧЕНИКИ"."ГРУППА", avg(date_part('year', age("Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")))
FROM "Н_ЛЮДИ"
JOIN "Н_УЧЕНИКИ" ON "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
GROUP BY "Н_УЧЕНИКИ"."ГРУППА"
HAVING avg(date_part('year', age("Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ"))) > (SELECT avg(date_part('year', age("Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")))
FROM "Н_ЛЮДИ"
JOIN "Н_УЧЕНИКИ" ON "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
WHERE "Н_УЧЕНИКИ"."ГРУППА" = '1101');
--6
-- Получить список студентов, зачисленных до первого сентября 2012 года на первый курс заочной формы обучения. В результат включить:
-- номер группы;
-- номер, фамилию, имя и отчество студента;
-- номер и состояние пункта приказа;
-- Для реализации использовать подзапрос с EXISTS.

SELECT "Н_УЧЕНИКИ"."ГРУППА", "Н_ЛЮДИ"."ИД", "Н_ЛЮДИ"."ФАМИЛИЯ", "Н_ЛЮДИ"."ИМЯ", "Н_ЛЮДИ"."ОТЧЕСТВО", "Н_ПЛАНЫ"."НОМЕР", "Н_УЧЕНИКИ"."СОСТОЯНИЕ"
FROM "Н_УЧЕНИКИ"
JOIN "Н_ЛЮДИ" ON "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
JOIN "Н_ПЛАНЫ" ON "Н_ПЛАНЫ"."ИД" = "Н_УЧЕНИКИ"."ПЛАН_ИД"
WHERE EXISTS (
    SELECT 1
    FROM "Н_ПЛАНЫ"
    WHERE "Н_ПЛАНЫ"."КУРС" = 1
        AND "Н_ПЛАНЫ"."ФО_ИД" = 3
        AND DATE("Н_ПЛАНЫ"."ДАТА_УТВЕРЖДЕНИЯ") < '2012-09-01'
        AND "Н_ПЛАНЫ"."ИД" = "Н_УЧЕНИКИ"."ПЛАН_ИД"
)
GROUP BY "Н_УЧЕНИКИ"."ГРУППА", "Н_ЛЮДИ"."ИД", "Н_ЛЮДИ"."ФАМИЛИЯ", "Н_ЛЮДИ"."ИМЯ", "Н_ЛЮДИ"."ОТЧЕСТВО", "Н_ПЛАНЫ"."НОМЕР", "Н_УЧЕНИКИ"."СОСТОЯНИЕ";

--7
-- Сформировать запрос для получения числа в группе No 3100 хорошистов.
select count("Н_ЛЮДИ"."ИД")
    from "Н_ЛЮДИ"
        join "Н_УЧЕНИКИ" on "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
        join "Н_ПЛАНЫ" on "Н_УЧЕНИКИ"."ПЛАН_ИД" = "Н_ПЛАНЫ"."ИД"
        JOIN "Н_ОТДЕЛЫ" ON "Н_ПЛАНЫ"."ОТД_ИД" = "Н_ОТДЕЛЫ"."ИД"
    where "Н_УЧЕНИКИ"."ГРУППА" = '3100'
        and "Н_ЛЮДИ"."ИД" in (SELECT "Н_ЛЮДИ"."ИД"
                            FROM "Н_ЛЮДИ"
                                   join "Н_ВЕДОМОСТИ" on "Н_ВЕДОМОСТИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
                                    join "Н_ОЦЕНКИ" on "Н_ВЕДОМОСТИ"."ОЦЕНКА" = "Н_ОЦЕНКИ"."КОД"

                            group by  "Н_ЛЮДИ"."ИД", "Н_ОЦЕНКИ"."КОД"
                            HAVING  "Н_ОЦЕНКИ"."КОД" = '4');


