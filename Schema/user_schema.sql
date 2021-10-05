DROP SCHEMA IF EXISTS "User" CASCADE;
CREATE SCHEMA "User";

CREATE TABLE "User".nameBookmark (
  "userId" char(10),
  "c_nconst" char(10)
);

CREATE TABLE "User".titleBookmark (
  "userId" char(10),
  "c_tconst" char(10)
);

CREATE TABLE "User".searchHistory (
  "userId" char(10),
  "t_searchKey" Text
);

CREATE TABLE "User".User (
  "userId" SERIAL UNIQUE PRIMARY KEY,
  "vc_username" varchar(256) UNIQUE NOT NULL,
  "vc_password" varchar(256) NOT NULL,
  "b_isAdmin" bool,
  "b_isAdult" bool
);

CREATE TABLE "User".ratings (
  "userId" char(10),
  "c_tconst" char(10),
  "i_rate" int4,
  "t_comment" text
);