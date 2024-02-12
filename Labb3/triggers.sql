
CREATE FUNCTION emp_stamp() RETURNS trigger AS $emp_stamp$
    BEGIN
        -- Check that empname and salary are given
        IF NEW.empname IS NULL THEN
            RAISE EXCEPTION 'empname cannot be null';
        END IF;
        IF NEW.salary IS NULL THEN
            RAISE EXCEPTION '% cannot have null salary', NEW.empname;
        END IF;

        -- Who works for us when they must pay for it?
        IF NEW.salary < 0 THEN
            RAISE EXCEPTION '% cannot have a negative salary', NEW.empname;
        END IF;

        -- Remember who changed the payroll when
        NEW.last_date := current_timestamp;
        NEW.last_user := current_user;
        RETURN NEW;
    END;
$emp_stamp$ LANGUAGE plpgsql;

CREATE TRIGGER emp_stamp BEFORE INSERT OR UPDATE ON emp
    FOR EACH ROW EXECUTE FUNCTION emp_stamp();

-- Our stuff

CREATE FUNCTION try_register() RETURNS TRIGGER AS $try_register$
    BEGIN
        CASE
            WHEN EXISTS(
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'waiting'
            ) THEN RAISE EXCEPTION 'Student cant register for a course they are on the waiting list for';
            WHEN EXISTS(
                SELECT * FROM RegistrationStatus
                WHERE RegistrationStatus.student = NEW.student 
                AND RegistrationStatus.course = NEW.course
                AND RegistrationStatus.status = 'registered'
            ) THEN RAISE EXCEPTION 'Student cant register for a course they are already registered for';
            WHEN EXISTS (
                SELECT * FROM StudentPassedCourses
                LEFT JOIN CoursePrerequisites ON StudentPassedCourses.course = CoursePrerequisites.course
                WHERE StudentPassedCourses.student = NEW.student AND CoursePrerequisites.prerequisite = NEW.course
            ) THEN RAISE EXCEPTION 'Student cant register for a course they are not qualified for';
            WHEN EXISTS(
                SELECT * FROM SumRegistrations
                WHERE Registrations.course = NEW.course AND Registrations.registeredStudents >= Registrations.capacity
            ) THEN RAISE EXCEPTION 'Course is full';
        END CASE;
        RETURN NEW;
    END;
$try_register$ LANGUAGE plpgsql;

CREATE TRIGGER try_register BEFORE INSERT OR UPDATE ON Registered
    FOR EACH ROW EXECUTE FUNCTION try_register();