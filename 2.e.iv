-----2.e.iv-----

--1
SELECT tit.price,tit.title FROM publishers pub, titles tit
WHERE pub.pub_id=tit.pub_id AND pub.pub_name='Algodata Infosystems' AND price=(SELECT MAX(price) FROM titles t);

--2
SELECT DISTINCT tit.title FROM titles tit , salesdetail sd, salesdetail sd2
WHERE tit.title_id=sd.title_id AND tit.title_id=sd2.title_id AND sd2.stor_id<>sd.stor_id;

--3
SELECT tit.price,tit.title FROM titles tit
WHERE price>(SELECT AVG(price) FROM titles t WHERE tit.type=t.type)*1.5;

--4
SELECT au.au_fname FROM authors au, titleauthor titau, titles tit, publishers pub
WHERE au.au_id=titau.au_id AND titau.title_id=tit.title_id AND tit.pub_id=pub.pub_id AND pub.state=au.state;

--5
SELECT p.pub_name FROM publishers p
WHERE p.pub_id NOT IN (SELECT t.pub_id FROM titles t);

--6
SELECT p.pub_name FROM publishers p, titles t
WHERE p.pub_id=t.pub_id
GROUP BY p.pub_name
HAVING COUNT(t.title_id) >= ALL(SELECT COUNT(t.title_id) AS nb_books FROM titles t
                            GROUP BY t.pub_id);

--7
SELECT p.pub_name FROM publishers p
WHERE NOT EXISTS(SELECT * FROM titles t, salesdetail sd
                WHERE t.title_id = sd.title_id);

--8
SELECT DISTINCT t.title_id FROM authors au, titleauthor ta, titles t, publishers p, stores st, salesdetail sd
WHERE au.au_id =ta.au_id AND ta.title_id=t.title_id AND t.pub_id=p.pub_id AND t.title_id=sd.title_id
AND st.stor_id=sd.stor_id AND au.state = 'CA' AND p.state ='CA' AND st.state ='CA';

--9
SELECT DISTINCT t.title FROM titles t, stores st, salesdetail sd
WHERE t.title_id = sd.title_id AND sd.stor_id = st.stor_id
  AND t.price =( SELECT MAX(t1.price) AS date_plus_recent FROM titles t1);

--11
SELECT DISTINCT au.city FROM authors au
WHERE state='CA' AND city NOT IN (SELECT st.city FROM stores st);

--12
SELECT pub.* FROM publishers pub
WHERE pub.city IN (SELECT city FROM authors GROUP BY city HAVING COUNT(au_id) >= (SELECT COUNT(au.au_id) FROM authors au));

--13
SELECT t.title FROM titles t
WHERE NOT EXISTS(SELECT * FROM titleauthor tit, authors au
                   WHERE t.title_id=tit.title_id AND au.au_id=tit.au_id AND au.state<>'CA');

--15
SELECT DISTINCT t.title, t.title_id FROM titles t, titleauthor ta
WHERE t.title_id =  ta.title_id
GROUP BY t.title, t.title_id
HAVING COUNT(ta.au_id)=1;

--16
SELECT DISTINCT title FROM titles
WHERE title_id IN (SELECT ta.title_id FROM authors au, titleauthor ta
                   WHERE ta.au_id=au.au_id AND au.state='CA'
                   GROUP BY ta.title_id
                   HAVING COUNT(au.au_id)=1);
