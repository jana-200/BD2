-----2.a.ii-----
--1
SELECT authors.au_lname FROM authors
WHERE city='Oakland';

--2
SELECT au_lname, address FROM authors
WHERE au_fname LIKE 'A%';

--3
SELECT au_lname, address FROM authors
WHERE phone IS NULL;

--4
SELECT au_lname FROM authors
WHERE state='CA' AND phone NOT LIKE '415%';

--5
SELECT au_lname FROM authors
WHERE country='BEL' OR country='NDL' OR country='LUX';

--6
SELECT DISTINCT pub.pub_id FROM publishers pub, titles tit
WHERE pub.pub_id=tit.pub_id AND tit.type='psychology';

--7
SELECT DISTINCT pub.pub_id FROM publishers pub, titles tit
WHERE pub.pub_id=tit.pub_id AND tit.type='psychology' AND (price<10 OR price>25);

--8
SELECT DISTINCT city FROM authors
WHERE (au_fname='Albert' OR au_lname LIKE '%er') AND state='CA';

--9
SELECT state,country FROM authors
WHERE state IS NOT NULL AND country NOT LIKE 'USA';

--10
SELECT DISTINCT type FROM titles
WHERE price<15;

