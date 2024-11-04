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