PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE "anulogs" (
  "name" varchar(128) NOT NULL default '',
  "dataset" varchar(128) NOT NULL default '',
  "method" varchar(32) NOT NULL default '',
  "date_processed" datetime NOT NULL default '0000-00-00 00:00:00'
);
COMMIT;
