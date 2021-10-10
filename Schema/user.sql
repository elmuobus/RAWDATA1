DROP SCHEMA IF EXISTS "user" CASCADE;
CREATE SCHEMA "user";

CREATE TABLE "user".user (
  username varchar(256) UNIQUE NOT NULL PRIMARY KEY,
  password varchar(256) NOT NULL,
  isAdmin bool,
  isAdult bool
);

CREATE TABLE "user".nameBookmark
(
    username varchar(256) NOT NULL,
    nameId char(10) REFERENCES Movie.namebasics(nameid),
    CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username)
);

CREATE TABLE "user".titleBookmark (
  "username" varchar(256) NOT NULL,
  "titleId" char(10),
    CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username),
    CONSTRAINT FK_titleId FOREIGN KEY ("titleId") REFERENCES Movie.titlebasics("titleid")
);

CREATE TABLE "user".searchHistory (
  "username" varchar(256) NOT NULL,
  "searchKey" Text,
    CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username)
);

CREATE TABLE "user".ratings (
  "username" varchar(256) NOT NULL,
  "titleId" char(10),
  "rate" int4,
  "comment" text,
    CONSTRAINT FK_username FOREIGN KEY (username) REFERENCES "user".user(username),
  CONSTRAINT FK_titleId FOREIGN KEY ("titleId") REFERENCES Movie.titlebasics("titleid")
);