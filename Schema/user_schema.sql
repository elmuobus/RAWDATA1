DROP SCHEMA IF EXISTS "User" CASCADE;
CREATE SCHEMA "User";

CREATE TABLE "User".nameBookmark (
  "userId" char(10),
  "nconst" char(10)
);

CREATE TABLE "User".titleBookmark (
  "userId" char(10),
  "tconst" char(10)
);

CREATE TABLE "User".searchHistory (
  "userId" char(10),
  "searchKey" Text
);

CREATE TABLE "User".User (
  "userId" char(10),
  "username" varchar(256),
  "password" varchar(256),
  "role" int4,
  "isAdult" bool
);

CREATE TABLE "User".ratings (
  "userId" char(10),
  "tconst" char(10),
  "rate" int4,
  "opinion" text
);

