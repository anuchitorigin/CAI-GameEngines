CREATE DATABASE caige_log;

USE caige_log;


CREATE TABLE log_users (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    userid varchar(40) NOT NULL,
    incident varchar(120) NOT NULL,
    logdetail varchar(500) NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE log_syss (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    sysid varchar(40) NOT NULL,
    incident varchar(120) NOT NULL,
    logdetail varchar(500) NOT NULL,
    PRIMARY KEY (id)
);
