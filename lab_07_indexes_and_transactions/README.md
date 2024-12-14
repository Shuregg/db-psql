# lab_07_indexes_and_transactions

```bash
psql -U ${USER} -d postgres -a -c "DROP DATABASE students;"
createdb students
psql students < students_dump_4.sql
```

## 1. Производительность и эффективность

### 1.1. Исследование производительности системы

<!-- Для глубокого анализа данного задания вам необходимо ознакомиться с рекомендованной литературой, указанной в источниках. -->

#### 1.1.1 Создайте таблицу, содержащую значения посещаемости студентом института. Таблица содержит номер студенческого билета, время его входа, выхода и сгенерированное случайное кодовое число при выходе из вуза

```sql
CREATE TABLE attendance (
attendance_id SERIAL PRIMARY KEY, 
generated_code VARCHAR(64),
person_id integer,
enter_time timestamp,
exit_time timestamp,
FOREIGN KEY (person_id) REFERENCES student_ids (student_id)
);
```

#### 1.1.2 С помощью следующего скрипта заполните таблицу данными

```sql
do
$$
DECLARE 
    enter_time timestamp(0);
    exit_time timestamp(0);
    person_id integer; 
    enter_id VARCHAR(64);
BEGIN
    FOR i IN 1..1000000 LOOP
    
        -- Генерируем случайную дату в указанном диапазоне
        enter_time := to_timestamp(
            random() * (
                extract(epoch from '2023-12-31'::date) - 
                extract(epoch from '2023-01-01'::date)
            ) + 
            extract(epoch from '2023-01-01'::date)
        );
    
        -- Генерируем случайный интервал времени, который пробыл в вузе студент (не более 10 часов)
        exit_time := enter_time + (floor(random() * 36000 + 1)*'1 SECOND'::interval);
    
        person_id := (
            SELECT student_id FROM students
            ORDER BY random()
            LIMIT 1
        );
    
        enter_id := md5(random()::text);
    
        INSERT INTO attendance(generated_code, person_id, enter_time,exit_time) 
        VALUES(enter_id, person_id, enter_time, exit_time);
    END LOOP;
END
$$;
```

```bash
Query returned successfully in 49 secs 411 msec.
```

#### 1.1.3 EXPLAIN ANALYZE

* Добавьте в таблицу attendance одно значение, измерив время данной операции.

    Insert new row (without indexes)

    ```sql
        \timing
        INSERT INTO attendance (generated_code, person_id, enter_time, exit_time)
        VALUES (
            md5(random()::TEXT),
            (
                SELECT student_id FROM students
                ORDER BY random()
                LIMIT 1
            ),
            now(),
            now() + '1 hour'::INTERVAL
        );
        \timing
    ```

    psql output:

    ```sql
    students=#     \timing
    Timing is on.
    students=#     INSERT INTO attendance (generated_code, person_id, enter_time, exit_time)
    students-#     VALUES (
    students(#         md5(random()::TEXT),
    students(#         (
    students(#             SELECT student_id FROM students
    students(#             ORDER BY random()
    students(#             LIMIT 1
    students(#         ),
    students(#         now(),
    students(#         now() + '1 hour'::INTERVAL
    students(#     );
    INSERT 0 1
    Time: 4,310 ms
    students=#     \timing
    ```

