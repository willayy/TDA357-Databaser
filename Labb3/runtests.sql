-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
-- This script deletes everything in your database
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
-- This line makes psql stop on the first error it encounters
-- You may want to remove this when running tests that are intended to fail
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE; -- More talk
\set QUIET false
-- \ir is for include relative, it will run files in the same directory as this
-- file
-- Note that these are not SQL statements but rather Postgres commands (no
-- terminating semicolon).

\ir tables.sql
\ir views.sql
\ir triggers.sql
\ir inserts.sql

-- Tests various queries from the assignment, uncomment these as you make progress
SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;
SELECT student, course, courseName, grade, credits FROM FinishedCourses ORDER BY
(student, course);
SELECT student, course, status FROM Registrations ORDER BY (status, course,
student);
SELECT student, totalCredits, mandatoryLeft, mathCredits, seminarCourses,
qualified FROM PathToGraduation ORDER BY student;

-- Helper views for PathToGraduation (optional)
SELECT idnr, course FROM StudentPassedCourses ORDER BY (idnr, course);
SELECT idnr, course FROM UncompleteMandatoryCourses ORDER BY (idnr, course);
SELECT idnr, recommendedCredits FROM RecommendedCourseCredits ORDER BY (idnr);
-- Life-hack: When working on a new view you can write it as a query here (without
-- creating a view) and when it works just add CREATE VIEW and put it in views.sql

-- Tests for the triggers
INSERT INTO Registrations VALUES ('1111111111', 'CCC111'); -- should register
INSERT INTO Registrations VALUES ('5555555555', 'CCC222'); -- should be waiting
INSERT INTO Registrations VALUES ('3333333333', 'CCC222'); -- should be waiting
INSERT INTO Registrations VALUES ('5555555555', 'CCC333'); -- should register
INSERT INTO Registrations VALUES ('3333333333', 'CCC333'); -- should be waiting
INSERT INTO Registrations VALUES ('4444444444', 'CCC444'); -- should register

-- Tests for the triggers uncomment to try
--INSERT INTO Registrations VALUES ('4444444444', 'CCC111'); -- should fail already passed
--INSERT INTO Registrations VALUES ('1111111111', 'CCC111'); -- should fail already registered
--INSERT INTO Registrations VALUES ('5555555555', 'CCC222'); -- should fail already waiting
--INSERT INTO Registrations VALUES ('5555555555', 'CCC444'); -- should fail doesnt have the prerequisites
--INSERT INTO Registrations VALUES ('2222222222', 'CCC444'); -- should fail doesnt have the prerequisites

DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111'; -- should unregister, no one on waiting list
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222'; -- should unregister, course still overfilled
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC222'; -- should unregister from waiting list
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222'; -- should unregister, student 555.. should be registered
INSERT INTO Registrations VALUES ('2222222222', 'CCC111'); -- should register
