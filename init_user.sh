#!/bin/bash
sudo -u postgres createuser --superuser ${USER}
touch ~/.psql_history

# for manual run:
# sudo su - postgres
# psql
# CREATE USER name WITH PASSWORD 'password';
# CREATE DATABASE database_name;
