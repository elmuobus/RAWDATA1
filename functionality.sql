--FUNCTIONALITY


--d10, only need titleid and word for functions.
ALTER TABLE movie.wi 
DROP COLUMN field,
DROP COLUMN lexeme;

--d11
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

SELECT * from exact_match('apple', 'mads', 'mikkelsen');

--d12 Best match. Union and such.
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

SELECT * from best_match('apple', 'mads', 'mikkelsen');
--d13

