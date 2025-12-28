-- exmane 2019 --
CREATE SCHEMA examen2019;

CREATE TABLE examen2019.concerts(
    id_concert SERIAL PRIMARY KEY,
    date_concert DATE NOT NULL,
    artiste VARCHAR(50) NOT NULL,
    salle VARCHAR(50) NOT NULL,
    nbr_tickets INTEGER NOT NULL CHECK (nbr_tickets > 0), --tickets en vente
    est_complet BOOLEAN DEFAULT FALSE

);

CREATE TABLE examen2019.clients(
    id_client SERIAL PRIMARY KEY,
    nom varchar(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    sexe CHAR(1) NOT NULL CHECK (sexe IN ('F','M'))

);

CREATE TABLE examen2019.reservations(
    concert INTEGER NOT NULL REFERENCES examen2019.concerts(id_concert),
    client INTEGER NOT NULL REFERENCES examen2019.clients(id_client),
    num_reservation INTEGER NOT NULL,
    tickets_reserves INTEGER CHECK (tickets_reserves BETWEEN 1 AND 4),
    PRIMARY KEY(concert,num_reservation)

);

--reserver tickets pour un concert

CREATE OR REPLACE FUNCTION examen2019.reserver_tickets(_client INTEGER,_concert INTEGER,_nbr_tickets INTEGER) RETURNS BOOLEAN AS $$
    DECLARE
        toReturn BOOLEAN;
        num_res INTEGER;
    BEGIN

        SELECT est_complet INTO toReturn
        FROM examen2019.concerts
        WHERE id_concert=_concert;

        num_res=(SELECT COUNT(concert) FROM examen2019.reservations WHERE concert=_concert);


        INSERT INTO examen2019.reservations(concert, client, num_reservation,tickets_reserves)
        VALUES(_concert, _client,num_res+1,_nbr_tickets);

        RETURN toReturn;
    END;

    $$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION examen2019.tg_bf_reserver_tickets() RETURNS TRIGGER AS $$
    DECLARE
        date DATE;
        tickets_res INTEGER;
        tickets_dipso INTEGER;
        tickets_client INTEGER;
    BEGIN
        SELECT c.date_concert, c.nbr_tickets INTO date, tickets_dipso FROM examen2019.concerts c WHERE NEW.concert=c.id_concert;
        SELECT SUM(r.tickets_reserves) INTO tickets_res FROM examen2019.reservations r WHERE r.concert= NEW.concert ;
        SELECT SUM(r.tickets_reserves) INTO tickets_client FROM examen2019.reservations r WHERE r.concert= NEW.concert AND r.client=NEW.client;


        IF EXISTS(SELECT 1 FROM examen2019.reservations r, examen2019.concerts c
                           WHERE r.client=NEW.client AND r.concert=c.id_concert
                           AND c.date_concert=date AND r.concert <> NEW.concert)THEN
            RAISE 'il ya déjà une reservation pour un autre concert à cette date';
        end if;

        IF tickets_res + NEW.tickets_reserves >tickets_dipso THEN
            RAISE 'il n ya  plus assez de tickets';
        end if;

        IF tickets_client+NEW.tickets_reserves >4 THEN
            RAISE 'vous avez prit plus de 4 tickets au total';
        end if;

        RETURN NEW;
    END;
    $$LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION examen2019.tg_af_reserver_tickets() RETURNS TRIGGER AS $$
    DECLARE
        tickets_res INTEGER;
        tickets_dipso INTEGER;
    BEGIN

        SELECT c.nbr_tickets INTO tickets_dipso FROM examen2019.concerts c WHERE NEW.concert=c.id_concert;
        SELECT SUM(r.tickets_reserves) INTO tickets_res FROM examen2019.reservations r WHERE r.concert= NEW.concert ;

        IF tickets_res=tickets_dipso THEN
            UPDATE examen2019.concerts SET est_complet=TRUE WHERE id_concert=NEW.concert;
        end if;

        RETURN NEW;
    END;
    $$LANGUAGE plpgsql;

CREATE TRIGGER tg_bf_reserver_tickets BEFORE INSERT ON examen2019.reservations
FOR EACH ROW EXECUTE PROCEDURE examen2019.tg_bf_reserver_tickets();

CREATE TRIGGER tg_af_reserver_tickets BEFORE INSERT ON examen2019.reservations
FOR EACH ROW EXECUTE PROCEDURE examen2019.tg_af_reserver_tickets();

SELECT examen2019.reserver_tickets(1,1,2);


CREATE OR REPLACE VIEW examen2019.concert_artiste_view AS
SELECT c.artiste, c.date_concert, c.salle , COALESCE(SUM(r.tickets_reserves),0)
FROM examen2019.concerts c
LEFT OUTER JOIN examen2019.reservations r ON c.id_concert = r.concert
GROUP BY c.artiste, c.date_concert, c.salle;

--partie java
/*
 import java.sql.*;
import java.util.Scanner;

public class examen2019 {
    public static void main(String[] args) {

        Scanner s = new Scanner(System.in);

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url="jdbc:postgresql://localhost:5432/postgres";
        Connection conn=null;
        try {
            conn= DriverManager.getConnection(url,"postgres","...");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        System.out.println("artiste : ");
        String artiste = s.nextLine();

        try {
            String requete="SELECT * FROM examen2019.concert_artiste_view WHERE artiste=?";
            PreparedStatement ps = conn.prepareStatement(requete);
            ps.setString(1,artiste);

            try(ResultSet rs=ps.executeQuery()){
                while(rs.next()){
                    System.out.println(rs.getDate(2)+" . "+rs.getString(3)+" . "+rs.getInt(4));
                }

            }
        } catch (SQLException se) {
            System.out.println("Erreur lors de l’insertion !");
            se.printStackTrace();
            System.exit(1);
        }
    }
}

 */



-- Insertions pr tester
INSERT INTO examen2019.concerts (date_concert, artiste, salle, nbr_tickets)
VALUES
    ('2025-02-15', 'The Rolling Stones', 'Stade de France', 1000),
    ('2025-02-20', 'Coldplay', 'Accor Arena', 500),
    ('2025-03-01', 'Adele', 'Le Zénith', 300);

INSERT INTO examen2019.clients (nom, prenom, sexe)
VALUES
    ('Dupont', 'Marie', 'F'),
    ('Martin', 'Jean', 'M'),
    ('Lemoine', 'Sophie', 'F'),
    ('Dufresne', 'Pierre', 'M');

INSERT INTO examen2019.reservations (concert, client, num_reservation, tickets_reserves)
VALUES
    (1, 1, 1, 2),
    (2, 2, 1, 4),
    (2, 2, 2, 3);
