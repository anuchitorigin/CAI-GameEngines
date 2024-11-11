CREATE DATABASE caige_oper;

USE caige_oper;


CREATE TABLE orders (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  bedone boolean NOT NULL DEFAULT 0,
  becancelled boolean NOT NULL DEFAULT 0,
  docid varchar(20) NOT NULL UNIQUE,
  docno int NOT NULL,
  companyname varchar(120) NOT NULL,
  contact varchar(120),
  address1 varchar(120),
  address2 varchar(120),
  telno varchar(20),
  faxno varchar(20),
  taxcode varchar(20),
  startdate datetime,
  finishdate datetime,
  refid varchar(40),
  remark varchar(120),
  PRIMARY KEY (id)
);


CREATE TABLE orderitems (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  order_id int NOT NULL,
  itemno int NOT NULL,
  goodservice_id int NOT NULL,
  quantity decimal(20,6) NOT NULL,
  remark varchar(120),
  PRIMARY KEY (id)
);


CREATE TABLE jobs (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  finished_at datetime,
  bedone boolean NOT NULL DEFAULT 0,
  becancelled boolean NOT NULL DEFAULT 0,
  order_id int NOT NULL,
  job_id int NOT NULL,
  docid varchar(20) NOT NULL UNIQUE,
  docno int NOT NULL,
  fromuserid varchar(40) NOT NULL,
  touserid varchar(40) NOT NULL,
  bom_id int NOT NULL,
  bomqty decimal(20,6) NOT NULL,
  station_id int,
  duedate datetime NOT NULL,
  refid varchar(40),
  remark varchar(120),
  PRIMARY KEY (id)
);


CREATE TABLE handovers (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  finished_at datetime,
  bedone boolean NOT NULL DEFAULT 0,
  becancelled boolean NOT NULL DEFAULT 0,
  docid varchar(20) NOT NULL UNIQUE,
  docno int NOT NULL,
  checker varchar(120) NOT NULL,
  deliverydate datetime NOT NULL,
  transporter varchar(120),
  drivername varchar(120),
  drivertelno varchar(20),
  vehicleid varchar(20),
  shiptolocname varchar(120),
  contact varchar(120),
  address1 varchar(120),
  address2 varchar(120),
  telno varchar(20),
  refid varchar(40),
  remark varchar(120),
  deliveryremark varchar(120),
  PRIMARY KEY (id)
);


CREATE TABLE handoveritems (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  handover_id int NOT NULL,
  itemno int NOT NULL,
  stock_id int NOT NULL,
  goodservice_id int NOT NULL,
  quantity decimal(20,6) NOT NULL,
  lotid varchar(20),
  serialid varchar(20),
  bestbefore datetime,
  goodafter datetime,
  goodstatus_id int NOT NULL,
  remark varchar(120),
  PRIMARY KEY (id)
);


CREATE TABLE qcitems (
  id int NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime ON UPDATE CURRENT_TIMESTAMP,
  handover_id int NOT NULL,
  itemno int NOT NULL,
  stepname varchar(120) NOT NULL,
  qcname varchar(120) NOT NULL,
  pictureid varchar(40),
  remark varchar(120),
  PRIMARY KEY (id)
);
