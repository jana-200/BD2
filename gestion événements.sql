-- semaine 6


--1
DROP SCHEMA IF EXISTS gestion_evenements CASCADE;
CREATE SCHEMA gestion_evenements;

CREATE TABLE gestion_evenements.salles(
    id_salle SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL CHECK (trim(nom) <> ''),
    ville VARCHAR(30) NOT NULL CHECK (trim(ville) <> ''),
    capacite INTEGER NOT NULL CHECK (capacite > 0)
);

CREATE TABLE gestion_evenements.festivals (
    id_festival SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL CHECK (trim(nom) <> '')
);

CREATE TABLE gestion_evenements.evenements (
    salle INTEGER NOT NULL REFERENCES gestion_evenements.salles(id_salle),
    date_evenement DATE NOT NULL,
    nom VARCHAR(100) NOT NULL CHECK (trim(nom) <> ''),
    prix MONEY NOT NULL CHECK (prix >= 0 :: MONEY),
    nb_places_restantes INTEGER NOT NULL CHECK (nb_places_restantes >= 0),
    festival INTEGER REFERENCES gestion_evenements.festivals(id_festival),
    PRIMARY KEY (salle,date_evenement)
);

CREATE TABLE gestion_evenements.artistes(
    id_artiste SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL CHECK (trim(nom) <> ''),
    nationalite CHAR(3) NULL CHECK (trim(nationalite) SIMILAR TO '[A-Z]{3}')
);

CREATE TABLE gestion_evenements.concerts(
    artiste INTEGER NOT NULL REFERENCES gestion_evenements.artistes(id_artiste),
    salle INTEGER NOT NULL,
    date_evenement DATE NOT NULL,
    heure_debut TIME NOT NULL,
    PRIMARY KEY(artiste,date_evenement),
    UNIQUE(salle,date_evenement,heure_debut),
    FOREIGN KEY (salle,date_evenement)
    REFERENCES gestion_evenements.evenements(salle,date_evenement)
);

CREATE TABLE gestion_evenements.clients (
    id_client SERIAL PRIMARY KEY,
    nom_utilisateur VARCHAR(25) NOT NULL UNIQUE CHECK (trim(nom_utilisateur) <> '' ),
    email VARCHAR(50) NOT NULL
    CHECK (email SIMILAR TO '%@([[:alnum:]]+[.-])*[[:alnum:]]+.[a-zA-Z]{2,4}' ),
    mot_de_passe CHAR(60) NOT NULL
);

CREATE TABLE gestion_evenements.reservations(
    salle INTEGER NOT NULL,
    date_evenement DATE NOT NULL,
    num_reservation INTEGER NOT NULL, --pas de check car sera géré automatiquement
    nb_tickets INTEGER CHECK (nb_tickets BETWEEN 1 AND 4),
    client INTEGER NOT NULL REFERENCES gestion_evenements.clients(id_client),
    PRIMARY KEY(salle,date_evenement,num_reservation),
    FOREIGN KEY (salle,date_evenement)
    REFERENCES gestion_evenements.evenements(salle,date_evenement)
);




-- semaine 6


--2
--ajouter une salle
CREATE OR REPLACE FUNCTION gestion_evenements.ajouterSalle(_nom VARCHAR, _ville VARCHAR,_capacite INT ) RETURNS INTEGER AS $$
    DECLARE
        id INTEGER;
    BEGIN
        INSERT INTO gestion_evenements.salles(nom, ville, capacite)
        VALUES(_nom,_ville,_capacite)
        RETURNING id_salle INTO id;
        RETURN id;
    END;

$$ LANGUAGE plpgsql;

--test
SELECT gestion_evenements.ajouterSalle('lolo','bruxelles',50);


--ajouter un festival
CREATE OR REPLACE FUNCTION gestion_evenements.ajouterFestival(_nom VARCHAR) RETURNS INTEGER AS $$
    DECLARE
        id INTEGER;
    BEGIN
        INSERT INTO gestion_evenements.festivals(nom)
        VALUES(_nom)
        RETURNING festivals.id_festival INTO id;
        RETURN id;
    END;

$$ LANGUAGE plpgsql;

