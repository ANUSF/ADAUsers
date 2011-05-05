PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE "StatementEJB" (
  "comment" text,
  "creationDate" datetime default NULL,
  "id" varchar(100) NOT NULL,
  "label" text,
  "objectId" text,
  "objectType" varchar(100) default NULL,
  "predicateIndex" integer default NULL,
  "predicateType" varchar(100) default NULL,
  "subjectId" varchar(100) default NULL,
  "subjectType" varchar(100) default NULL
);
COMMIT;
