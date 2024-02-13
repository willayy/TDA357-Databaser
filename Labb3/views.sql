CREATE VIEW BasicInformation AS (
	SELECT s.idnr, s.name, s.login, s.program, sb.branch 
	FROM Students AS s LEFT JOIN StudentBranches AS sb
	ON (s.idnr = sb.student)
);

-- Students that have done a course and recieved a grade
CREATE VIEW FinishedCourses AS (
	SELECT Taken.student, Taken.course, Taken.grade, Courses.name AS courseName, Courses.credits
	FROM Taken, Courses WHERE (Taken.course = Courses.code)
);

-- Students that are registered or waiting for a course
CREATE VIEW RegistrationStatus AS (
	SELECT Registered.student, Registered.course, 'registered' AS status FROM Registered
	UNION
	SELECT WaitingList.student, WaitingList.course, 'waiting' AS status FROM WaitingList
);

-- View of students registered to a specific course and the max capacity
CREATE VIEW SumRegistrations AS (
	SELECT Courses.code, COALESCE(COUNT(Registered.student), 0) AS registeredStudents, LimitedCourses.capacity
	FROM Courses
	LEFT JOIN Registered
	ON (Courses.code = Registered.course)
	LEFT JOIN LimitedCourses
	ON (Courses.code = LimitedCourses.code)
	GROUP BY Courses.code, LimitedCourses.capacity
);

-- Subview of students passed courses, i.e. courses with a grade other than U
CREATE VIEW StudentPassedCourses AS (	
	SELECT Students.idnr, Taken.course
	FROM Students 
	LEFT JOIN Taken
	ON (Students.idnr = Taken.student)
	WHERE (Taken.grade != 'U')
);

-- Subview of student total credits 
CREATE VIEW StudentTotalCredits AS (
	SELECT Students.idnr, COALESCE(SUM(Courses.credits),0) AS totalCredits 
	FROM Students 
	LEFT JOIN StudentPassedCourses ON Students.idnr = StudentPassedCourses.idnr 
	LEFT JOIN Courses ON Courses.code = StudentPassedCourses.course
	GROUP BY Students.idnr
);

-- Subview of all students that have obligatory courses
CREATE VIEW StudentMandatoryCourses AS (	
	SELECT idnr, course
	FROM Students
	NATURAL JOIN MandatoryProgram
	
	UNION

	SElECT student, course
	FROM StudentBranches
	NATURAL JOIN MandatoryBranch
);

-- Subview of all students that have mandatory courses that they have not passed
CREATE VIEW UncompleteMandatoryCourses AS (
	SELECT StudentMandatoryCourses.idnr, StudentMandatoryCourses.course
	FROM StudentMandatoryCourses
	EXCEPT
	SELECT StudentPassedCourses.idnr, StudentPassedCourses.course
	FROM StudentPassedCourses
);

-- Subview of the amount of uncompleted mandatory courses for each all students
CREATE VIEW AllStudentsUncompleteMandatoryCourses AS (
	SELECT Students.idnr, COALESCE(COUNT(UncompleteMandatoryCourses.course),0) AS mandatoryLeft
	FROM Students
	LEFT JOIN UncompleteMandatoryCourses
	ON (Students.idnr = UncompleteMandatoryCourses.idnr)
	GROUP BY Students.idnr
);

-- Subview of all students that have passed a seminar course
CREATE view PassedSeminarCourses AS (
	SELECT students.idnr, studentpassedcourses.course
	FROM students,studentpassedcourses, classified
	WHERE (Students.idnr = StudentPassedCourses.idnr)
	AND (StudentPassedCourses.course = Classified.course)
	AND (Classified.classification = 'seminar')
);

-- All students number of seminar courses passed
Create View AllStudentsPassedSeminarCourses AS (
SELECT Students.idnr, COALESCE(count(courses.code),0) AS numberofpassedseminarcourses
	FROM Students
	LEFT JOIN Passedseminarcourses
	ON (Students.idnr = Passedseminarcourses.idnr)
	LEFT JOIN Courses
	ON (Passedseminarcourses.course = Courses.code)
	GROUP BY Students.idnr
);

-- Subview of all students that have passed a math course
CREATE VIEW PassedMathCourses AS (
	SELECT Students.idnr, COALESCE(StudentPassedCourses.course, NULL) AS passedMathCourse
	FROM Students, StudentPassedCourses, Classified
	WHERE (Students.idnr = StudentPassedCourses.idnr)
	AND (StudentPassedCourses.course = Classified.course)
	AND (Classified.classification = 'math')
);

-- All students sums of math credits
CREATE VIEW AllStudentsMathCredits AS (
	SELECT Students.idnr, COALESCE(SUM(Courses.credits),0) AS mathCredits
	FROM Students
	LEFT JOIN PassedMathCourses
	ON (Students.idnr = PassedMathCourses.idnr)
	LEFT JOIN Courses
	ON (PassedMathCourses.passedMathCourse = Courses.code)
	GROUP BY Students.idnr
);

CREATE VIEW RecommendedCourseCredits AS (
	SELECT Students.idnr, SUM(Courses.credits) AS recommendedCredits
	FROM Students
	JOIN StudentPassedCourses ON (Students.idnr = StudentPassedCourses.idnr)
	JOIN StudentBranches ON (Students.idnr = StudentBranches.student)
	JOIN RecommendedBranch ON (StudentBranches.branch = RecommendedBranch.branch 
	AND StudentBranches.program = RecommendedBranch.program)
	JOIN Courses ON (StudentPassedCourses.course = Courses.code 
	AND Courses.code = RecommendedBranch.course)
	GROUP BY Students.idnr
);

CREATE VIEW AllStudentsRecommendedCredits AS (
	SELECT Students.idnr, COALESCE(RecommendedCourseCredits.recommendedcredits, 0) AS recommendedCredits
	FROM Students
	LEFT JOIN RecommendedCourseCredits
	ON (Students.idnr = RecommendedCourseCredits.idnr)
);

CREATE VIEW PathToGraduation AS (
	SELECT
	Students.idnr AS student,
	StudentTotalCredits.totalCredits,
	AllStudentsUncompleteMandatoryCourses.mandatoryLeft,
	AllStudentsMathCredits.mathCredits,
	AllStudentsPassedSeminarCourses.numberOfPassedSeminarCourses AS seminarCourses,

	CASE
		WHEN AllStudentsUncompleteMandatoryCourses.mandatoryLeft = 0
		AND AllStudentsMathCredits.mathCredits >= 20
		AND AllStudentsPassedSeminarCourses.numberOfPassedSeminarCourses >= 1
		AND AllStudentsRecommendedCredits.recommendedCredits >= 10
	THEN TRUE
	ELSE FALSE
	END AS qualified

	FROM 
	Students,
	StudentTotalCredits,
	AllStudentsUncompleteMandatoryCourses,
	AllStudentsMathCredits,
	AllStudentsPassedSeminarCourses,
	AllStudentsRecommendedCredits

	WHERE Students.idnr = StudentTotalCredits.idnr 
	AND Students.idnr = AllStudentsUncompleteMandatoryCourses.idnr 
	AND Students.idnr = AllStudentsMathCredits.idnr 
	AND Students.idnr = AllStudentsPassedSeminarCourses.idnr
	AND Students.idnr = AllStudentsRecommendedCredits.idnr
);

CREATE VIEW AllCoursesPreRequisites AS (
	SELECT Courses.code AS code, COALESCE(CoursePrerequisites.prerequisite, 'NONE') AS prerequisite
	FROM Courses
	LEFT JOIN CoursePrerequisites
	ON (Courses.code = CoursePrerequisites.course)
);
