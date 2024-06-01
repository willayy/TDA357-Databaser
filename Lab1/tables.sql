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
);

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