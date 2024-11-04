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
(801337, 'Павлов', 'Иван', 'Петрович', 'д.б.н.', 'профессор', 'профессор', 38, 143657.84);

