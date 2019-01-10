CREATE TABLE ANIME (
  a_id INTEGER,
  a_name VARCHAR2(50),
  PRIMARY KEY(a_id)
);

CREATE TABLE MANGA (
  m_id INTEGER,
  m_name VARCHAR2(50),
  PRIMARY KEY(m_id)
);

CREATE TABLE ANIME_SCORE(
  score_id INTEGER,
  a_id INTEGER,
  score INTEGER,
  PRIMARY KEY(score_id),
  FOREIGN KEY(a_id) REFERENCES Anime(a_id)
);

CREATE TABLE MANGA_SCORE(
score_id INTEGER,
m_id INTEGER,
score INTEGER,
PRIMARY KEY(score_id),
FOREIGN KEY(m_id) REFERENCES MANGA(m_id)
);

ALTER TABLE ANIME
ADD (
  m_id INTEGER,
  FOREIGN KEY (m_id) REFERENCES MANGA(m_id)
);

ALTER TABLE ANIME
  ADD UNIQUE (a_name);
  
ALTER TABLE MANGA
  ADD UNIQUE (m_name);

--Creating Sequences

CREATE SEQUENCE a_seq
  START WITH 1
  INCREMENT BY 1;

CREATE SEQUENCE m_seq
  START WITH 1
  INCREMENT BY 1;
  
CREATE SEQUENCE a_score_seq
  START WITH 1
  INCREMENT BY 1;

CREATE SEQUENCE m_score_seq
  START WITH 1
  INCREMENT BY 1;

--Creating Triggers

CREATE OR REPLACE TRIGGER a_seq_trigger
  BEFORE INSERT ON ANIME
  FOR EACH ROW
  BEGIN
    SELECT a_seq.nextval INTO :new.a_id FROM DUAL;
  END;
  
CREATE OR REPLACE TRIGGER m_seq_trigger
  BEFORE INSERT ON MANGA
  FOR EACH ROW
  BEGIN
    SELECT m_seq.nextval INTO :new.m_id FROM DUAL;
  END;

CREATE OR REPLACE TRIGGER a_score_trigger
  BEFORE INSERT ON ANIME_SCORE
  FOR EACH ROW
  BEGIN
    SELECT a_score_seq.nextval INTO  :new.score_id FROM DUAL;
  END;

CREATE OR REPLACE TRIGGER m_score_trigger
  BEFORE INSERT ON MANGA_SCORE
  FOR EACH ROW
  BEGIN
    SELECT m_score_seq.nextval into :new.score_id FROM DUAL;
  END;

INSERT INTO ANIME (A_NAME) VALUES('Kyoukai no Rinne');

INSERT INTO MANGA (M_NAME) VALUES('Kyoukai no Rinne');

UPDATE ANIME SET M_ID = 1 WHERE A_NAME = 'Kyoukai no Rinne';


SELECT an.a_id, ma.m_id, an.a_name as ANIME_NAME, ma.m_name as MANGA_NAME   
FROM ANIME an
LEFT JOIN MANGA ma ON an.M_ID = ma.M_ID;

--Writing Functions
CREATE OR REPLACE FUNCTION get_max_id_anime
RETURN INTEGER
IS
max_id INTEGER;
BEGIN
SELECT MAX(A_ID) INTO MAX_ID FROM ANIME;
RETURN MAX_ID;
END;
/

--Helpful procedures

CREATE OR REPLACE PROCEDURE insert_anime(anime_name in ANIME.A_NAME%TYPE)
IS
BEGIN
  INSERT INTO ANIME(a_name) VALUES(anime_name);
  DBMS_OUTPUT.PUT_LINE('Inserted new anime: ' || anime_name);
  commit;
END;
/

CREATE OR REPLACE PROCEDURE insert_manga(manga_name IN MANGA.M_NAME%TYPE)
IS
BEGIN
  INSERT INTO MANGA(m_name) VALUES(manga_name);
  DBMS_OUTPUT.PUT_LINE('Inserted Manga: ' || manga_name);
  commit;
END;
/

CREATE OR REPLACE PROCEDURE update_anime_with_manga(manga_id in INTEGER, anime_name IN VARCHAR2)
IS
BEGIN
  UPDATE ANIME set m_id = manga_id where a_name = anime_name;
  DBMS_OUTPUT.PUT_LINE('Updated Anime: ' || anime_name);
  commit;
