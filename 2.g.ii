-----2.g.ii-----

--2
SELECT s.stor_name, SUM(sd.qty * tit.price) AS total_sales
FROM stores s
LEFT OUTER JOIN salesdetail sd ON s.stor_id = sd.stor_id
LEFT OUTER JOIN titles tit ON sd.title_id = tit.title_id
GROUP BY s.stor_name
ORDER BY total_sales DESC;

--4 (faire avec left outer join mais flemme)
SELECT tit.type,tit.title, au.au_fname, tit.price FROM titles tit , titleauthor ta, authors au
WHERE au.au_id = ta.au_id AND ta.title_id = tit.title_id AND tit.price > 20
ORDER BY tit.type;

--6
SELECT au.au_fname, au.au_lname , COUNT(ta.title_id) FROM authors au
LEFT OUTER JOIN titleauthor ta ON au.au_id = ta.au_id
LEFT OUTER JOIN titles tit ON ta.title_id = tit.title_id AND tit.price > 20
GROUP BY au.au_fname, au.au_lname
ORDER BY 3 DESC, au.au_fname, au.au_lname;