* Далее измерьте время выполнения запроса, выводящего содержимого таблицы в отсортированном виде по столбцу generated_code.

    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM attendance ORDER BY generated_code;
    ```

    Output

    ```sql
    "QUERY PLAN"
    "Gather Merge  (cost=71089.50..168318.59 rows=833334 width=57) (actual time=306.225..673.070 rows=1000001 loops=1)"
    "  Workers Planned: 2"
    "  Workers Launched: 2"
    "  ->  Sort  (cost=70089.48..71131.15 rows=416667 width=57) (actual time=296.282..435.365 rows=333334 loops=3)"
    "        Sort Key: generated_code"
    "        Sort Method: external merge  Disk: 25256kB"
    "        Worker 0:  Sort Method: external merge  Disk: 23648kB"
    "        Worker 1:  Sort Method: external merge  Disk: 23648kB"
    "        ->  Parallel Seq Scan on attendance  (cost=0.00..15530.67 rows=416667 width=57) (actual time=0.007..12.397 rows=333334 loops=3)"
    "Planning Time: 0.172 ms"
    "Execution Time: 694.338 ms"
    ```

    Output 2:

    ```sql
    "QUERY PLAN"
    "Gather Merge  (cost=71089.50..168318.59 rows=833334 width=57) (actual time=319.256..692.464 rows=1000001 loops=1)"
    "  Workers Planned: 2"
    "  Workers Launched: 2"
    "  ->  Sort  (cost=70089.48..71131.15 rows=416667 width=57) (actual time=313.873..459.755 rows=333334 loops=3)"
    "        Sort Key: generated_code"
    "        Sort Method: external merge  Disk: 23648kB"
    "        Worker 0:  Sort Method: external merge  Disk: 24640kB"
    "        Worker 1:  Sort Method: external merge  Disk: 24264kB"
    "        ->  Parallel Seq Scan on attendance  (cost=0.00..15530.67 rows=416667 width=57) (actual time=0.005..13.871 rows=333334 loops=3)"
    "Planning Time: 0.122 ms"
    "Execution Time: 715.045 ms"
    ```

* Добавьте индекс на столбец generated_code. Повторите предыдущие две операции. Сравните полученное время. Во сколько раз оно изменилось? Результаты вычисления занесите в таблицу.

    Create indexes

    ```sql
    CREATE INDEX idx_generated_code ON attendance (generated_code);
    ```

    Insert new row (with indexes)

    ```sql
        \timing
        INSERT INTO attendance (generated_code, person_id, enter_time, exit_time)
        VALUES (
            md5(random()::TEXT),
            (
                SELECT student_id FROM students
                ORDER BY random()
                LIMIT 1
            ),
            now(),
            now() + '1 hour'::INTERVAL
        );
        \timing
    ```

    Output:

    ```sql
    students=#     \timing
    Timing is on.
    students=#     INSERT INTO attendance (generated_code, person_id, enter_time, exit_time)
        VALUES (
            md5(random()::TEXT),
            (
                SELECT student_id FROM students
                ORDER BY random()
                LIMIT 1
            ),
            now(),
            now() + '1 hour'::INTERVAL
        );
    INSERT 0 1
    Time: 3,570 ms
    ```

    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM attendance ORDER BY generated_code;
    ```

    ```sql
    "QUERY PLAN"
    "Index Scan using idx_generated_code on attendance  (cost=0.42..89293.41 rows=1000001 width=57) (actual time=0.053..451.839 rows=1000002 loops=1)"
    "Planning Time: 0.122 ms"
    "Execution Time: 468.981 ms"
    ```

|      |Время до индексирования Tb|Время после индексирования Ta|Ta/ Tb      |
|------|--------------------------|-----------------------------|------------|
|SELECT|715.045 ms                |468.981 ms                   |0,655876204 |
|INSERT|4,310 ms                  |3,570 ms                     |0,8283062650|

### 1.2. Индексы и селективность

Выполните запрос, выводящий все строки таблицы attendance, измерьте время его выполнения. Добавьте условие, выбрав только все записи, связанные с одним конкретным студентом. Аналогично измерьте время выполнения. Создайте индекс на атрибут person_id и повторите эксперименты. Сравните время выполнения операций до создания индекса и после. Объясните полученный результат.

#### 1.2.1 Select all rows (without indexes)

```sql
EXPLAIN ANALYZE
SELECT * FROM attendance;
```

Output:

```sql
"QUERY PLAN"
"Seq Scan on attendance  (cost=0.00..21364.01 rows=1000001 width=57) (actual time=0.006..33.772 rows=1000002 loops=1)"
"Planning Time: 0.032 ms"
"Execution Time: 50.682 ms"
```

#### 1.2.2 Select all rows + WHERE (without indexes)

```sql
EXPLAIN ANALYZE
SELECT * FROM attendance
WHERE person_id = 830609;
```

