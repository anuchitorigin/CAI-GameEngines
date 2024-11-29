CREATE DATABASE caige_oper;

USE caige_oper;


CREATE TABLE assessments (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  finished_at datetime,
  userid varchar(40) NOT NULL,
  examid varchar(40) NOT NULL,
  finishscore int NOT NULL DEFAULT 0,
  finishminute int NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
);
