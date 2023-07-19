--indexing film table
ALTER TABLE film ADD COLUMN content_ts tsvector;

UPDATE film 
SET content_ts = x.content_ts 
FROM (
	SELECT film_id,
		setweight(to_tsvector('english',title),'A') ||
		setweight(to_tsvector('english',description),'B')
		AS content_ts
	FROM film
)AS x
WHERE x.film_id = film.film_id

--inverted index
CREATE INDEX idx_content_ts ON film USING gin(content_ts);

--no indexed:string matching
--Execution Time: 11.047 ms
EXPLAIN ANALYZE
SELECT title, description FROM film
WHERE description ILIKE '%man%' OR description ILIKE '%woman%';

--indexed: word matching
--Execution Time: 0.739 ms
EXPLAIN ANALYZE
SELECT title, description FROM film
WHERE to_tsquery('english', 'man | woman') @@ content_ts;

  
--TOP K
--Ranking (1): 1.638 ms
--Ranking (10): 1.969 ms
--Ranking (100): 2.054 ms
EXPLAIN ANALYZE
SELECT title, description, 
       ts_rank_cd(content_ts, query_ts) AS score
FROM film, to_tsquery('english', 'man | woman') query_ts
WHERE query_ts @@ content_ts
ORDER BY score desc
LIMIT 100;


