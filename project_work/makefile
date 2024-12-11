DB_NAME = hospital

create_db:
	createdb ${DB_NAME};

create_tables:
	psql -U ${USER} -d ${DB_NAME} -a -f scripts/create_tables.sql

create: create_db create_tables

fill_tables:
	psql -U ${USER} -d ${DB_NAME} -a -f scripts/fill_tables.sql

drop_db:
	dropdb ${DB_NAME}

