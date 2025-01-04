-----2.b.iv-----
--1
SELECT tit.title,tit.price, pub.pub_name FROM publishers pub, titles tit
WHERE tit.pub_id=pub.pub_id;

--2
SELECT tit.title,tit.price, pub.pub_name FROM publishers pub, titles tit
WHERE tit.pub_id=pub.pub_id AND tit.type='psychology';

--3
SELECT DISTINCT au.au_lname,au.au_fname FROM titleauthor titau, authors au
WHERE au.au_id = titau.au_id;

--4
SELECT DISTINCT au.state FROM titleauthor titau, authors au
WHERE au.au_id = titau.au_id;

--5
SELECT DISTINCT sto.stor_name, sto.stor_address FROM stores sto, sales sal
WHERE sto.stor_id=sal.stor_id AND date_part('year',sal.date)=1991 AND date_part('month',sal.date)=11;

--6
SELECT tit.title FROM publishers pub, titles tit
WHERE pub.pub_id=tit.pub_id AND tit.type='psychology' AND tit.price<20 AND pub.pub_name NOT LIKE 'Algo%';

--7
SELECT DISTINCT tit.title FROM authors au, titleauthor titau, titles tit
WHERE au.au_id=titau.au_id AND titau.title_id=tit.title_id AND au.state='CA';

--8
SELECT au.au_fname FROM authors au, publishers pub, titleauthor titau , titles tit
WHERE au.au_id=titau.au_id AND titau.title_id=tit.title_id AND tit.pub_id=pub.pub_id
AND pub.state='CA';

--9
SELECT au.au_fname FROM authors au, publishers pub, titleauthor titau , titles tit
WHERE au.au_id=titau.au_id AND titau.title_id=tit.title_id AND tit.pub_id=pub.pub_id
AND pub.state=au.state;

--10
SELECT DISTINCT pub.* FROM publishers pub, titles tit, salesdetail sd, sales sa
WHERE pub.pub_id=tit.pub_id AND tit.title_id=sd.title_id AND sd.stor_id=sa.stor_id AND sd.ord_num=sa.ord_num
AND sa.date BETWEEN'01-11-1990' AND '01-03-1991';

--11
SELECT DISTINCT st.stor_name FROM stores st, salesdetail sd, titles tit
WHERE tit.title_id= sd.title_id AND sd.stor_id=st.stor_id
AND LOWER(tit.title) LIKE '%cook%';

--12
SELECT DISTINCT t1.title ,t2.title FROM titles t1, titles t2
WHERE t1.pub_id=t2.pub_id AND t1.pubdate=t2.pubdate AND t1.title_id < t2.title_id;

--13
SELECT au.* FROM authors au
WHERE 1< (SELECT COUNT(DISTINCT pub_id) FROM titles tit, titleauthor ta WHERE tit.title_id=ta.title_id and ta.au_id=au.au_id);

--14
SELECT tit.title FROM titles tit, salesdetail sd, sales s
WHERE tit.title_id=sd.title_id AND sd.stor_id=s.stor_id AND sd.ord_num=s.ord_num AND s.date<tit.pubdate;

--15
SELECT DISTINCT st.stor_name FROM authors au ,titleauthor titau, salesdetail sd, stores st
WHERE au.au_id=titau.au_id  AND titau.title_id= sd.title_id AND sd.stor_id=st.stor_id AND au.au_fname ='Anne' AND au.au_lname ='Ringer';

--16
SELECT DISTINCT au.state FROM authors au, titleauthor titau, salesdetail sd, sales s, stores st
WHERE au.au_id = titau.au_id AND titau.title_id=sd.title_id AND sd.stor_id= s.stor_id AND s.stor_id=st.stor_id AND sd.ord_num= s.ord_num
AND s.date BETWEEN '01-02-1991' AND  '28-02-1991' AND st.state='CA';

--17
SELECT DISTINCT st1.stor_name, st2.stor_name FROM stores st1, stores st2, salesdetail sd1, salesdetail sd2, titleauthor ta1, titleauthor ta2
WHERE st1.stor_id = sd1.stor_id AND st2.stor_id = sd2.stor_id AND ta1.title_id = sd1.title_id AND ta2.title_id = sd2.title_id
AND st1.state = st2.state AND st1.stor_name < st2.stor_name AND ta1.au_id = ta2.au_id;

--18
SELECT DISTINCT a1.au_lname, a2.au_lname FROM authors a1, authors a2, titleauthor ta1, titleauthor ta2
WHERE a1.au_id = ta1.au_id AND a2.au_id = ta2.au_id AND a1.au_id < a2.au_id AND ta1.title_id = ta2.title_id;
