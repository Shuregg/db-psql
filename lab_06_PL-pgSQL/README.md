[task 1: calculate_avg_mark.sql](task_01_calculate_avg_mark.sql)

# PL/pgSQL, procedures, functions, triggers

## 1. Create script, that calculates average mark of a student

### 1.1 PL/pgSQL

* PL/pgSQL script:

    ```SQL
    CREATE OR REPLACE FUNCTION calculate_avg_mark(student_id_i INTEGER) RETURNS NUMERIC AS $$
    DECLARE
        avg_mark NUMERIC;
    BEGIN
        SELECT AVG(mark)
        INTO avg_mark
        FROM field_comprehensions
        WHERE field_comprehensions.student_id = student_id_i;

        RETURN avg_mark;
    END;
    $$ LANGUAGE PLPGSQL;
    ```

* Check function in psql terminal

    ```sql
    \timing
    SELECT calculate_avg_mark(812507);
    \timing off
    ```

* Result:

    ```sql
    students=# \timing
    Timing is on.
    students=# SELECT calculate_avg_mark(812507);
     calculate_avg_mark 
    --------------------
     3.6388888888888889
    (1 row)
    
    Time: 1,085 ms
    students=# \timing off
    Timing is off.
    ```

### 1.2 SQL Query

* Compare perfomance with usual SQL query

    ```SQL
    SELECT AVG(mark) AS avg_mark
    FROM field_comprehensions
    WHERE student_id = 1;
    ```

* Result:

    ```sql
    students=# \timing
    Timing is on.
    students=# SELECT AVG(mark) AS avg_mark
    students-# FROM field_comprehensions
    students-# WHERE student_id = 1;
     avg_mark 
    ----------
             
    (1 row)
    
    Time: 0,833 ms
    ```

## 2. Query writing training

### 2.2

* Display professors total ZET

    ```sql
    DO $$
    DECLARE
        rec RECORD;
    BEGIN
        FOR rec IN
            SELECT 
                p.last_name,
                p.first_name,
                p.patronymic,
                p.salary,
                COALESCE(SUM(f.zet), 0) AS total_zet
            FROM 
                professors p
            LEFT JOIN 
                fields f ON p.professor_id = f.professor_id
            GROUP BY 
                p.professor_id, p.last_name, p.first_name, p.patronymic, p.salary
            ORDER BY 
                p.last_name, p.first_name
        LOOP
            RAISE NOTICE 'Professor: % % %, wage rate: %, employment (ZET): %', 
                rec.last_name, rec.first_name, rec.patronymic, rec.salary, rec.total_zet;
        END LOOP;
    END $$;
    ```

### 2.12

* Generate random coords for each student

    ```SQl
    DO $$
    DECLARE
        student_rec RECORD;
        lat NUMERIC;
        lon NUMERIC;
    BEGIN
        FOR student_rec IN
            SELECT student_id FROM students
        LOOP
            -- Generate random latitude and longitude
            lat := round((random() * 180 - 90)::numeric, 6);  -- Range: [-90 : 90] degrees
            lon := round((random() * 360 - 180)::numeric, 6); -- Range: [-180 : 180] degrees

            RAISE NOTICE 'Student ID: %, Latitude: %, Longitude: %', student_rec.student_id, lat, lon;
        END LOOP;
    END $$;
    ```

### 2.22 SQL Procedures

* Change group number procedure

    ```sql
    CREATE OR REPLACE PROCEDURE update_group_course(new_course INTEGER, target_group_number VARCHAR)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        new_group_number VARCHAR;
    BEGIN
        -- -- Check that course value is in range
        -- IF new_course < 1 OR new_course > 5 THEN
        --     RAISE EXCEPTION 'Course value should be in range: [1 : 5]';
        -- END IF;
    
        -- current_group_number := SUBSTRING(target_group_number FROM '^[А-Яа-я]+-([0-9]+)$');
    
        -- New group name
        new_group_number := SUBSTRING(target_group_number FROM '^[А-Яа-я]+') || '-' || new_course;
        
        -- Update students
        UPDATE students
        SET students_group_number = new_group_number
        WHERE students_group_number = target_group_number;
        
        -- Update group name
        UPDATE students_groups
        SET students_group_number = new_group_number
        WHERE students_group_number = target_group_number;
    
        -- Check update
        IF NOT FOUND THEN
            RAISE NOTICE 'The group % not found.', target_group_number;
        ELSE
            RAISE NOTICE 'Name of the group was changed from % to %', target_group_number, new_group_number;
        END IF;
    END;
    $$;
    CALL update_group_course(12, 'ИВТ-12');
    ```

### 2.32 SQL Function

