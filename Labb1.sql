CREATE TABLE Students (
	idnr TEXT PRIMARY KEY CHECK (idnr LIKE '__________'),
	name TEXT NOT NULL,
	login TEXT NOT NULL,
	program TEXT NOT NULL
);

CREATE TABLE Branches (
	name TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
	code TEXT PRIMARY KEY CHECK (code LIKE '______'),
	name TEXT NOT NULL,
	credits DECIMAL NOT NULL,
	department TEXT NOT NULL
);

CREATE TABLE LimitedCourses (
	code TEXT PRIMARY KEY CHECK (code LIKE '______'),
	capacity INTEGER NOT NULL,
	FOREIGN KEY (code) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE StudentBranches (
	student TEXT PRIMARY KEY,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (student) REFERENCES Students(idnr) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program) ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Classifications (
	name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
	course TEXT NOT NULL,
	classification TEXT NOT NULL,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (classification) REFERENCES Classifications(name) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram(
	course TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch(
	course TEXT NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (course, branch, program)
);

CREATE TABLE RecommendedBranch(
	course TEXT NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (course, branch, program)
);

CREATE TABLE Registered (
	student TEXT NOT NULL,
	course TEXT NOT NULL,
	FOREIGN KEY (student) REFERENCES Students(idnr) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (student, course)
);

CREATE TABLE Taken (
	student TEXT NOT NULL,
	course TEXT NOT NULL,
	grade CHAR(1) NOT NULL,
	FOREIGN KEY (student) REFERENCES Students(idnr) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (student, course)
);

CREATE TABLE WaitingList (
	student TEXT NOT NULL,
	course TEXT NOT NULL,
	position INTEGER NOT NULL,
	FOREIGN KEY (student) REFERENCES Students(idnr) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course) REFERENCES LimitedCourses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (student, course)
);

CREATE VIEW BasicInformation AS (
	SELECT s.idnr, s.name, s.login, s.program, sb.branch 
	FROM Students AS s LEFT JOIN StudentBranches AS sb
	ON (s.idnr = sb.student)
);

CREATE VIEW FinishedCourses AS (
	SELECT Taken.student, Taken.course, Taken.grade, Courses.name, Courses.credits
	FROM Taken, Courses WHERE (Taken.course = Courses.code)
);

CREATE VIEW Registrations AS (
	SELECT Registered.student, Registered.course, 'registered' AS status FROM Registered
	UNION
	SELECT WaitingList.student, WaitingList.course, 'waiting' AS status FROM WaitingList
);

-- Subview of students passed courses
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
	SELECT Students.idnr, MandatoryBranch.course
	FROM Students 
	LEFT JOIN MandatoryBranch
	ON (Students.program = MandatoryBranch.program)
	WHERE MandatoryBranch.course IS NOT NULL
	
	UNION

	SElECT Students.idnr, MandatoryProgram.course
	FROM Students 
	LEFT JOIN MandatoryProgram
	ON (Students.program = MandatoryProgram.program)
	WHERE MandatoryProgram.course IS NOT NULL
);

-- Subview of all students that have mandatory courses that they have not passed
CREATE VIEW UncompletedMandatoryCourses AS (
	SELECT StudentsMandatoryCourses.idnr, StudentsMandatoryCourses.course
	FROM StudentsMandatoryCourses
	EXCEPT
	SELECT StudentPassedCourses.idnr, StudentPassedCourses.course
	FROM StudentPassedCourses
);

-- Subview of the amount of uncompleted mandatory courses for each all students
CREATE VIEW CountedUncompleteMandatoryCourses AS (
	SELECT UncompletedMandatoryCourses.idnr, COUNT(UncompletedMandatoryCourses.course) 
	FROM UncompletedMandatoryCourses
	GROUP BY UncompletedMandatoryCourses.idnr

	UNION -- Add all students

	SELECT Students.idnr, '0' 
	FROM Students

	EXCEPT -- Remove the intersection, the students that are also in uncompleted courses

	SELECT Students.idnr, '0'
	FROM Students, UncompletedMandatoryCourses
	WHERE Students.idnr = UncompletedMandatoryCourses.idnr
);