END;
/

CREATE OR REPLACE PROCEDURE insert_anime_score(score_value in INTEGER, anime_name in VARCHAR2)
  IS 
  anime_id INTEGER;
  BEGIN
    SELECT a_id INTO anime_id FROM ANIME WHERE a_name = anime_name;
    INSERT INTO ANIME_SCORE(score, a_id) VALUES (score_value, anime_id);
    DBMS_OUTPUT.PUT_LINE('ANIME: ' || anime_name || ' with the id: ' || anime_id
    || ' has been updated');
  END;
/

CREATE OR REPLACE PROCEDURE insert_manga_score(score_value in INTEGER, manga_name in VARCHAR2)
  IS
  manga_id INTEGER;
  BEGIN
    SELECT m_id INTO manga_id FROM MANGA WHERE m_name = manga_name;
    INSERT INTO MANGA_SCORE(m_id, score) VALUES(manga_id, score_value);
    DBMS_OUTPUT.PUT_LINE('MANGA: ' || manga_name || ' with the id: ' || manga_id
    || ' has been updated');
  END;
  /
  


CREATE OR REPLACE PROCEDURE get_all_anime(cursorParam out SYS_REFCURSOR)
IS
BEGIN
  Open cursorParam for
  Select * from Anime;
END;
/

DECLARE
  animeCursor SYS_REFCURSOR;
  animeId ANIME.A_ID%TYPE;
  animeName ANIME.A_NAME%TYPE;
  mangaId ANIME.M_ID%TYPE;
BEGIN
  get_all_anime(animeCursor);
  
  LOOP
    fetch animeCursor into animeId, animeName, mangaId;
    EXIT WHEN animeCursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(animeId || ' ' || animeName || ' ' || mangaId);
  END LOOP;
  
  CLOSE animeCursor;
END;
/
  
  

BEGIN

  insert_anime('Sword Art Online');
  
END;
/

Begin
  INSERT_MANGA('Sword Art Online');
END;
/

Begin
  UPDATE_ANIME_WITH_MANGA(3, 'Sword Art Online');
END;
/

BEGIN
  insert_anime_score(8, 'Sword Art Online');
END;
/

BEGIN
  insert_manga_score(9, 'Sword Art Online');
END;
/

select * from anime;
select * from anime_score;
select * from MANGA_SCORE;

--GET MAXID FROM ANIME
DECLARE 
max_id INTEGER;
BEGIN
  max_id := GET_MAX_ID_ANIME();
  DBMS_OUTPUT.PUT_LINE('MAX ID: ' || MAX_ID);
END;

--Get all anime w/o a reference to a manga
Select * from anime where M_ID is null;

--Cross Join
Select * 
from anime
cross join manga;

--Order By
Select * 
From Anime
WHERE ROWNUM <= 2
ORDER BY A_NAME DESC;

--Nested Query WITH ROWNUM
Select * 
FROM ANIME
WHERE ROWNUM <= 2 AND
M_ID = (SELECT M_ID FROM MANGA WHERE M_NAME = 'Sword Art Online');

--Using Group by and Having with aggregate func.
Select Count(m_id) as MANGA_REFERENCES, a_name 
from Anime
Group by a_name
Having Count(m_id) > 0
order by a_name desc;

--Using Exists
Select * 
from Anime
Where EXISTS (Select m_name from MANGA where m_id = 1);

--Inner JOIN
SELECT an.a_name as ANIME_NAME, AVG(ascore.score) as ANIME_SCORE, ma.m_name as 
MANGA_NAME, AVG(ms.score) as MANGA_SCORE
FROM ANIME an
INNER JOIN ANIME_SCORE ascore ON an.A_ID = ascore.A_ID
INNER JOIN MANGA ma ON an.M_ID = ma.M_ID
INNER JOIN MANGA_SCORE ms ON an.M_ID = ms.M_ID
GROUP BY an.a_name, ma.m_name
ORDER BY an.A_NAME;

--Using LIKE
Select * from Anime 
where a_name like '%oo%';

Select a_name, COUNT(A_NAME) from Anime group by a_name
UNION ALL
SELECT m_name, COUNT(M_NAME) from Manga GROUP BY M_NAME
ORDER BY a_name;







