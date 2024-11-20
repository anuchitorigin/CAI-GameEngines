CREATE DATABASE caige_data;

USE caige_data;


CREATE TABLE sysvars (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  varid varchar(20) NOT NULL UNIQUE,
  varname varchar(60) NOT NULL,
  descr varchar(120),
  varvalue varchar(500) NOT NULL,
  PRIMARY KEY (id)
);


CREATE TABLE buckets (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    bucketid varchar(40) NOT NULL UNIQUE,
    bucketname varchar(80) NOT NULL,
    buckettype varchar(80) NOT NULL,
    bucketdata LONGBLOB NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE contents (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    bucketid varchar(40) NOT NULL UNIQUE,
    bucketname varchar(80) NOT NULL,
    buckettype varchar(80) NOT NULL,
    bucketdata LONGBLOB NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE modules (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    belocked boolean NOT NULL DEFAULT 0,
    becancelled boolean NOT NULL DEFAULT 0,
    docstatus int NOT NULL DEFAULT 0,
    moduleid varchar(40) NOT NULL UNIQUE,
    modulecode varchar(40) NOT NULL,
    title varchar(120) NOT NULL,
    caption varchar(250),
    descr varchar(1000),
    coverid varchar(40),
    maturityrating int NOT NULL DEFAULT 0,
    tags varchar(1000),
    released_at datetime,
    PRIMARY KEY (id)
);


CREATE TABLE lessons (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    belocked boolean NOT NULL DEFAULT 0,
    becancelled boolean NOT NULL DEFAULT 0,
    docstatus int NOT NULL DEFAULT 0,
    lessonid varchar(40) NOT NULL UNIQUE,
    lessoncode varchar(40) NOT NULL,
    module_id int NOT NULL,
    lessonno int NOT NULL,
    title varchar(120) NOT NULL,
    descr varchar(1000),
    coverid varchar(40),
    contentid varchar(40),
    mediaid varchar(40),
    tags varchar(1000),
    released_at datetime,
    PRIMARY KEY (id)
);


CREATE TABLE exams (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    belocked boolean NOT NULL DEFAULT 0,
    becancelled boolean NOT NULL DEFAULT 0,
    docstatus int NOT NULL DEFAULT 0,
    examid varchar(40) NOT NULL UNIQUE,
    examcode varchar(40) NOT NULL,
    module_id int NOT NULL,
    lesson_id int NOT NULL,
    maxscore int NOT NULL,
    examminute int NOT NULL,
    title varchar(120) NOT NULL,
    caption varchar(250),
    descr varchar(1000),
    coverid varchar(40),
    maturityrating int NOT NULL DEFAULT 0,
    tags varchar(1000),
    released_at datetime,
    PRIMARY KEY (id)
);


CREATE TABLE quizzes (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    belocked boolean NOT NULL DEFAULT 0,
    becancelled boolean NOT NULL DEFAULT 0,
    docstatus int NOT NULL DEFAULT 0,
    exam_id int NOT NULL,
    quizno int NOT NULL,
    quizminute int NOT NULL,
    question varchar(1000),
    contentid varchar(40),
    mediaid varchar(40),
    released_at datetime,
    PRIMARY KEY (id)
);


CREATE TABLE choices (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    quiz_id int NOT NULL,
    answer varchar(250),
    choiceno int NOT NULL,
    choicescore int NOT NULL,
    becorrect boolean NOT NULL DEFAULT 0,
    mediaid varchar(40),
    feedbackid varchar(40),
    PRIMARY KEY (id)
);
