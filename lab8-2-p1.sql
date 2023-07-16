CREATE TABLE articles (
body text,
body_indexed text
);

CREATE EXTENSION pg_trgm;
CREATE INDEX articles_search_idx ON articles USING gin
(body_indexed gin_trgm_ops);

INSERT INTO articles
SELECT
	md5(random()::text)
from (
	SELECT * FROM generate_series(1,1000000) AS id
) AS x;

UPDATE articles set body_indexed = body;

EXPLAIN ANALYZE SELECT count(*) FROM articles where body ilike '%abc%';
EXPLAIN ANALYZE SELECT count(*) FROM articles where body_indexed ilike'%abc%';

DELETE FROM articles;
