--D1

DROP FUNCTION registerUser(_user varchar(256), _pwd varchar(256), _isAdmin bool);
CREATE OR REPLACE FUNCTION registerUser(_user varchar(256), _pwd varchar(256), _isAdmin bool)
RETURNS void
LANGUAGE plpgsql AS
    $$
    DECLARE res varchar(256) = 'Done';
        BEGIN
            INSERT INTO "user".user(username, password, isadmin, isadult)
            VALUES (_user, _pwd, _isAdmin, false);
        END;
    $$;

CREATE OR REPLACE FUNCTION get_titlebookmarks(var_username VARCHAR)
RETURNS TABLE(titleId VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY
		SELECT titleId
		FROM "user".titlebookmark
		WHERE "user".titlebookmark.username = var_username;
END;
$$;

CREATE OR REPLACE FUNCTION get_namebookmarks(var_username VARCHAR)
RETURNS TABLE(titleId VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY
		SELECT titleId
		FROM "user".namebookmark
		WHERE "user".namebookmark.username = var_username;
END;
$$;

CREATE OR REPLACE FUNCTION get_ratings(var_username VARCHAR)
RETURNS TABLE(titleId VARCHAR, rate INTEGER, comment TEXT)
LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY
		SELECT titleId, ratings.rate, ratings.comment
		FROM "user".ratings
		WHERE "user".ratings.username = var_username;
END;
$$;

CREATE OR REPLACE FUNCTION get_searchhistory(var_username VARCHAR)
RETURNS TABLE(searchKey VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY
		SELECT searchKey
		FROM "user".searchhistory
		WHERE "user".searchhistory.username = var_username;
END;
$$;

--D2.
CREATE OR REPLACE FUNCTION string_search(string VARCHAR, username VARCHAR)
RETURNS TABLE(id VARCHAR(10), title VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE substring VARCHAR(256);
BEGIN
	IF username IS NOT NULL AND username IN (SELECT "user".username FROM "user"."user") THEN
		INSERT INTO "user".searchhistory
		VALUES (username, string);
	END IF;
	substring := '%' || string || '%';
	RETURN QUERY
		SELECT titleid::VARCHAR(10) id, primarytitle::VARCHAR title
		FROM movie.titlebasics NATURAL JOIN omdb_data
		WHERE primarytitle LIKE substring OR plot LIKE substring;
END;
$$;

--D3.
CREATE OR REPLACE FUNCTION ratings(_titleId char(10), _vote numeric(5, 1), _user varchar(256), _comment Text)
    RETURNS void
    LANGUAGE plpgsql AS
    $$
    BEGIN
        IF _vote < 10 AND _vote > 1 THEN
            UPDATE movie.titleratings
                SET numvotes = numvotes + 1,
                    averagerating = (averagerating + ((_vote - averagerating) / numvotes))
                    WHERE titleid = _titleId;
        IF _user IS NOT NULL AND _user IN (SELECT "user".username FROM "user"."user") THEN
                INSERT INTO "user".ratings(username, "titleId", rate, comment)
                VALUES(_user, _titleId, _vote, _comment);
        END IF;
        END IF;
    END;
    $$;

--D4.
CREATE OR REPLACE FUNCTION structured_string_search(username VARCHAR, _str1 varchar(255), _str2 varchar(255), _str3 varchar(255), _str4 varchar(255))
    RETURNS TABLE (titleid char(10), primarytitle text)
    LANGUAGE plpgsql AS
    $$
    DECLARE result varchar(255);
    DECLARE str1 varchar(255);
    DECLARE str2 varchar(255);
    DECLARE str3 varchar(255);
    DECLARE str4 varchar(255);
    BEGIN
        str1 := '%' || _str1 || '%';
        str2 := '%' || _str2 || '%';
        str3 := '%' || _str3 || '%';
        str4 := '%' || _str4 || '%';
        IF username IS NOT NULL AND username IN (SELECT "user".username FROM "user"."user") THEN
		INSERT INTO "user".searchhistory(username, "searchKey")
		VALUES (username, str1 || str2 || str3 || str4);
		END IF;
        IF _str1 IS NULL THEN
            str1 = '%%';
        END IF;
        IF _str2 IS NULL THEN
            str2 = '%%';
        END IF;
        IF _str3 IS NULL THEN
            str3 = '%%';
        END IF;
        IF _str4 IS NULL THEN
            str4 = '%%';
        END IF;
                RETURN QUERY
        SELECT DISTINCT titlebasics.titleid, titlebasics.primarytitle
        FROM movie.titlebasics
            JOIN movie.omdb_data od on titlebasics.titleid = od.titleid
            JOIN movie.titleprincipals t on titlebasics.titleid = t.titleid
            JOIN movie.namebasics n on t.nameid = n.nameid
        WHERE LOWER(titlebasics.primarytitle) LIKE LOWER(str1)
          AND LOWER(od.plot) LIKE LOWER(str2)
          AND LOWER(t.characters) LIKE LOWER(str3)
          AND LOWER(n.primaryname) LIKE LOWER(str4);
    END;
    $$;

--D5.
CREATE OR REPLACE FUNCTION structured_actors_search(_str1 varchar(255), _str2 varchar(255), _str3 varchar(255), _str4 varchar(255))
    RETURNS TABLE (nameid varchar(256), primaryname varchar(256))
    LANGUAGE plpgsql AS
    $$
    DECLARE result varchar(255);
    DECLARE str1 varchar(255);
    DECLARE str2 varchar(255);
    DECLARE str3 varchar(255);
    DECLARE str4 varchar(255);
    BEGIN
        str1 := '%' || _str1 || '%';
        str2 := '%' || _str2 || '%';
        str3 := '%' || _str3 || '%';
        str4 := '%' || _str4 || '%';
        IF _str1 IS NULL THEN
            str1 = '%%';
        END IF;
        IF _str2 IS NULL THEN
            str2 = '%%';
        END IF;
        IF _str3 IS NULL THEN
            str3 = '%%';
        END IF;
        IF _str4 IS NULL THEN
            str4 = '%%';
        END IF;
        RETURN QUERY
        SELECT DISTINCT namebasics.nameid, namebasics.primaryname FROM movie.namebasics
            JOIN movie.titleprincipals t on namebasics.nameid = t.nameid
            JOIN movie.titlebasics t2 on t2.titleid = t.titleid
            JOIN movie.omdb_data od on t2.titleid = od.titleid
        WHERE LOWER(t2.primarytitle) LIKE LOWER(str1)
          AND LOWER(od.plot) LIKE LOWER(str2)
          AND LOWER(t.characters) LIKE LOWER(str3)
          AND LOWER(namebasics.primaryname) LIKE LOWER(str4);
    END;
    $$;

--D6.
CREATE OR REPLACE VIEW players AS
SELECT titleid, nameid, primaryname
FROM movie.titleprincipals NATURAL JOIN movie.namebasics
WHERE category = 'actor' OR category = 'actress';

CREATE OR REPLACE FUNCTION find_co_players(actorname VARCHAR)
RETURNS TABLE(co_playerid VARCHAR(10), primaryname VARCHAR, frequency INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY
		SELECT players.nameid::VARCHAR(10) co_playerid, players.primaryname, count(titleid)::INTEGER
		FROM players
		WHERE players.primaryname != actorname
			AND players.titleid IN (SELECT titleid FROM players WHERE actorname = players.primaryname)
		GROUP BY nameid, players.primaryname
		HAVING count(titleid) > 0;
END;
$$;

CREATE OR REPLACE FUNCTION find_co_players_by_id(actorid VARCHAR)
RETURNS TABLE(co_playerid VARCHAR(10), primaryname VARCHAR, frequency INTEGER)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
		SELECT players.nameid::VARCHAR(10) co_playerid, players.primaryname, count(titleid)::INTEGER
		FROM players
		WHERE players.nameid != actorid
			AND players.titleid IN (SELECT titleid FROM players WHERE actorid = players.nameid)
		GROUP BY nameid, players.primaryname
		HAVING count(titleid) > 0;
END;
$$;

--D7.
CREATE OR REPLACE FUNCTION find_rating(actorid VARCHAR)
RETURNS FLOAT
LANGUAGE plpgsql AS $$
DECLARE res FLOAT;
BEGIN
		SELECT SUM(averagerating * numvotes) / SUM(numvotes) INTO res
		FROM movie.titleratings NATURAL JOIN movie.titleprincipals
		WHERE actorid = titleprincipals.nameid;
		RETURN res;
END;
$$;

CREATE OR REPLACE PROCEDURE update_name_ratings()
LANGUAGE plpgsql AS $$
BEGIN
		ALTER TABLE movie.namebasics ADD COLUMN IF NOT EXISTS rating FLOAT;

		UPDATE movie.namebasics
		SET rating = find_rating(nameid);
END;
$$;

--D8.
CREATE OR REPLACE FUNCTION popular_actors_in_movie(var_movieid VARCHAR)
RETURNS TABLE(id VARCHAR, primaryname VARCHAR, rating FLOAT)
LANGUAGE plpgsql AS $$
BEGIN
		RETURN QUERY
			SELECT nameid::VARCHAR id, namebasics.primaryname, rating
			FROM movie.titleprincipals NATURAL JOIN movie.namebasics
			WHERE titleid = var_movieid AND (category = 'actor' OR category = 'actress')
			ORDER BY rating DESC;
END;
$$;

--list actors with an actor
CREATE OR REPLACE FUNCTION popular_actors_co_players(var_actorid VARCHAR)
RETURNS TABLE(id VARCHAR, primaryname VARCHAR, rating FLOAT)
LANGUAGE plpgsql AS $$
BEGIN
		RETURN QUERY
			SELECT DISTINCT nameid::VARCHAR id, namebasics.primaryname, namebasics.rating
			FROM movie.titleprincipals NATURAL JOIN movie.namebasics
			WHERE namebasics.rating IS NOT NULL AND nameid IN (SELECT co_playerid FROM find_co_players_by_id(var_actorid))
			ORDER BY namebasics.rating DESC;
END;
$$;

--D9.
CREATE OR REPLACE FUNCTION recommended(title varchar)
RETURNS TABLE(
  primarytitle text
)
LANGUAGE plpgsql as
$$
BEGIN
	RETURN QUERY
		WITH main_title(titletype, isadult, genres) AS (
			SELECT titletype, isadult, genres
			FROM movie.titlebasics
			WHERE titleid = title
		)
    SELECT DISTINCT t.primarytitle
		FROM movie.titlebasics t, main_title
		WHERE  main_title.titletype = t.titletype
			AND main_title.isadult = t.isadult
			AND main_title.genres = t.genres;
END;
$$;

--D10.
ALTER TABLE movie.wi
DROP COLUMN field,
DROP COLUMN lexeme;

--D11.
DROP FUNCTION IF EXISTS exact_match(text[]);
CREATE or replace FUNCTION exact_match(VARIADIC w text[])
RETURNS TABLE(
titleid char(10),
primarytitle text
) AS $$
DECLARE
w_elem text;
t text = '';
BEGIN
t := 'SELECT t.titleid, primarytitle FROM movie.titlebasics t, ';
t := t || ' (select w.titleid from movie.wi w where w.word = ''' || w[1] || ''' ';
FOREACH w_elem IN ARRAY w[2:]
LOOP
t := t || 'INTERSECT ';
t := t || 'select w.titleid from movie.wi w where w.word = ''' || w_elem || ''' ';
END LOOP;
t := t || ') w WHERE t.titleid=w.titleid;';
RAISE NOTICE '%', t;
RETURN QUERY EXECUTE t;
END $$
LANGUAGE 'plpgsql';

--D12.
CREATE or replace FUNCTION best_match(VARIADIC w text[])
RETURNS TABLE(
titleid char(10),
rank bigint,
primarytitle text
) AS $$
DECLARE
w_elem text;
t text = '';
BEGIN
t := 'SELECT t.titleid, sum(relevance) rank, primarytitle FROM movie.titlebasics t, ';
t := t || ' (select w.titleid, 1 relevance from movie.wi w where w.word = ''' || w[1] || ''' ';
FOREACH w_elem IN ARRAY w[2:]
LOOP
t := t || 'UNION ALL ';
t := t || 'select w.titleid, 1 relevance from movie.wi w where w.word = ''' || w_elem || ''' ';
END LOOP;
t := t || ') w WHERE t.titleid=w.titleid GROUP BY t.titleid, t.primarytitle ORDER BY rank DESC;';
RAISE NOTICE '%', t;
RETURN QUERY EXECUTE t;
END $$
LANGUAGE 'plpgsql';