Output:

```sql
"QUERY PLAN"
"Gather  (cost=1000.00..17777.84 rows=2055 width=57) (actual time=0.176..19.010 rows=2095 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on attendance  (cost=0.00..16572.34 rows=856 width=57) (actual time=0.026..14.302 rows=698 loops=3)"
"        Filter: (person_id = 830609)"
"        Rows Removed by Filter: 332636"
"Planning Time: 0.052 ms"
"Execution Time: 19.067 ms"
```

#### 1.2.3 Create indexes

```sql
CREATE INDEX idx_person_id ON attendance (person_id);
```

Output:

```sql
CREATE INDEX
Query returned successfully in 296 msec.
```

#### 1.2.4 Select all rows (with indexes)

```sql
EXPLAIN ANALYZE
SELECT * FROM attendance;
```

Output:

```sql
"QUERY PLAN"
"Seq Scan on attendance  (cost=0.00..21364.02 rows=1000002 width=57) (actual time=0.003..32.280 rows=1000002 loops=1)"
"Planning Time: 0.084 ms"
"Execution Time: 48.859 ms"
```

#### 1.2.5 Select all rows + WHERE (with indexes)

```sql
EXPLAIN ANALYZE
SELECT * FROM attendance
WHERE person_id = 830609;
```

```sql
"QUERY PLAN"
"Bitmap Heap Scan on attendance  (cost=24.35..5286.89 rows=2055 width=57) (actual time=0.421..1.939 rows=2095 loops=1)"
"  Recheck Cond: (person_id = 830609)"
"  Heap Blocks: exact=1906"
"  ->  Bitmap Index Scan on idx_person_id  (cost=0.00..23.84 rows=2055 width=0) (actual time=0.200..0.201 rows=2095 loops=1)"
"        Index Cond: (person_id = 830609)"
"Planning Time: 0.067 ms"
"Execution Time: 2.007 ms"
```

#### 1.2.5 Comparison table

|              |Время до индексирования Tb|Время после индексирования Ta|Ta/ Tb     |
|--------------|--------------------------|-----------------------------|-----------|
|SELECT        |50.682 ms                 |48.859 ms                    |0,964030622|
|SELECT + WHERE|19.067 ms                 |2.007 ms                     |0,105260398|

### 1.3 Анализ плана выполнения запроса

Составьте запрос к таблице attendance, выводящий все строки в отсортированном порядке, в которых столбец generated_code заканчивается символом ‘a’. Проанализируйте полученный запрос и объясните результат. Используется ли в данном случае индекс?

```sql
EXPLAIN ANALYZE
SELECT * 
FROM attendance
WHERE generated_code LIKE '%a'
ORDER BY generated_code;
```

```sql
"QUERY PLAN"
"Gather Merge  (cost=18121.19..20085.53 rows=16836 width=57) (actual time=60.704..79.449 rows=62480 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Sort  (cost=17121.17..17142.21 rows=8418 width=57) (actual time=53.422..55.866 rows=20827 loops=3)"
"        Sort Key: generated_code"
"        Sort Method: quicksort  Memory: 2786kB"
"        Worker 0:  Sort Method: quicksort  Memory: 2486kB"
"        Worker 1:  Sort Method: quicksort  Memory: 2403kB"
"        ->  Parallel Seq Scan on attendance  (cost=0.00..16572.34 rows=8418 width=57) (actual time=0.015..35.373 rows=20827 loops=3)"
"              Filter: ((generated_code)::text ~~ '%a'::text)"
"              Rows Removed by Filter: 312507"
"Planning Time: 0.110 ms"
"Execution Time: 80.589 ms"
```

## 2. Транзакции

Предположим, что студент группы ИВТ-42 Полиграф Шариков во время зимней сессии пересдал экзамен по дисциплине «Операционные системы» на оценку 5 и пересдал экзамен по дисциплине «Базы данных» на 5. Одновременно с проставлением баллов за его успехами следила методист кафедры. Для работы с несколькими транзакциями запустите два командных окна (запросника). В первом вводите команды за преподавателя, проставляющего оценки, а во втором за методиста, просматривающего результаты.

