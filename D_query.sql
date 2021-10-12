--D3
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
        IF _user IS NOT NULL THEN
                INSERT INTO "user".ratings(username, "titleId", rate, comment)
                VALUES(_user, _titleId, _vote, _comment);
        END IF;
        END IF;
    END;
    $$;

--D4
CREATE OR REPLACE FUNCTION structured_string_search(_str1 varchar(255), _str2 varchar(255), _str3 varchar(255), _str4 varchar(255))
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
--D5
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
select * from structured_actors_search('','see','','Mads miKKelsen');
--D9
