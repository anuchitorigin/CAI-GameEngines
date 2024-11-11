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
    bucketid VARCHAR(40) NOT NULL UNIQUE,
    bucketname VARCHAR(80) NOT NULL,
    buckettype VARCHAR(80) NOT NULL,
    bucketdata LONGBLOB NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE contents (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    bucketid VARCHAR(40) NOT NULL UNIQUE,
    bucketname VARCHAR(80) NOT NULL,
    buckettype VARCHAR(80) NOT NULL,
    bucketdata LONGBLOB NOT NULL,
    PRIMARY KEY (id)
);
