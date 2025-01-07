-- examen 2024 --

CREATE SCHEMA examen2024;

CREATE TABLE examen2024.formations(
    id_formation SERIAL PRIMARY KEY,
    niveau INTEGER NOT NULL CHECK(niveau BETWEEN 1 AND 5),
    date_formation DATE NOT NULL,
    nbr_max_participants INTEGER NOT NULL CHECK(nbr_max_participants>0),
    inscriptions_clotures BOOLEAN NOT NULL DEFAULT FALSE

);

CREATE TABLE examen2024.participants(
    id_participant SERIAL PRIMARY KEY,
    nom_participant VARCHAR(50) NOT NULL CHECK(trim(nom_participant)<>''),
    prenom_participant VARCHAR(50) NOT NULL CHECK(trim(prenom_participant)<>''),
    nationalite VARCHAR(50) NOT NULL CHECK(trim(nationalite)<>'')

);

CREATE TABLE examen2024.inscriptions(
    participant INTEGER NOT NULL REFERENCES examen2024.participants(id_participant),
    formation INTEGER NOT NULL REFERENCES examen2024.formations(id_formation),
    CONSTRAINT insc_PKEY PRIMARY KEY (participant,formation)
);

CREATE OR REPLACE FUNCTION examen2024.inscription(_id_participant INTEGER,_id_formation INTEGER) RETURNS INTEGER AS $$
    DECLARE
        _niveau INTEGER;
        _return INTEGER;
    BEGIN

        SELECT niveau INTO _niveau FROM examen2024.formations WHERE id_formation=_id_formation;

        SELECT COUNT( i.participant) INTO _return FROM examen2024.inscriptions i, examen2024.formations f
        WHERE i.formation=f.id_formation AND f.niveau=_niveau;

        INSERT INTO examen2024.inscriptions(participant, formation) VALUES (_id_participant,_id_formation);

        RETURN _return+1;
    end;
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION examen2024.tg_bf_inscription() RETURNS TRIGGER AS $$
    DECLARE
        niveauF INTEGER;
        date DATE;
        clotures BOOLEAN;

    BEGIN
        SELECT niveau INTO niveauF FROM examen2024.formations WHERE id_formation=NEW.formation;
        SELECT date_formation INTO date FROM examen2024.formations WHERE id_formation=NEW.formation;
        SELECT inscriptions_clotures INTO clotures FROM examen2024.formations WHERE id_formation=NEW.formation;

        IF (date < current_date )THEN
            RAISE 'la formation est déjà passée';
        end if;

        IF clotures THEN
            RAISE 'inscriptions cloturées';
        end if;

        IF niveauF >= 2 AND
            NOT EXISTS(SELECT 1 FROM examen2024.inscriptions i, examen2024.formations f
                                WHERE i.participant=NEW.participant AND i.formation=f.id_formation AND f.niveau= niveauF-1) THEN
            RAISE 'vous devez suivre la formation du niveau précédent';

        end if;

        RETURN NEW;
    end;
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION examen2024.tg_af_inscription() RETURNS TRIGGER AS $$
    DECLARE
       participants_max INTEGER;
       nb_participants INTEGER;
    BEGIN

        SELECT nbr_max_participants INTO participants_max FROM examen2024.formations WHERE id_formation=NEW.formation;
        SELECT COUNT(DISTINCT participant) INTO nb_participants FROM examen2024.inscriptions WHERE formation=NEW.formation;

        IF nb_participants = participants_max THEN
            UPDATE examen2024.formations SET inscriptions_clotures = TRUE WHERE id_formation=NEW.formation;
        end if;

        RETURN NEW;
    end;
$$LANGUAGE plpgsql;

CREATE TRIGGER tg_af_inscription AFTER INSERT ON examen2024.inscriptions
FOR EACH ROW EXECUTE PROCEDURE examen2024.tg_af_inscription();

CREATE TRIGGER tg_bf_inscription BEFORE INSERT ON examen2024.inscriptions
FOR EACH ROW EXECUTE PROCEDURE examen2024.tg_bf_inscription();

SELECT examen2024.inscription(3,2);

CREATE OR REPLACE VIEW examen2024.part_view AS
SELECT p.nationalite, p.nom_participant, p.prenom_participant, MAX(f.niveau)
FROM examen2024.participants p
LEFT OUTER JOIN examen2024.inscriptions i ON i.participant=p.id_participant
LEFT OUTER JOIN examen2024.formations f ON f.id_formation=i.formation
GROUP BY p.nationalite, p.nom_participant, p.prenom_participant
order by nom_participant, prenom_participant;


--partie java
/*
 import java.sql.*;
import java.util.Scanner;

public class examen2024 {
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
            conn= DriverManager.getConnection(url,"postgres" ,"...");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        System.out.println("nationalité ? ");
        String nat = s.nextLine();

        try {
            String query = "SELECT * FROM examen2024.part_view WHERE nationalite = ?";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, nat);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println(rs.getString(2) + " . " + rs.getString(3) + " . " + rs.getInt(4));
                }
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }

    }
}
 */

INSERT INTO examen2024.participants (nom_participant, prenom_participant, nationalite) VALUES
('Dupont', 'Jean', 'Français'),
('Martin', 'Claire', 'Français'),
('Smith', 'John', 'Anglais'),
('Garcia', 'Maria', 'Espagnole'),
('Lee', 'Min', 'Coréenne');

INSERT INTO examen2024.formations (niveau, date_formation, nbr_max_participants) VALUES
(1, '2025-01-01', 20),
(1, '2025-01-15', 15),
(3, '2025-02-01', 10),
(4, '2024-12-20', 8), -- Formation passée
(5, '2025-03-01', 5);



