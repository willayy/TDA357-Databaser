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
CREATE VIEW Registrations AS (
	SELECT Registered.student, Registered.course, 'registered' AS status FROM Registered
	UNION
	SELECT WaitingList.student, WaitingList.course, 'waiting' AS status FROM WaitingList
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
CREATE VIEW NrOfUncompleteMandatoryCourses AS (
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
Create View NrOfSeminarCoursesPassed AS (
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
CREATE VIEW StudentMathCredits AS (
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
	FROM 
	Students, 
	StudentPassedCourses, 
	StudentBranches,
	RecommendedBranch,
	Courses
	WHERE
	Students.idnr = StudentPassedCourses.idnr
	AND Students.idnr = StudentBranches.student
	AND Students.program = StudentBranches.program
	AND StudentBranches.branch = RecommendedBranch.branch
	AND Students.program = RecommendedBranch.program
	AND StudentPassedCourses.course = RecommendedBranch.course
	AND StudentPassedCOurses.course = Courses.code
	GROUP BY Students.idnr
);

CREATE VIEW AllStudentsRecommendedCredits AS (
	SELECT Students.idnr, COALESCE(RecommendedCourseCredits.recommendedcredits, 0)AS recommendedCredits
	FROM Students
	LEFT JOIN RecommendedCourseCredits
	ON (Students.idnr = RecommendedCourseCredits.idnr)
);

CREATE VIEW PathToGraduation AS (
	SELECT
	Students.idnr AS student,
	StudentTotalCredits.totalCredits,
	NrOfUncompleteMandatoryCourses.mandatoryLeft,
	StudentMathCredits.mathCredits,
	NrOfSeminarCoursesPassed.numberOfPassedSeminarCourses AS seminarCourses,

	CASE
	WHEN NrOfUncompleteMandatoryCourses.mandatoryLeft = 0
	AND StudentMathCredits.mathCredits >= 20
	AND NrOfSeminarCoursesPassed.numberOfPassedSeminarCourses >= 1
	AND AllStudentsRecommendedCredits.recommendedCredits >= 10
	THEN TRUE
	ELSE FALSE
	END AS qualified

	FROM 
	Students,
	StudentTotalCredits,
	NrOfUncompleteMandatoryCourses,
	StudentMathCredits,
	NrOfSeminarCoursesPassed,
	AllStudentsRecommendedCredits

	WHERE
	Students.idnr = StudentTotalCredits.idnr 
	AND Students.idnr = NrOfUncompleteMandatoryCourses.idnr 
	AND Students.idnr = StudentMathCredits.idnr 
	AND Students.idnr = NrOfSeminarCoursesPassed.idnr
	AND Students.idnr = AllStudentsRecommendedCredits.idnr
);