### 2.1 Работа с транзакциями

В рамках транзакции измените значение оценки студента по Операционным системам и проверьте значение в первом и втором окне. Зафиксируйте изменения и вновь проверьте значения. Аналогично внесите новую оценку по Базам данных и проверьте изменения.

|Преподаватель|Методист|
|-|-|
|||
|BEGIN;||
|Изменяет оценку;||
|Добавляет оценку;||
||Смотрит результат до фиксации изменений преподавателем;|
|COMMIT||
||Смотрит результат после фиксации изменений преподавателем;|

|Профессор                                                          |Методист                                                       |
|-------------------------------------------------------------------|---------------------------------------------------------------|
|BEGIN;                                                             |                                                               |
|    UPDATE field_comprehensions                                    |                                                               |
|    SET mark = 5                                                   |                                                               |
|    WHERE                                                          |                                                               |
|    student_id = (                                                 |                                                               |
|        SELECT student_id FROM students WHERE last_name = 'Шариков'|                                                               |
|        AND first_name = 'Полиграф'                                |                                                               |
|    )                                                              |                                                               |
|    AND field IN (                                                 |                                                               |
|        SELECT field_id                                            |                                                               |
|        FROM fields                                                |                                                               |
|        WHERE (                                                    |                                                               |
|            field_name = 'Операционные системы'                    |                                                               |
|            OR (field_name = 'Базы данных' AND semester = 7)       |                                                               |
|        )                                                          |                                                               |
|    );                                                             |                                                               |
|                                                                   |BEGIN;                                                         |
|                                                                   |SELECT mark                                                    |
|                                                                   |FROM field_comprehensions                                      |
|                                                                   |WHERE                                                          |
|                                                                   |student_id = (                                                 |
|                                                                   |    SELECT student_id FROM students WHERE last_name = 'Шариков'|
|                                                                   |    AND first_name = 'Полиграф'                                |
|                                                                   |)                                                              |
|                                                                   |AND field IN (                                                 |
|                                                                   |    SELECT field_id                                            |
|                                                                   |    FROM fields                                                |
|                                                                   |    WHERE (                                                    |
|                                                                   |        field_name = 'Операционные системы'                    |
|                                                                   |        OR (field_name = 'Базы данных' AND semester = 7)       |
|                                                                   |    )                                                          |
|                                                                   |);                                                             |
|COMMIT;                                                            |                                                               |
|                                                                   |SELECT mark                                                    |
|                                                                   |FROM field_comprehensions                                      |
|                                                                   |WHERE                                                          |
|                                                                   |student_id = (                                                 |
|                                                                   |    SELECT student_id FROM students WHERE last_name = 'Шариков'|
|                                                                   |    AND first_name = 'Полиграф'                                |
|                                                                   |)                                                              |
|                                                                   |AND field IN (                                                 |
|                                                                   |    SELECT field_id                                            |
|                                                                   |    FROM fields                                                |
|                                                                   |    WHERE (                                                    |
|                                                                   |        field_name = 'Операционные системы'                    |
|                                                                   |        OR (field_name = 'Базы данных' AND semester = 7)       |
|                                                                   |    )                                                          |
|                                                                   |);                                                             |
|                                                                   |END;                                                           |

Профессор (update marks)

```sql
-- Update marks
BEGIN;
    UPDATE field_comprehensions 
    SET mark = 5 
    WHERE 
    student_id = (
        SELECT student_id FROM students WHERE last_name = 'Шариков'
        AND first_name = 'Полиграф'
    ) 
    AND field IN (
        SELECT field_id
        FROM fields 
        WHERE (
            field_name = 'Операционные системы'
            OR (field_name = 'Базы данных' AND semester = 7)
        )
    );
```

Методист (before commit)

