-- Results using the imdb_small.backup
SELECT registerUser('toto', 'testToto', true); -- Create an admin account.
SELECT registerUser('tata', 'testTata', false); -- Create an user account.

--D2.
SELECT string_search('Star Wars Episode 3', 'testTata'); -- String search with account
SELECT string_search('Twilight', null); -- String search without account

--D3.
SELECT * FROM movie.titleratings WHERE titleid = 'tt1084014'; -- Test query before the rating
SELECT ratings('tt1084014', 4, 'testTata', 'Test comment'); -- Test with user
SELECT * FROM movie.titleratings WHERE titleid = 'tt1084014'; -- Test query after the first rating
SELECT ratings('tt1084014', 7, null , 'Test comment'); -- Test without user
SELECT * FROM movie.titleratings WHERE titleid = 'tt1084014'; -- Test query after the second rating

--D4.
SELECT * FROM structured_string_search('testTata', '','see','','Mads miKKelsen'); -- With users
SELECT * FROM structured_string_search('','see','','Mads miKKelsen'); -- Without users

--D5.
SELECT * FROM structured_actors_search('testTata', '','see','','Mads miKKelsen'); -- With users
SELECT * FROM structured_actors_search('','see','','Mads miKKelsen'); -- Without users

--D6.
SELECT * FROM find_co_players('Matt Damon'); -- Find coplayers by name
SELECT * FROM find_co_players_by_id('nm0000138'); -- Find coplayers by ID

--D7.
SELECT * FROM find_rating('nm0000158'); -- Find rating by ID
CALL update_name_ratings();

--D8.
SELECT * FROM popular_actors_in_movie('tt0418455'); -- Find popular actor in movie by id

--D9.
SELECT * FROM recommended('Wednesday Addiction');

--D10.
ALTER TABLE movie.wi
DROP COLUMN IF EXISTS field,
DROP COLUMN IF EXISTS lexeme;
--D11.
SELECT * FROM exact_match('Twilight');

--D12.
SELECT * FROM best_match('apple', 'mads', 'mikkelsen');
