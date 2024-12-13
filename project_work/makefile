DB_NAME = hospital

PREFIX = query_
POSTFIX = .sql

DUMP_NAME = dump_$(DB_NAME)$(POSTFIX)

all:
	clear;
	@for NUM in $(shell seq -w 1 20); do \
		$(MAKE) query NUM=$$NUM; \
	done

create_db:
	createdb $(DB_NAME);

create_tables:
	psql -U ${USER} -d $(DB_NAME) -a -f scripts/create_tables.sql

create_indexes:
	psql -U ${USER} -d $(DB_NAME) -a -f scripts/create_indexes.sql

create_procedures:
	psql -U ${USER} -d $(DB_NAME) -a -f scripts/create_procedures.sql

create: create_db create_tables create_indexes create_procedures

fill_tables:
	psql -U ${USER} -d $(DB_NAME) -a -f scripts/fill_tables.sql

drop_db:
	dropdb $(DB_NAME)

query:
	psql -U ${USER} -d $(DB_NAME) -a -f queries/$(PREFIX)$(NUM)$(POSTFIX)

dump:
	pg_dump $(DB_NAME) > $(DUMP_NAME)

restore:
	psql $(DB_NAME)  < $(DUMP_NAME)