--test
SELECT gestion_evenements.ajouterFestival('lolo');


--ajouter un artiste
CREATE OR REPLACE FUNCTION gestion_evenements.ajouterArtiste(_nom VARCHAR, _nationalite CHAR) RETURNS INTEGER AS $$
    DECLARE
        id INTEGER;
    BEGIN
        INSERT INTO gestion_evenements.artistes(nom, nationalite)
        VALUES(_nom,_nationalite)
        RETURNING artistes.id_artiste INTO id;
        RETURN id;
    END;

$$ LANGUAGE plpgsql;

--test
SELECT gestion_evenements.ajouterArtiste('lolo','BEL');


--ajouter un client
CREATE OR REPLACE FUNCTION gestion_evenements.ajouterClient(_nom VARCHAR, _email VARCHAR, _mot_de_passe VARCHAR) RETURNS INTEGER AS $$
    DECLARE
        id INTEGER;
    BEGIN
        INSERT INTO gestion_evenements.clients(nom_utilisateur,email,mot_de_passe)
        VALUES(_nom,_email,_mot_de_passe)
        RETURNING clients.id_client INTO id;
        RETURN id;
    END;

$$ LANGUAGE plpgsql;

--test
SELECT gestion_evenements.ajouterClient('lolo','lolo@gmail.com','lolo');




--semaine 7



--3
--ajouter un evenement
CREATE OR REPLACE FUNCTION gestion_evenements.ajouterEvenement(_salle INT, _date_evenement DATE,_nom VARCHAR,_prix MONEY,_festival INTEGER) RETURNS VOID AS $$
    BEGIN
        IF(_date_evenement<=CURRENT_DATE) THEN
            RAISE EXCEPTION 'date pas bonne';
        END IF;

        INSERT INTO gestion_evenements.evenements(salle, date_evenement, nom, prix,nb_places_restantes, festival)
        VALUES(_salle,_date_evenement::DATE,_nom, _prix::MONEY,(SELECT s.capacite FROM gestion_evenements.salles s WHERE s.id_salle=_salle ),_festival);
    END;

$$ LANGUAGE plpgsql;

--test
SELECT gestion_evenements.ajouterEvenement(1,(CURRENT_DATE+1)::DATE,'lolo',50.00::MONEY,1);

--4
--ajouter un concert
CREATE OR REPLACE FUNCTION gestion_evenements.ajouterConcert(_artiste INT, _date_evenement DATE, _heure_debut TIME,_salle INT) RETURNS VOID AS $$
    BEGIN
        IF(_date_evenement<=CURRENT_DATE) THEN
            RAISE EXCEPTION 'date pas bonne';
        END IF;

        IF(EXISTS(SELECT 1 FROM gestion_evenements.concerts c, gestion_evenements.evenements e
                           WHERE c.salle=e.salle AND c.date_evenement=e.date_evenement
                           AND c.artiste=_artiste AND c.date_evenement=_date_evenement
                           AND e.festival IS NOT NULL)) THEN
            RAISE EXCEPTION 'artiste ne peut pas avoir 2 concerts pour le mm festival';
        END IF;

        INSERT INTO gestion_evenements.concerts(artiste, date_evenement, heure_debut, salle)
        VALUES(_artiste,_date_evenement::DATE,_heure_debut,_salle);
    END;

$$ LANGUAGE plpgsql;

--test
SELECT gestion_evenements.ajouterConcert(1,'2024-12-12'::DATE,'20:01'::TIME,1); /*ERROR*/




--semaine 8



--5
--procédure d'ajout d'un événement
CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_evenement(_id_salle INTEGER,_date_evenement DATE, _nom VARCHAR, _prix NUMERIC, _id_festival INTEGER)RETURNS VOID AS $$
    BEGIN
        INSERT INTO gestion_evenements.evenements(salle,date_evenement,nom,prix,festival)
        VALUES(_id_salle,_date_evenement,_nom,_prix::MONEY,_id_festival);
    END
$$LANGUAGE plpgsql;