```sql
-- Check marks
BEGIN;
SELECT mark
FROM field_comprehensions
WHERE 
student_id = (
    SELECT student_id FROM students WHERE last_name = 'Шариков'
    AND first_name = 'Полиграф'
) 
AND field IN (
    SELECT field_id
    FROM fields 
    WHERE (
        field_name = 'Операционные системы'
        OR (field_name = 'Базы данных' AND semester = 7)
    )
);
```

||"mark"|
|-|-|
|1|2|
|2|2|

Профессор (Commit)

```sql
COMMIT;
```

Методист (after commit)

```sql
-- Check marks
SELECT mark
FROM field_comprehensions
WHERE 
student_id = (
    SELECT student_id FROM students WHERE last_name = 'Шариков'
    AND first_name = 'Полиграф'
) 
AND field IN (
    SELECT field_id
    FROM fields 
    WHERE (
        field_name = 'Операционные системы'
        OR (field_name = 'Базы данных' AND semester = 7)
    )
);
END;
```

||"mark"|
|-|-|
|1|5|
|2|5|

### 2.2 Отмена изменений транзакций

Удалите добавленное значение и верните исправленную оценку в прежнее состояние. Повторите аналогичные действия, только по окончании внесения изменений преподавателем откатите их с помощью команды ROLLBACK.  Какое значение увидела методист?

Revert changes

```sql
-- Revert marks
BEGIN;
    UPDATE field_comprehensions 
    SET mark = 2 
    WHERE 
    student_id = (
        SELECT student_id FROM students WHERE last_name = 'Шариков'
        AND first_name = 'Полиграф'
    ) 
    AND field IN (
        SELECT field_id
        FROM fields 
        WHERE (
            field_name = 'Операционные системы'
            OR (field_name = 'Базы данных' AND semester = 7)
        )
    );
COMMIT;
```

Update mark (with ROLLBACK) (professor)

```sql
-- Update marks (ROLLBACK)
BEGIN;
    UPDATE field_comprehensions 
    SET mark = 5 
    WHERE 
    student_id = (
        SELECT student_id FROM students WHERE last_name = 'Шариков'
        AND first_name = 'Полиграф'
    ) 
    AND field IN (
        SELECT field_id
        FROM fields 
        WHERE (
            field_name = 'Операционные системы'
            OR (field_name = 'Базы данных' AND semester = 7)
        )
    );
```

Output:

```bash
UPDATE 2

Query returned successfully in 61 msec.
```

Методист (before ROLLBACK)

```sql
-- Check marks
BEGIN;
    SELECT mark
    FROM field_comprehensions
    WHERE 
    student_id = (
        SELECT student_id FROM students WHERE last_name = 'Шариков'
        AND first_name = 'Полиграф'
    ) 
    AND field IN (
        SELECT field_id
        FROM fields 
        WHERE (
            field_name = 'Операционные системы'
            OR (field_name = 'Базы данных' AND semester = 7)
        )
    );
```

||"mark"|
|-|-|
|1|2|
|2|2|

Профессор (ROLLBACK)

```sql
ROLLBACK;
```

Методист (after update)

```sql
-- Check marks
    SELECT mark
    FROM field_comprehensions
    WHERE 
    student_id = (
        SELECT student_id FROM students WHERE last_name = 'Шариков'
        AND first_name = 'Полиграф'
    ) 
    AND field IN (
        SELECT field_id
        FROM fields 
        WHERE (
            field_name = 'Операционные системы'
            OR (field_name = 'Базы данных' AND semester = 7)
        )
    );
END;
```

||"mark"|
|-|-|
|1|2|
|2|2|

### 2.3 Моделирование аномалий при выполнении транзакций

Повторите эксперименты в п. 2.1, используя различные уровни изоляции.

#### 2.3.1 READ UNCOMMITTED

* Update

    ```sql
    BEGIN ISOLATION LEVEL READ UNCOMMITTED;
        UPDATE field_comprehensions 
        SET mark = 5 
        WHERE 
        student_id = (
            SELECT student_id FROM students WHERE last_name = 'Шариков'
            AND first_name = 'Полиграф'
        ) 
        AND field IN (
            SELECT field_id
            FROM fields 
            WHERE (
                field_name = 'Операционные системы'
                OR (field_name = 'Базы данных' AND semester = 7)
            )
        );
    ```

