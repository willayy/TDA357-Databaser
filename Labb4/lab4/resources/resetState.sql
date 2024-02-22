\set QUIET true
SET client_min_messages TO WARNING;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE;
\set QUIET false
\ir tables.sql
\ir views.sql
\ir triggers.sql
\ir inserts.sql