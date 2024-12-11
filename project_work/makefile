DB_NAME = hospital

create_db:
	createdb ${DB_NAME};

create_tables:
	psql -U ${USER} -d ${DB_NAME} -a -f scripts/create_database.sql

# fill_db:


drop_db:
	dropdb ${DB_NAME}

