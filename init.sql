CREATE USER myuser WITH PASSWORD 'mypassword';

CREATE DATABASE mydb_dev;
CREATE DATABASE mydb_test;

\c mydb_dev;
CREATE TABLE statesave(
stateid SERIAL NOT NULL PRIMARY KEY,
ts_utc TIMESTAMP NOT NULL,
statejson JSON NOT NULL
);

CREATE TABLE inputdata(
id SERIAL NOT NULL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
datajson JSON NOT NULL
);

GRANT ALL ON ALL TABLES IN SCHEMA "public" TO myuser;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "public" TO myuser;

COPY inputdata(name, datajson) FROM '/var/lib/postgresql/data/inputdata.txt' CSV QUOTE e'\x01' DELIMITER '|';

\c mydb_test;
CREATE TABLE statesave(
stateid SERIAL NOT NULL PRIMARY KEY,
ts_utc TIMESTAMP NOT NULL,
statejson JSON NOT NULL
);

CREATE TABLE inputdata(
id SERIAL NOT NULL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
datajson JSON NOT NULL
);

GRANT ALL ON ALL TABLES IN SCHEMA "public" TO myuser;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "public" TO myuser;

COPY inputdata(name, datajson) FROM '/var/lib/postgresql/data/inputdata.txt' CSV QUOTE e'\x01' DELIMITER '|';
