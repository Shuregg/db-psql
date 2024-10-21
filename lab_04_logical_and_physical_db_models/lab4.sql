-- This querry returns you list of constraint's names of foreign keys.
SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'fields' AND constraint_type = 'FOREIGN KEY';

----------------------------------------------------------------------

-- Task 1. Replace 1:n by n:n relation type.

-- 1.1 Delete foreign key from "fields" table.
ALTER TABLE fields
DROP CONSTRAINT fields_professor_id_fkey;

-- 1.2 Create additional table for n:n relation between professors and fields tables.
CREATE TABLE professors_fields (
    professor_id INTEGER NOT NULL,
    field_id UUID NOT NULL,
    PRIMARY KEY
        (professor_id, field_id),
    FOREIGN KEY (professor_id)  REFERENCES professors(professor_id),
    FOREIGN KEY (field_id)      REFERENCES fields(field_id)
);

-- 1.3 Insert all rows from "fields" table
INSERT INTO professors_fields (professor_id, field_id)
SELECT professor_id, field_id
FROM fields
WHERE professor_id IS NOT NULL;

-- 1.4 Delete atribute professor_id from "fields" table.
ALTER TABLE fields
DROP COLUMN professor_id;

-- 1.5 Fill new table with new rows
INSERT INTO professors_fields (professor_id, field_id)
VALUES
     (810001, '0567507e-641d-40f5-ae7a-42a128f2e46f')
    ,(810006, '0567507e-641d-40f5-ae7a-42a128f2e46f')
    ,(809001, '0567507e-641d-40f5-ae7a-42a128f2e46f')
    ,(890001, '0567507e-641d-40f5-ae7a-42a128f2e46f')
    ,(830003, '0567507e-641d-40f5-ae7a-42a128f2e46f')

-- 1.6 Check new table
SELECT 
	 pf.professor_id
	,p.last_name
	,p.first_name
	,p.patronymic
	,f.field_name
	,pf.field_id
FROM
	professors_fields pf
INNER JOIN
	fields f ON f.field_id = pf.field_id
INNER JOIN
	professors p ON p.professor_id = pf.professor_id
ORDER BY field_name

-- Task 2. Add a new field to the 'students_id' table, that contains status of 'active' or 'inactive'.
ALTER TABLE student_ids
ADD COLUMN status VARCHAR(10) NOT NULL DEFAULT 'inactive',
ADD CONSTRAINT status_check CHECK (status IN ('active', 'inactive'));

UPDATE student_ids
SET status = CASE
    WHEN CURRENT_DATE BETWEEN issue_date AND expiration_date THEN 'active'
    ELSE 'inactive'
END;
SELECT * FROM student_ids