* get student's average mark by student's id

    ```SQL
    CREATE OR REPLACE FUNCTION calculate_avg_mark(student_id_i INTEGER) RETURNS NUMERIC AS $$
    DECLARE
        avg_mark NUMERIC;
    BEGIN
        SELECT AVG(mark)
        INTO avg_mark
        FROM field_comprehensions
        WHERE field_comprehensions.student_id = student_id_i;

        RETURN avg_mark;
    END;
    $$ LANGUAGE PLPGSQL;
    ```

### 2.42 SQL Function

* Function that calculates average students age for every group

    ```sql
    CREATE OR REPLACE FUNCTION calculate_avg_age_for_groups()
    RETURNS TABLE(students_group_number VARCHAR, avg_age NUMERIC) AS $$
    BEGIN
        RETURN QUERY
        SELECT
            s.students_group_number,
            AVG(EXTRACT(YEAR FROM AGE(s.birthday))) AS avg_age
        FROM
            students s
        GROUP BY
            s.students_group_number;
    END;
    $$ LANGUAGE plpgsql;
    
    SELECT * FROM calculate_avg_age_for_groups();
    ```

### 2.52 Trigger

* Function + Trigger: Cannot add or update student with age over 100 years

    ```sql
    -- Function check_student_age()
    CREATE OR REPLACE FUNCTION check_student_age()
    RETURNS TRIGGER AS $$
    DECLARE
        years_difference INTEGER;
    BEGIN
        years_difference := EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM NEW.birthday);

        IF (EXTRACT(MONTH FROM CURRENT_DATE) < EXTRACT(MONTH FROM NEW.birthday)) OR
           (EXTRACT(MONTH FROM CURRENT_DATE) = EXTRACT(MONTH FROM NEW.birthday) AND
            EXTRACT(DAY FROM CURRENT_DATE) < EXTRACT(DAY FROM NEW.birthday)) THEN
            years_difference := years_difference - 1;
        END IF;

        IF years_difference > 100 THEN
            RAISE EXCEPTION 'Cannot add or update student with age over 100 years.';
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger prevent_age_over_100
    CREATE OR REPLACE TRIGGER prevent_age_over_100
    BEFORE INSERT OR UPDATE ON students
    FOR EACH ROW
    EXECUTE FUNCTION check_student_age();

    INSERT INTO students (student_id, last_name, first_name, patronymic, students_group_number, birthday, email)
    VALUES
    (130, 'ivanov', 'ivan', 'ivanovich', 'ИВТ-42', '1920-03-28', 'ivan130@miet.ru');
    ```

    Result:

    ```sql
    ERROR:  Cannot add or update student with age over 100 years.
    CONTEXT:  PL/pgSQL function check_student_age() line 17 at RAISE 

    SQL state: P0001
    ```

### 2.62

* Prevent similar professors names

    ```sql
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    
    -- Function prevent_duplicate_professors()
    CREATE OR REPLACE FUNCTION prevent_duplicate_professors()
    RETURNS TRIGGER AS $$
    DECLARE
        duplicate_count INTEGER;
    BEGIN
        -- Checking for similar professors
        SELECT COUNT(*)
        INTO duplicate_count
        FROM professors
        WHERE levenshtein(NEW.last_name, last_name) <= 2
        AND levenshtein(NEW.first_name, first_name) <= 2
        AND levenshtein(NEW.patronymic, patronymic) <= 2;
    
        IF duplicate_count > 0 THEN
            RAISE EXCEPTION 'Duplicate professor with similar name already exists.';
        END IF;
    
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    
    -- Trigger prevent_duplicate_professor_trigger
    CREATE OR REPLACE TRIGGER prevent_duplicate_professor_trigger
    BEFORE INSERT OR UPDATE ON professors
    FOR EACH ROW
    EXECUTE FUNCTION prevent_duplicate_professors();
    
    INSERT INTO professors (
        professor_id,
        last_name,
        first_name,
        patronymic,
        degree,
        academic_title,
        current_position,
        experience,
        salary
    )
    VALUES
    (801337, 'Павлович', 'Иванн', 'Петрович', 'д.б.н.', 'профессор', 'профессор', 38, 143657.84);
    ```

### 3. Create trigger for one of the tables from lab_04

* Trigger for update status for the students

    ```sql
    CREATE OR REPLACE FUNCTION update_status()
    RETURNS TRIGGER AS $$
    BEGIN
        IF CURRENT_DATE BETWEEN NEW.issue_date AND NEW.expiration_date THEN
            NEW.status := 'active';
        ELSE
            NEW.status := 'inactive';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER set_status_before_insert
    BEFORE INSERT OR UPDATE ON student_ids
    FOR EACH ROW
    EXECUTE FUNCTION update_status();
    ```
