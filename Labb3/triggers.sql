-- Our stuff

CREATE FUNCTION try_register() RETURNS TRIGGER AS $try_register$
    BEGIN
        CASE
            WHEN EXISTS( -- Check if student is already is on waiting list
                SELECT * FROM Registrations
                WHERE Registrations.student = NEW.student 
                AND Registrations.course = NEW.course
                AND Registrations.status = 'waiting'
            ) THEN 
                RAISE EXCEPTION 'Student cant register for a course they are on the waiting list for';

            WHEN EXISTS( -- Check if student is already registered
                SELECT * FROM Registrations
                WHERE Registrations.student = NEW.student 
                AND Registrations.course = NEW.course
                AND Registrations.status = 'registered'
            ) THEN 
                RAISE EXCEPTION 'Student cant register for a course they are already registered for';
            
            WHEN EXISTS(
                SELECT * from StudentPassedCourses
                WHERE StudentPassedCourses.idnr = NEW.student
                AND StudentPassedCourses.Course = NEW.course
            ) THEN
                RAISE EXCEPTION 'Student has already passed this course'; 

            WHEN EXISTS ( -- Check if student is qualified for the course
                SELECT prerequisite FROM AllCoursesPrerequisites WHERE AllCoursesPrerequisites.code = NEW.course
                EXCEPT
                SELECT prerequisite FROM AllCoursesPrerequisites WHERE prerequisite = 'NONE'
                EXCEPT
                SELECT course FROM StudentPassedCourses WHERE StudentPassedCourses.idnr = NEW.student
            ) THEN 
                RAISE EXCEPTION 'Student cant register for a course they are not qualified for';

            WHEN EXISTS( -- Check if course is full
                SELECT * FROM SumRegistrations
                WHERE SumRegistrations.code = NEW.course AND SumRegistrations.registeredStudents >= SumRegistrations.capacity
            ) THEN 
                RAISE NOTICE 'Course is full putting student: % in waiting list for course: %', NEW.student, NEW.course;
                INSERT INTO WaitingList VALUES (NEW.student, NEW.course, (SELECT COUNT(*) FROM WaitingList WHERE WaitingList.course = NEW.course) + 1);
            
            ELSE 
                RAISE NOTICE 'Student: % registered for course: %', NEW.student, NEW.course;
                INSERT INTO Registered VALUES (NEW.student, NEW.course);
        END CASE;
        RETURN NEW;
    END;
$try_register$ LANGUAGE plpgsql;

CREATE FUNCTION unregister() RETURNS TRIGGER AS $unregister$
    BEGIN
        CASE
            WHEN EXISTS( -- Check if student is on waiting list
                SELECT * FROM Registrations
                WHERE Registrations.student = OLD.student 
                AND Registrations.course = OLD.course
                AND Registrations.status = 'waiting'
            ) THEN 
                DELETE FROM WaitingList WHERE WaitingList.student = OLD.student AND WaitingList.course = OLD.course;
                UPDATE WaitingList SET position = position - 1 WHERE WaitingList.course = OLD.course 
                AND WaitingList.position > (SELECT position FROM WaitingList WHERE WaitingList.course = OLD.course AND WaitingList.position > 1 );
                RAISE NOTICE 'Student: % unregistered from waiting list for course: %', OLD.student, OLD.course;

            WHEN EXISTS( -- Check if student is registered
                SELECT * FROM Registrations
                WHERE Registrations.student = OLD.student 
                AND Registrations.course = OLD.course
                AND (Registrations.status = 'registered')
            ) THEN 
                DELETE FROM Registered WHERE Registered.student = OLD.student AND Registered.course = OLD.course;
                RAISE NOTICE 'Student: % unregistered from course: %', OLD.student, OLD.course;
                CASE
                    WHEN EXISTS( -- Check if course is full
                        SELECT * FROM SumRegistrations
                        WHERE SumRegistrations.code = OLD.course AND SumRegistrations.registeredStudents >= SumRegistrations.capacity
                    ) THEN 
                        RAISE NOTICE 'Course % is still full, no students added from waiting list', OLD.course;
                    ELSE -- If course is not full, take the first student from the waiting list (if there is one) and register them.
                        CASE
                            WHEN EXISTS( -- Check if waitinglist for unregistered course is empty
                                SELECT * FROM WaitingList
                                WHERE WaitingList.course = OLD.course
                            ) THEN 
                                INSERT INTO Registered SELECT student, course FROM WaitingList WHERE WaitingList.course = OLD.course AND WaitingList.position = 1;
                                RAISE NOTICE 'First student on waiting list (student idnr %) for course % is registered to %',
                                (SELECT student FROM WaitingList WHERE course = OLD.course AND position = 1 ), OLD.course, OLD.course;
                                DELETE FROM WaitingList WHERE WaitingList.course = OLD.course AND WaitingList.position = 1;
                                UPDATE WaitingList SET position = position - 1 WHERE WaitingList.course = OLD.course AND WaitingList.position > 1;
                            ELSE 
                                RAISE NOTICE 'No students on waiting list for course %', OLD.course;
                        END CASE;
                END CASE;
        END CASE;
        RETURN OLD;
    END;
$unregister$ LANGUAGE plpgsql;

CREATE TRIGGER unregister INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister();

CREATE TRIGGER try_register INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE FUNCTION try_register();

