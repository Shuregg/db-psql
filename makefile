create_db:
 bash init_user.sh
 createdb students

dump_db:
 pg_dump students > db_dump.db

drop_current_db: dump_db
 psql -U ${USER} -d postgres -a -c "DROP DATABASE students;"

init_from_dump_db: create_db
 psql students < db_dump.db

init_db: create_db
 psql -U ${USER} -d students -a -f ../sql_help_scripts/create_database.sql
 psql -U ${USER} -d students -a -f ../sql_help_scripts/insert_students.sql

run_db:
 psql -U ${USER} -d students
