-- Our stuff

CREATE FUNCTION try_register() RETURNS TRIGGER AS $try_register$
    BEGIN
        CASE
            WHEN EXISTS( -- Check if student is already is on waiting list
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'waiting'
            ) THEN RAISE EXCEPTION 'Student cant register for a course they are on the waiting list for';

            WHEN EXISTS( -- Check if student is already registered
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'registered'
            ) THEN RAISE EXCEPTION 'Student cant register for a course they are already registered for';
            
            WHEN EXISTS ( -- Check if student is qualified for the course
                SELECT prerequisite FROM AllCoursesPrerequisites WHERE AllCoursesPrerequisites.code = NEW.course
                EXCEPT
                SELECT prerequisite FROM AllCoursesPrerequisites WHERE prerequisite = 'NONE'
                EXCEPT
                SELECT course FROM StudentPassedCourses WHERE StudentPassedCourses.idnr = NEW.idnr
            ) THEN RAISE EXCEPTION 'Student cant register for a course they are not qualified for';

            WHEN EXISTS( -- Check if course is full
                SELECT * FROM SumRegistrations
                WHERE SumRegistrations.code = NEW.course AND SumRegistrations.registeredStudents >= SumRegistrations.capacity
            ) THEN (
                RAISE NOTICE 'Course is full putting student: % in waiting list for course: %', NEW.student, NEW.course;
                INSERT INTO WaitingList VALUES (NEW.student, NEW.course, (SELECT COUNT(*) FROM WaitingList WHERE WaitingList.course = NEW.course) + 1)
                RETURN NULL;
            );
        END CASE;

        RETURN NEW;
    END;
$try_register$ LANGUAGE plpgsql;

CREATE TRIGGER try_register BEFORE INSERT OR UPDATE ON Registered
    FOR EACH ROW EXECUTE FUNCTION try_register();