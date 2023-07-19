CREATE TABLE news(
	id_seq integer,
	id integer,
	title text,
	publication text,
	author text,
	date text,
	year float,
	month float,
	url text,
	content text
)

select count(*) from news;

--indexing film table
ALTER TABLE news ADD COLUMN content_ts tsvector;

UPDATE news 
SET content_ts = x.content_ts 
FROM (
	SELECT id,
		setweight(to_tsvector('english',title),'A') ||
		setweight(to_tsvector('english',content),'B')
		AS content_ts
	FROM news
)AS x
WHERE x.id = news.id

CREATE INDEX idx_content_ts ON news USING gin(content_ts);

--Querys

--Ranking (1): 381.465 ms
--Ranking (10): 384.137 ms
--Ranking (100): 392.058 ms
EXPLAIN ANALYZE
SELECT title, content, 
       ts_rank_cd(content_ts, query_ts) AS score
FROM news, to_tsquery('english', 'Obama | Trump') query_ts
WHERE query_ts @@ content_ts
ORDER BY score desc
LIMIT 10;


--Ranking (1): 30.145 ms
--Ranking (10): 31.558 ms
--Ranking (100): 36.297 ms
EXPLAIN ANALYZE
SELECT title, content, 
       ts_rank_cd(content_ts, query_ts) AS score
FROM news, plainto_tsquery('english', 'Independency of United States') query_ts
WHERE query_ts @@ content_ts
ORDER BY score desc
LIMIT 10;


