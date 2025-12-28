-----2.d.ii-----

--1
SELECT AVG(t.price) FROM  titles t, publishers pub
WHERE t.pub_id=pub.pub_id AND pub.pub_name='Algodata Infosystems';

--2
SELECT au.au_lname, au.au_fname, AVG(t.price) FROM authors au, titleauthor ta, titles t
WHERE au.au_id=ta.au_id  AND ta.title_id=t.title_id
GROUP BY au.au_lname, au.au_fname;

--3
SELECT t.price, COUNT(ta.au_id) FROM publishers pub, titles t , titleauthor ta
WHERE pub.pub_id=t.pub_id AND t.title_id= ta.title_id AND pub_name='Algodata Infosystems'
GROUP BY t.price;

--4
SELECT  t.title ,t.price, COUNT(DISTINCT sd.stor_id) FROM titles t, salesdetail sd
WHERE t.title_id= sd.title_id
GROUP BY t.price, t.title;

--5
SELECT t.title, COUNT(DISTINCT sd.stor_id) FROM titles t, salesdetail sd
WHERE t.title_id= sd.title_id
GROUP BY t.title
HAVING COUNT(DISTINCT sd.stor_id)>1;

--6
SELECT t.type , COUNT(t.title_id), AVG(t.price) FROM titles t
WHERE t.type IS NOT NULL
GROUP BY t.type;

--7
SELECT t.title_id, t.total_sales, SUM(sd.qty) AS QTY FROM salesdetail sd, titles t
WHERE t.title_id=sd.title_id
GROUP BY t.title_id, t.total_sales;

--8
SELECT t.title_id, t.total_sales, SUM(sd.qty) AS QTY FROM salesdetail sd, titles t
WHERE t.title_id=sd.title_id
GROUP BY t.title_id, t.total_sales
HAVING t.total_sales <> SUM(sd.qty);

--9
SELECT t.title, COUNT(ta.au_id) FROM titles t , titleauthor ta
WHERE  t.title_id=ta.title_id
GROUP BY t.title
HAVING COUNT(ta.au_id)>=3;