* Before commit

    ||"mark"|
    |-|-|
    |1|2|
    |2|2|

* Commit

    ```sql
    COMMIT;
    ```

* After commit

    ||"mark"|
    |-|-|
    |1|5|
    |2|5|

#### 2.3.2 READ COMMITTED

* Update

    ```sql
    BEGIN ISOLATION LEVEL READ COMMITTED;
        UPDATE field_comprehensions 
        SET mark = 5 
        WHERE 
        student_id = (
            SELECT student_id FROM students WHERE last_name = 'Шариков'
            AND first_name = 'Полиграф'
        ) 
        AND field IN (
            SELECT field_id
            FROM fields 
            WHERE (
                field_name = 'Операционные системы'
                OR (field_name = 'Базы данных' AND semester = 7)
            )
        );
    ```

* Before commit

    ||"mark"|
    |-|-|
    |1|2|
    |2|2|

* Commit

    ```sql
    COMMIT;
    ```

* After commit

    ||"mark"|
    |-|-|
    |1|5|
    |2|5|

#### 2.3.3 REPEATABLE READ

* Update

    ```sql
    BEGIN ISOLATION LEVEL REPEATABLE READ;
        UPDATE field_comprehensions 
        SET mark = 5 
        WHERE 
        student_id = (
            SELECT student_id FROM students WHERE last_name = 'Шариков'
            AND first_name = 'Полиграф'
        ) 
        AND field IN (
            SELECT field_id
            FROM fields 
            WHERE (
                field_name = 'Операционные системы'
                OR (field_name = 'Базы данных' AND semester = 7)
            )
        );
    ```

* Before commit

    ||"mark"|
    |-|-|
    |1|2|
    |2|2|

* Commit

    ```sql
    COMMIT;
    ```

* After commit

    ||"mark"|
    |-|-|
    |1|5|
    |2|5|

#### 2.3.4 SERIALIZABLE

* Before commit commit

* Update

    ```sql
    BEGIN ISOLATION LEVEL SERIALIZABLE;
        UPDATE field_comprehensions 
        SET mark = 5 
        WHERE 
        student_id = (
            SELECT student_id FROM students WHERE last_name = 'Шариков'
            AND first_name = 'Полиграф'
        ) 
        AND field IN (
            SELECT field_id
            FROM fields 
            WHERE (
                field_name = 'Операционные системы'
                OR (field_name = 'Базы данных' AND semester = 7)
            )
        );
    ```

* Before commit

    ||"mark"|
    |-|-|
    |1|2|
    |2|2|

* Commit

    ```sql
    COMMIT;
    ```

* After commit

    ||"mark"|
    |-|-|
    |1|5|
    |2|5|

|Преподаватель|Методист|
|-|-|
|BEGIN ISOLATION LEVEL ...; Изменяет оценку; Добавляет оценку; COMMIT|BEGIN ISOLATION LEVEL ...; Смотрит результат до фиксации изменений преподавателем; Смотрит результат после фиксации изменений преподавателем|

Внесите в таблицу в какой момент были получены ошибочные значения из-за аномалий.

|Уровень изоляции|До фиксации|После фиксации|
|----------------|-----------|--------------|
|Read uncommited |2, 2       |5, 5          |
|Read committed  |2, 2       |5, 5          |
|Repeatable read |2, 2       |5, 5          |
|Serializable    |2, 2       |5, 5          |

Т.к. PostgreSQL не допускает возникновения dirty read, то данной аномалии не было обнаружено при чтении незафиксированных данных при уровне изоляции READ UNCOMMITTED.

## 3. Индексация БД

Проанализируйте учебную базу данных и проиндексируйте одно из полей любой таблицы. Объясните свой выбор.

```sql
EXPLAIN ANALYZE
SELECT * FROM professors WHERE salary > 100000::money;
```