--trigger s'exécutant avant l'ajout
CREATE OR REPLACE FUNCTION gestion_evenements.tg_bf_ajouter_evenement()RETURNS TRIGGER AS $$
    BEGIN
        IF (NEW.date_evenement <= CURRENT_DATE) THEN
            RAISE EXCEPTION 'La date d''un événement ajouté doit être ultérieure à la date actuelle';
        END IF;

        NEW.nb_places_restantes = (SELECT s.capacite FROM gestion_evenements.salles s WHERE NEW.salle = s.id_salle);
        RETURN NEW;
    END
$$LANGUAGE plpgsql;

CREATE TRIGGER tg_bf_insert_evenement BEFORE INSERT ON gestion_evenements.evenements
FOR EACH ROW EXECUTE PROCEDURE gestion_evenements.tg_bf_ajouter_evenement();


--procédure d'ajout d'un concert
CREATE OR REPLACE FUNCTION gestion_evenements.ajouterConcert(_artiste INT, _date_evenement DATE, _heure_debut TIME,_salle INT) RETURNS VOID AS $$
    BEGIN
        INSERT INTO gestion_evenements.concerts(artiste, date_evenement, heure_debut, salle)
        VALUES(_artiste,_date_evenement::DATE,_heure_debut,_salle);
    END;

$$ LANGUAGE plpgsql;

--trigger
CREATE OR REPLACE FUNCTION gestion_evenements.tg_bf_ajouter_concert()RETURNS TRIGGER AS $$
    BEGIN
        IF(NEW.date_evenement<=CURRENT_DATE) THEN
            RAISE EXCEPTION 'date pas bonne';
        END IF;

        IF(EXISTS(SELECT 1 FROM gestion_evenements.concerts c, gestion_evenements.evenements e
                           WHERE c.salle=e.salle AND c.date_evenement=e.date_evenement
                           AND c.artiste=NEW.artiste AND c.date_evenement=NEW.date_evenement
                           AND e.festival IS NOT NULL)) THEN
            RAISE EXCEPTION 'artiste ne peut pas avoir 2 concerts pour le mm festival';
        END IF;

        RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_bf_ajouter_concert BEFORE INSERT ON gestion_evenements.concerts
FOR EACH ROW EXECUTE PROCEDURE gestion_evenements.tg_bf_ajouter_concert();


--procédure d'ajout d'une réservation
CREATE OR REPLACE FUNCTION gestion_evenements.ajouter_reservation(_salle INTEGER, _date_evenement DATE,_nb_tickets INTEGER, _client INTEGER) RETURNS INTEGER AS $$
    DECLARE
        _num_reservation INTEGER;
    BEGIN
        INSERT INTO gestion_evenements.reservations(salle, date_evenement, nb_tickets, client)
        VALUES(_salle,_date_evenement,_nb_tickets,_client)
        RETURNING reservations.num_reservation INTO _num_reservation;

        RETURN _num_reservation;
    END;

$$ LANGUAGE plpgsql;

--trigger
CREATE OR REPLACE FUNCTION gestion_evenements.tg_bf_ajouter_reservation() RETURNS TRIGGER AS $$
    BEGIN

        IF(NEW.date_evenement<=CURRENT_DATE) THEN
            RAISE EXCEPTION 'date pas bonne';
        END IF;

        IF(NOT EXISTS (SELECT 1 FROM gestion_evenements.concerts
                       WHERE salle = NEW.salle AND date_evenement = NEW.date_evenement)) THEN
            RAISE EXCEPTION 'le concert ne peut être null';
        END IF;

        IF(NEW.nb_tickets>4)THEN
            RAISE EXCEPTION 'nbr de tickets doit être entre 1 et 4';
        END IF;

        IF EXISTS(SELECT 1 FROM gestion_evenements.reservations r, gestion_evenements.evenements e
                           WHERE e.salle=r.salle AND e.date_evenement=r.date_evenement
                           AND r.client=NEW.client AND r.date_evenement=NEW.date_evenement
                           AND (r.salle <> NEW.salle OR r.date_evenement <> NEW.date_evenement)) THEN
            RAISE EXCEPTION 'le client a déjà une réservation pour un autre événement à la même date';
        END IF;

        UPDATE gestion_evenements.evenements
        SET nb_places_restantes = nb_places_restantes - NEW.nb_tickets
        WHERE salle = NEW.salle AND date_evenement = NEW.date_evenement;

        -- initialisation du numéro de réservation
        SELECT COUNT(*) + 1
        FROM gestion_evenements.reservations r
        WHERE r.date_evenement = NEW.date_evenement
        AND r.salle = NEW.salle
        INTO NEW.num_reservation;

        RETURN NEW;

    END

