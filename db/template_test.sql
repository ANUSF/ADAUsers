PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE "ProjectEJB" (
  "comment" text,
  "creationDate" datetime default NULL,
  "id" varchar(100) NOT NULL default '',
  "label" text,
  "scope" text,
  "sponsor" text,
  "title" text,
  "type" text
);
CREATE TABLE "PurposeEJB" (
  "comment" text,
  "creationDate" datetime default NULL,
  "id" varchar(100) NOT NULL default '',
  "label" text
);
CREATE TABLE "RoleEJB" (
  "comment" text,
  "creationDate" datetime default NULL,
  "id" varchar(100) NOT NULL default '',
  "label" text
);
CREATE TABLE "UserEJB" (
  "comment" text,
  "creationDate" datetime default NULL,
  "id" varchar(100) NOT NULL default '',
  "label" text,
  "modificationDate" date default NULL,
  "admin" integer default '0',
  "password" varchar(20) default NULL,
  "active" integer default NULL
);
CREATE TABLE "accesslevel" (
  "datasetID" varchar(100) NOT NULL default '',
  "fileID" varchar(100) default NULL,
  "datasetname" varchar(100) default NULL,
  "fileContent" text,
  "accessLevel" char(1) default NULL
);
CREATE TABLE "agenciesdept" (
  "id" integer NOT NULL,
  "value" varchar(150) NOT NULL default '',
  "name" varchar(150) NOT NULL default '',
  "acsprimember" integer NOT NULL default '1',
  "type" varchar(100) default NULL
);
CREATE TABLE "countries" (
  "id" integer NOT NULL,
  "Countryname" varchar(100) NOT NULL default '',
  "Sym" varchar(10) default ''
);
CREATE TABLE "otherinstitutions" (
  "id" integer NOT NULL,
  "name" varchar(150) NOT NULL default '',
  "acsprimember" integer NOT NULL default '1',
  "type" varchar(100) default NULL
);
CREATE TABLE "searches" (
  "userId" varchar(100) NOT NULL default '',
  "name" varchar(100) default NULL,
  "query" text NOT NULL,
  "date" datetime default NULL
);
CREATE TABLE "searchstats" (
  "date" varchar(6) NOT NULL default '',
  "sessions" integer NOT NULL default '0',
  "searches" integer NOT NULL default '0'
);
CREATE TABLE "uniaustralia" (
  "id" integer NOT NULL,
  "Longuniname" varchar(100) NOT NULL default '',
  "Shortuniname" varchar(30) default '',
  "acsprimember" integer NOT NULL default '1',
  "g8" integer default NULL
);
CREATE TABLE "usage" (
  "server" varchar(100) NOT NULL default '',
  "datasetId" varchar(100) NOT NULL default '',
  "accesses" integer NOT NULL default '0'
);
CREATE TABLE "userAgreement" (
  "agreementID" varchar(100) NOT NULL default '',
  "userID" varchar(100) NOT NULL default ''
);
CREATE TABLE "userGroups" (
  "userId" varchar(100) NOT NULL default '',
  "group" varchar(100) NOT NULL default ''
);
CREATE TABLE "userProject" (
  "projectID" varchar(100) NOT NULL default '',
  "userID" varchar(100) NOT NULL default ''
);
CREATE TABLE "userPurposes" (
  "purposeID" varchar(100) NOT NULL default '',
  "userID" varchar(100) NOT NULL default ''
);
CREATE TABLE "userRole" (
  "id" varchar(100) NOT NULL default '',
  "roleID" varchar(100) NOT NULL default '',
  "rolegroup" text
);
CREATE TABLE "userdetails" (
  "user" varchar(100) NOT NULL,
  "password" varchar(100) default NULL,
  "email" varchar(100) default NULL,
  "institution" varchar(100) default NULL,
  "action" varchar(100) default NULL,
  "position" varchar(100) default NULL,
  "dateregistered" varchar(100) default '',
  "acsprimember" integer default NULL,
  "countryid" integer default NULL,
  "uniid" integer default NULL,
  "departmentid" integer default NULL,
  "institutiontype" varchar(100) default NULL,
  "fname" varchar(50) default NULL,
  "sname" varchar(50) default NULL,
  "title" varchar(10) default NULL,
  "austinstitution" varchar(10) default NULL,
  "otherpd" varchar(100) default NULL,
  "otherwt" varchar(100) default NULL
, role_cms varchar(255));
CREATE TABLE "userpermissiona" (
  "userID" varchar(100) default NULL,
  "datasetID" varchar(100) default NULL,
  "fileID" varchar(100) default NULL,
  "permissionvalue" integer default '0'
);
CREATE TABLE "userpermissionb" (
  "userID" varchar(100) default NULL,
  "datasetID" varchar(100) default NULL,
  "fileID" varchar(100) default NULL,
  "permissionvalue" integer default NULL
);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "undertakings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_user" varchar(255), "is_restricted" boolean, "intended_use_type" varchar(255), "intended_use_other" varchar(255), "intended_use_description" text, "email_supervisor" varchar(255), "funding_sources" text, "agreed" boolean, "processed" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "access_levels_undertakings" ("datasetID" varchar(255), "undertaking_id" integer);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
COMMIT;
