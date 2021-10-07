CREATE SCHEMA movie;

--Primary and foreign key missing

--drop all
DROP TABLE IF EXISTS movie.omdb_data CASCADE;
DROP TABLE IF EXISTS movie.titleEpisode CASCADE;
DROP TABLE IF EXISTS movie.titleBasics CASCADE;
DROP TABLE IF EXISTS movie.titleCrew CASCADE;
DROP TABLE IF EXISTS movie.titleprincipals CASCADE;
DROP TABLE IF EXISTS movie.namebasics CASCADE;
DROP TABLE IF EXISTS movie.wi CASCADE;
DROP TABLE IF EXISTS movie.titleakas CASCADE;
DROP TABLE IF EXISTS movie.titleratings CASCADE;

--add primary and foreign keys
CREATE TABLE movie.titleBasics (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  titleType VARCHAR(20),
  primaryTitle TEXT,
  originalTitle TEXT,
  isAdult BOOL,
  startYear CHAR(4),
  endYear CHAR(4),
  runtimeMinutes INT4,
  genres VARCHAR(256)
);

CREATE  TABLE movie.omdb_data (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  poster VARCHAR(256),
  awards TEXT,
  plot TEXT, 
	  FOREIGN KEY(titleId)
	  REFERENCES movie.titlebasics
);

CREATE TABLE movie.titleEpisode (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  parentTId CHAR(10),
  seasonNumber INT4,
  episodeNumber INT4, 
	  FOREIGN KEY(titleId)
	  REFERENCES movie.titlebasics
);

CREATE TABLE movie.titleCrew (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  directors TEXT,
  writers TEXT, 
	FOREIGN KEY(titleId)
	REFERENCES movie.titlebasics
);

CREATE TABLE movie.nameBasics (
  nameId VARCHAR(256) UNIQUE NOT NULL PRIMARY KEY,
  primaryName VARCHAR(256),
  birthYear CHAR(4),
  deathYear CHAR(4),
  primaryProfession VARCHAR(256),
  knownForTitles TEXT 
);

CREATE TABLE movie.titlePrincipals (
  titleId CHAR(10) NOT NULL,
  ordering INT4,
  nameId CHAR(10), --NOT COMPLETELY SURE IT IS UNIQUE, but should be. It is not. So probably combination of nameId and ordering. nope.
  category VARCHAR(50),
  job TEXT,
  characters TEXT, 
	PRIMARY KEY(titleId, ordering, nameId),
	FOREIGN KEY(titleId)
	REFERENCES movie.titleBasics(titleId),
	FOREIGN KEY(nameId)
	REFERENCES movie.namebasics
);

CREATE TABLE movie.wi (
  titleId CHAR(10) NOT NULL,
  word TEXT,
  field CHAR(1),
  lexeme TEXT, 
	PRIMARY KEY(titleId, word, field),
	FOREIGN KEY(titleId)
	REFERENCES movie.titlebasics
);

CREATE TABLE movie.titleAkas (
  titleId CHAR(10) NOT NULL,
  ordering INT4,
  title TEXT,
  region VARCHAR(10),
  language VARCHAR(10),
  types VARCHAR(256),
  attributes VARCHAR(256),
  isOriginalTitle BOOL, 
	PRIMARY KEY(titleId, ordering),
	FOREIGN KEY(titleId)
	REFERENCES movie.titlebasics
);

CREATE TABLE movie.titleRatings (
  titleId CHAR(10) UNIQUE NOT NULL PRIMARY KEY,
  averageRating numeric(5,1),
  numvotes INT4,
	FOREIGN KEY(titleId)
	REFERENCES movie.titlebasics
);

--Insert into, from public. all the same values.
INSERT INTO movie.titlebasics(titleId, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres)
SELECT tconst, titletype, primarytitle, originaltitle, isadult, startyear, endyear, runtimeminutes, genres
FROM title_basics;

--Had to change to 2 columns as primary key in titleakas table, to insure uniqueness.
INSERT INTO movie.titleakas(titleid, ordering, title, region, language, types, attributes, isOriginalTitle)
SELECT titleid, ordering, title, region, language, types, attributes, isoriginaltitle
FROM title_akas;

INSERT INTO movie.titlecrew(titleid, directors, writers)
SELECT tconst, directors, writers
FROM title_crew;

INSERT INTO movie.titleratings(titleid, averagerating, numvotes)
SELECT tconst, averagerating, numvotes
FROM title_ratings;

INSERT INTO movie.titleepisode(titleid, parenttid, seasonnumber, episodenumber)
SELECT tconst, parenttconst, seasonnumber, episodenumber
FROM title_episode;

--4 left. 2 need to change primary key, like with others. 1 depends one one of aforementioned, last i am unsure. 

--needs 2 attributes as primary keys, to avoid duplicates. Also remove unique from titleid, as it is repeated. Also a duplicate with tid & word as pk. also tid & field. i guess 3 then.
INSERT INTO movie.wi(titleid, word, field, lexeme)
SELECT tconst, word, field, lexeme
FROM wi;
--done but 34s query time.
--Update, now takes 73s
--Only missing this one i guess. Might be correct, just a shit ton of data. 


--Only missing namebasics, which depends on titleprincipals, so ti hase to be done first. Other way around actually. 
INSERT INTO movie.namebasics(nameid, primaryname, birthyear, deathyear, primaryprofession, knownfortitles)
SELECT nconst, primaryname, birthyear, deathyear, primaryprofession, knownfortitles
FROM name_basics;

INSERT INTO movie.titleprincipals(titleid, ordering, nameid, category, job, characters)
SELECT t.tconst, t.ordering, t.nconst, t.category, t.job, t.characters
FROM title_principals t, name_basics n
WHERE t.nconst=n.nconst;
--22s. improvement i guess.


--Actual solution, done! 1.53s
INSERT INTO movie.omdb_data(titleid, poster, awards, plot)
SELECT o.tconst, o.poster, o.awards, o.plot
FROM omdb_data o, title_basics t
WHERE o.tconst = t.tconst;

--I kinda think it is completely done, can check after. When? after. After what? After after. 

--create functions/functionality.