$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_bf_ajouter_reservation BEFORE INSERT ON gestion_evenements.reservations
FOR EACH ROW EXECUTE PROCEDURE gestion_evenements.tg_bf_ajouter_reservation();
--test
SELECT gestion_evenements.ajouter_reservation(1, '2024-12-12', 2, 1);



--semaine 9



--6
--procédure de réservation de x places pr tous les events d'un festival
CREATE OR REPLACE FUNCTION gestion_evenements.reserver_festival(_id_festival INTEGER, _id_client INTEGER, _nb_places INTEGER) RETURNS VOID AS $$
    DECLARE
        _evenement RECORD;
    BEGIN
        FOR _evenement IN
            SELECT e.date_evenement, e.salle FROM gestion_evenements.evenements e
            WHERE e.festival=_id_festival
        LOOP
            PERFORM gestion_evenements.ajouter_reservation(_evenement.salle,_evenement.date_evenement, _nb_places,_id_client);
        END LOOP;
    END
$$ LANGUAGE plpgsql;

--7
--view: afficher les festivals futurs
CREATE OR REPLACE VIEW gestion_evenements.festival_view AS
SELECT f.nom, MIN(e.date_evenement) as "first_event", MAX(e.date_evenement) as "last_event",SUM(e.prix) as "prix_total"
FROM gestion_evenements.festivals f , gestion_evenements.evenements e
WHERE f.id_festival=e.festival
GROUP BY f.nom
HAVING MIN(e.date_evenement) >= CURRENT_DATE
ORDER BY 3;

--test
SELECT * FROM gestion_evenements.festival_view;

--view: afficher les réservation
CREATE OR REPLACE VIEW gestion_evenements.reservations_view AS
SELECT ev.nom, res.date_evenement, res.salle, res.num_reservation, res.nb_tickets, res.client
FROM gestion_evenements.reservations res, gestion_evenements.evenements ev
WHERE ev.salle=res.salle AND res.date_evenement=ev.date_evenement
ORDER BY res.date_evenement;

--test
SELECT * FROM gestion_evenements.reservations_view WHERE client=1;




--semaine 10



--8
--view: afficher les événements d'une salle
CREATE OR REPLACE VIEW gestion_evenements.evenements_view AS
SELECT e.nom AS "nom_event", e.date_evenement AS "date_event", e.salle AS "id_salle_event",
        STRING_AGG(a.nom, '+') AS "artistes",
       e.prix, e.nb_places_restantes = 0 AS "complet"
FROM gestion_evenements.evenements e
    LEFT JOIN gestion_evenements.concerts co ON e.date_evenement = co.date_evenement AND e.salle = co.salle
    LEFT JOIN gestion_evenements.artistes a ON a.id_artiste = co.artiste
GROUP BY e.nom, e.date_evenement, e.salle, e.prix, e.nb_places_restantes;

SELECT *
FROM gestion_evenements.evenements_view
WHERE id_salle_event = 1;


--9
--view: afficher les événements d'un artiste
CREATE OR REPLACE VIEW gestion_evenements.afficher_events_artiste AS
SELECT ev.nom, ev.date_evenement,ev.salle, STRING_AGG(ar.nom,'+') AS "artistes", ev.prix, ev.nb_places_restantes=0, ar.id_artiste
FROM gestion_evenements.evenements ev
    LEFT JOIN gestion_evenements.concerts c ON ev.salle=c.salle AND ev.date_evenement=c.date_evenement
    LEFT JOIN gestion_evenements.artistes ar ON ar.id_artiste=c.artiste
GROUP BY ev.nom, ev.date_evenement, ev.salle, ev.prix, ev.nb_places_restantes=0,ar.id_artiste
ORDER BY ev.date_evenement;

SELECT *
FROM gestion_evenements.afficher_events_artiste
WHERE id_artiste=1;
