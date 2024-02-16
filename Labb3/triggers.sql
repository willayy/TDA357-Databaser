-- Our stuff

CREATE FUNCTION try_register() RETURNS TRIGGER AS $try_register$
    BEGIN
        CASE
            WHEN EXISTS( -- Check if student is already is on waiting list
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'waiting'
            ) THEN 
                RAISE EXCEPTION 'Student cant register for a course they are on the waiting list for';

            WHEN EXISTS( -- Check if student is already registered
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'registered'
            ) THEN 
                RAISE EXCEPTION 'Student cant register for a course they are already registered for';
            
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
            
            ELSE RAISE NOTICE 'Student: % registered for course: %', NEW.student, NEW.course;
        END CASE;
        RETURN NEW;
    END;
$try_register$ LANGUAGE plpgsql;

CREATE FUNCTION unregister() RETURNS TRIGGER AS $unregister$
    BEGIN
        CASE
            WHEN EXISTS( -- Check if student is on waiting list
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'waiting'
            ) THEN 
                DELETE FROM WaitingList WHERE WaitingList.student = NEW.student AND WaitingList.course = NEW.course;
                UPDATE WaitingList SET position = position - 1 WHERE WaitingList.course = NEW.course AND WaitingList.position > NEW.position;
                RAISE NOTICE 'Student: % unregistered from waiting list for course: %', NEW.student, NEW.course;

            WHEN EXISTS( -- Check if student is registered
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'registered'
            ) THEN 
                DELETE FROM Registered WHERE Registered.student = NEW.student AND Registered.course = NEW.course;
                RAISE NOTICE 'Student: % unregistered from course: %', NEW.student, NEW.course;
                CASE
                    WHEN EXISTS( -- Check if course is full
                        SELECT * FROM SumRegistrations
                        WHERE SumRegistrations.code = NEW.course AND SumRegistrations.registeredStudents >= SumRegistrations.capacity
                    ) THEN
                    ELSE -- If course is not full, take the first student from the waiting list and register them
                        INSERT INTO Registered SELECT * FROM WaitingList WHERE WaitingList.course = NEW.course AND WaitingList.position = 1;
                        DELETE FROM WaitingList WHERE WaitingList.course = NEW.course AND WaitingList.position = 1;
                        UPDATE WaitingList SET position = position - 1 WHERE WaitingList.course = NEW.course AND WaitingList.position > 1;
                        RAISE NOTICE 'Unregistering caused the first student on the waiting list to be registered for course %', NEW.course;
                END CASE;
            
            ELSE RAISE EXCEPTION 'Student cant unregister from a course they are not registered for or on the waiting list for';
        END CASE;
        RETURN NEW;
    END;
$unregister$ LANGUAGE plpgsql;

CREATE TRIGGER unregister INSTEAD OF UPDATE OR DELETE ON RegistrationStatus
    FOR EACH ROW EXECUTE FUNCTION unregister();

CREATE TRIGGER try_register INSTEAD OF UPDATE OR INSERT ON RegistrationStatus
    FOR EACH ROW EXECUTE FUNCTION try_register();

