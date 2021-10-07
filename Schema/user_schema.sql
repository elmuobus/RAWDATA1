DROP SCHEMA IF EXISTS "User" CASCADE;
CREATE SCHEMA "User";

CREATE TABLE "User".nameBookmark (
  "username" varchar(256) NOT NULL,
  "nameId" char(10),
    CONSTRAINT FK_username FOREIGN KEY ("username") REFERENCES user("username"),
    CONSTRAINT FK_nameId FOREIGN KEY ("nameId") REFERENCES Movie.Name("nameId")
);

CREATE TABLE "User".titleBookmark (
  "username" varchar(256) NOT NULL,
  "titleId" char(10),
    CONSTRAINT FK_username FOREIGN KEY ("username") REFERENCES user("username"),
    CONSTRAINT FK_titleId FOREIGN KEY ("titleId") REFERENCES Movie.titleBasics("titleId")
);

CREATE TABLE "User".searchHistory (
  "username" varchar(256) NOT NULL,
  "searchKey" Text,
    CONSTRAINT FK_username FOREIGN KEY ("username") REFERENCES user("username")
);

CREATE TABLE "User".user (
  "username" varchar(256) UNIQUE NOT NULL PRIMARY KEY,
  "password" varchar(256) NOT NULL,
  "isAdmin" bool,
  "isAdult" bool
);

CREATE TABLE "User".ratings (
  "username" varchar(256) NOT NULL,
  "titleId" char(10),
  "rate" int4,
  "comment" text,
  CONSTRAINT FK_username FOREIGN KEY ("username") REFERENCES user("username"),
  CONSTRAINT FK_titleId FOREIGN KEY ("titleId") REFERENCES Movie.titleBasics("titleId")
);