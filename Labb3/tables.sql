-- We decided to exlcude Taking relationship because it isnt needed from the domain description, we also
-- made EnrolledInProgram into an attribute of Students instead of a relationship, since it is a 1-1 relationship

CREATE TABLE Programs (
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL UNIQUE
);

CREATE TABLE Departments (
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL UNIQUE
);

CREATE TABLE Branches (
	name TEXT NOT NULL,
	program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Programs(name) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (name, program)
);

CREATE TABLE Students (
	idnr TEXT PRIMARY KEY CHECK (idnr LIKE '__________'),
	name TEXT NOT NULL,
	login TEXT NOT NULL,
    program TEXT NOT NULL,
	FOREIGN KEY (program) REFERENCES Programs(name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PartOf (
    program TEXT NOT NULL,
    department TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Programs(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (department) REFERENCES Departments(name) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (program, department)
);

CREATE TABLE Courses (
	code TEXT PRIMARY KEY CHECK (code LIKE '______'),
	name TEXT NOT NULL,
	credits DECIMAL NOT NULL,
	department TEXT NOT NULL,
    FOREIGN KEY (department) REFERENCES Departments(name) ON DELETE CASCADE ON UPDATE CASCADE
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
    FOREIGN KEY (program) REFERENCES Programs(name) ON DELETE CASCADE ON UPDATE CASCADE,
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
    FOREIGN KEY (program) REFERENCES Programs(name) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch(
	course TEXT NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (program) REFERENCES Programs(name) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (course, branch, program)
);

CREATE TABLE RecommendedBranch(
	course TEXT NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (course) REFERENCES Courses(code) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (program) REFERENCES Programs(name) ON DELETE CASCADE ON UPDATE CASCADE,
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
	position INTEGER NOT NULL CHECK (position > 0),
    UNIQUE (course, position),
	FOREIGN KEY (student) REFERENCES Students(idnr) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course) REFERENCES LimitedCourses(code) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (student, course)
);