```sql
"Seq Scan on professors  (cost=0.00..3.05 rows=21 width=114) (actual time=0.238..0.254 rows=21 loops=1)"
"  Filter: (salary > (100000)::money)"
"  Rows Removed by Filter: 49"
"Planning Time: 0.817 ms"
"Execution Time: 0.265 ms"
```

```sql
CREATE INDEX idx_salary ON professors (salary);
```

```sql
EXPLAIN ANALYZE
SELECT * FROM professors WHERE salary > 100000::money;
```

```sql
"Seq Scan on professors  (cost=0.00..3.05 rows=21 width=114) (actual time=0.004..0.009 rows=21 loops=1)"
"  Filter: (salary > (100000)::money)"
"  Rows Removed by Filter: 49"
"Planning Time: 0.132 ms"
"Execution Time: 0.015 ms"
```

## Контрольные вопросы

1. За счет чего индексы ускоряют выборку данных?  

    * Уменьшения числа операций поиска: Индекс организует данные в упорядоченном виде (например, в виде деревьев или хешей), что позволяет базе данных искать данные за логарифмическое время O(log⁡N)O(logN), а не за линейное O(N)O(N).

    * Снижения объёма сканируемых данных: Вместо полного сканирования всей таблицы используется поиск только в части данных.

2. Существуют ли случаи, когда использование индексов замедляет выборку данных?

    * Если таблица содержит мало строк, чтение индекса и строки в таблице занимает больше времени, чем простое последовательное сканирование.

    * Частые обновления: Вставка, обновление или удаление строк требуют обновления индекса, что увеличивает накладные расходы.

    * Неэффективные запросы: Например, при использовании условий, которые не соответствуют структуре индекса (неравенства, функции и т.д.), индекс не помогает, а добавляет накладные расходы.

    * Селективность данных: Если запрос возвращает большинство строк таблицы (низкая селективность), использование индекса замедлит выборку.

3. Какая структура данных хранит в себе индексные записи?

    * B-деревья (B-Trees):
        Используются для диапазонных запросов (>, <, BETWEEN) и поиска.
        Поддерживают сбалансированную структуру, что гарантирует эффективный доступ к данным.

    * Хеш-таблицы:
        Используются для точного поиска (=).
        Не подходят для диапазонных запросов.

    * GiST (Generalized Search Tree):
        Поддерживает поиск по неструктурированным данным, например, географическим или полнотекстовым данным.

    * GIN (Generalized Inverted Index):
        Применяется для поиска в массивоподобных структурах, например JSON.

4. Для чего предназначены транзакции?

    1. Атомарность (Atomicity) – все операции внутри транзакции гарантированно должны выполниться или не выполниться ни одна из них.
    2. Согласованность (Consistency) ­– база данных в результате выполнения транзакции переходит из одного согласованного состояния в другое
    3. Изолированность (Isolation) – во время выполнения транзакции, другие транзакции должны по возможности минимально влиять на её ход работы
    4. Долговечность (Durability) – после завершения работы транзакции данные должны быть надежно сохранены в базе данных

5. В чем отличие между неповторяющимся и фантомным чтением?

    1. Неповторяющееся чтение связано с изменением существующих строк.

    2. Фантомное чтение связано с добавлением или удалением строк, подходящих под условия запроса.
<!-- 
## Список использованной литературы

* [1] Е. П. Моргунов, PostgreSQL. Основы языка SQL, 1-е ред., Санкт-Петербург: БХВ-Петербург, 2018, p. 336.
* [2] Г. Домбровская, Б. Новиков и А. Бейликова, Оптимизация запросов в PostgreSQL, Москва: ДМА, 2022.
* [3] «Исходный код СУБД postgres,» [В Интернете]. Available: https://github.com/postgres/postgres. [Дата обращения: 30 01 2023].
* [4] Документация к PostgreSQL 15.1, 2022.
* [5] Е. Рогов, PostgreSQL изнутри, 1-е ред., Москва: ДМК Пресс, 2023, p. 662 .
* [6] Б. А. Новиков, Е. А. Горшкова и Н. Г. Графеева, Основы технологии баз данных, 2-е ред., Москва: ДМК пресс, 2020, p. 582. -->
