CREATE DATABASE caige_auth;

USE caige_auth;


CREATE TABLE auth_tokens (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    sender varchar(20) NOT NULL UNIQUE,
    apikey varchar(80) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);


CREATE TABLE roles (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    roleid varchar(20) NOT NULL UNIQUE,
    rolename varchar(60) NOT NULL,
    roleparam varchar(1000) NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE users (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    belocked boolean NOT NULL DEFAULT 0,
    deleted boolean NOT NULL DEFAULT 0,
    userid varchar(40) NOT NULL UNIQUE,
    loginid varchar(250) UNIQUE,
    passcode varchar(80),
    roleparam varchar(500) NOT NULL,
    firstname varchar(60) NOT NULL,
    lastname varchar(60),
    employeeid varchar(20),
    remark varchar(250),
    PRIMARY KEY (id)
);


CREATE TABLE log_sessions (
    id int NOT NULL AUTO_INCREMENT,
    created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
    sessionid varchar(40) NOT NULL,
    user_id int NOT NULL,
    accesstoken varchar(40) NOT NULL,
    expired_at datetime NOT NULL,
    callerip varchar(40) NOT NULL,
    callername varchar(60) NOT NULL,
    purpose varchar(20) NOT NULL,
    PRIMARY KEY (id)
);
