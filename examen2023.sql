-- examen 2023 --
CREATE SCHEMA examen2023;

CREATE TABLE examen2023.examens(
    id_examen SERIAL PRIMARY KEY,
    code_unique VARCHAR(8) NOT NULL CHECK (code_unique SIMILAR TO 'BINV[0-9][0-9][0-9][0-9]') UNIQUE,
    nom_examen VARCHAR(50) NOT NULL CHECK(trim(nom_examen) <>''),
    date_examen DATE NOT NULL,
    bloc INTEGER NOT NULL CHECK(bloc IN (1,2,3)),
    nbr_inscrits INTEGER NOT NULL CHECK(nbr_inscrits>0),
    complet BOOLEAN NOT NULL DEFAULT FALSE,
    sur_machine BOOLEAN NOT NULL
);

CREATE TABLE examen2023.locaux(
    id_local SERIAL PRIMARY KEY,
    nom_local VARCHAR(50) NOT NULL CHECK(trim(nom_local) <> '') UNIQUE,
    nbr_places INTEGER NOT NULL CHECK(nbr_places>0),
    presence_machine BOOLEAN NOT NULL
);

CREATE TABLE examen2023.reservations(
    examen INTEGER NOT NULL REFERENCES examen2023.examens(id_examen),
    local INTEGER NOT NULL REFERENCES examen2023.locaux(id_local),
    CONSTRAINT res_PKEY PRIMARY KEY (examen,local)
);


-- procédure ajoute réservation
CREATE OR REPLACE FUNCTION examen2023.reservation(_nom_local VARCHAR(50), _code_examen VARCHAR(8)) RETURNS INTEGER AS $$
    DECLARE
        id_exam INTEGER;
        id_local INTEGER;
        nb_exams INTEGER;

    BEGIN
        SELECT l.id_local INTO id_local FROM examen2023.locaux l WHERE l.nom_local=_nom_local;
        SELECT e.id_examen INTO id_exam FROM examen2023.examens e WHERE e.code_unique=_code_examen;

        INSERT INTO examen2023.reservations(examen, local) VALUES (id_exam,id_local);

        SELECT COUNT(DISTINCT r.examen) INTO nb_exams FROM examen2023.reservations r , examen2023.examens e
        WHERE r.examen=e.id_examen AND e.complet = TRUE AND r.local=id_local;

        RETURN nb_exams;
    END;

    $$LANGUAGE plpgsql;

-- trigger
CREATE OR REPLACE FUNCTION examen2023.tg_bf_reservation() RETURNS TRIGGER AS $$
    DECLARE
        _sur_machine BOOLEAN;
        _presence_machines BOOLEAN;
        _complet BOOLEAN;
        _date_exam DATE;

    BEGIN
        SELECT e.sur_machine INTO _sur_machine FROM examen2023.examens e WHERE e.id_examen=NEW.examen;
        SELECT e.complet INTO _complet FROM examen2023.examens e WHERE e.id_examen=NEW.examen;
        SELECT e.date_examen INTO _date_exam FROM examen2023.examens e WHERE e.id_examen=NEW.examen;


        IF _sur_machine THEN
            SELECT l.presence_machine INTO _presence_machines FROM examen2023.locaux l WHERE l.id_local=NEW.local;
            IF _presence_machines=FALSE THEN
                RAISE 'cet examen doit avoir lieu dans une salle machine';
            END IF;
        END IF;

        IF _complet THEN
            RAISE 'cet examen est completement reservé';
        END IF;

        IF EXISTS(SELECT 1
                  FROM examen2023.reservations r, examen2023.examens e
                  WHERE r.examen=e.id_examen AND e.id_examen<>NEW.examen
                  AND e.date_examen=_date_exam AND r.local=NEW.local) THEN
            RAISE 'il ya déjà un autre examen à ce local le même jour';
        END IF;

        RETURN NEW;

    END;

    $$LANGUAGE plpgsql;


CREATE TRIGGER tg_bf_reservation BEFORE INSERT ON examen2023.reservations
FOR EACH ROW EXECUTE PROCEDURE examen2023.tg_bf_reservation();

CREATE OR REPLACE FUNCTION examen2023.tg_af_reservation() RETURNS TRIGGER AS $$
    DECLARE
        _nbr_places INTEGER;
        _nbr_inscrits INTEGER;
    BEGIN
        SELECT SUM(l.nbr_places) INTO _nbr_places FROM examen2023.reservations r, examen2023.locaux l
        WHERE r.local=l.id_local AND r.examen=NEW.examen;

        SELECT e.nbr_inscrits INTO _nbr_inscrits FROM examen2023.examens e WHERE e.id_examen=NEW.examen;

        IF _nbr_inscrits <= _nbr_places THEN
            UPDATE examen2023.examens SET complet=TRUE WHERE id_examen=NEW.examen;
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER tg_af_reservation AFTER INSERT ON examen2023.reservations
FOR EACH ROW EXECUTE PROCEDURE examen2023.tg_af_reservation();

SELECT examen2023.reservation('Salle B','BINV1001');
SELECT examen2023.reservation('Salle A','BINV1001');

CREATE OR REPLACE VIEW examen2023.exams_view AS
SELECT e.bloc , e.nom_examen, e.date_examen, COUNT(r.local)
FROM examen2023.examens e
    LEFT OUTER JOIN examen2023.reservations r on e.id_examen = r.examen
GROUP BY e.bloc, e.nom_examen, e.date_examen
ORDER BY e.date_examen;


--partie java 
/*
import java.sql.*;
import java.util.Scanner;

public class examens2023 {
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
            conn= DriverManager.getConnection(url,"postgres" ,".");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        System.out.println("quel bloc");
        int bloc = Integer.parseInt(s.nextLine());

        try {
            Statement st = conn.createStatement();
            try(ResultSet rs= st.executeQuery(" SELECT * FROM examen2023.exams_view WHERE bloc = '"+bloc+"' ;")){
                while(rs.next()) {
                    System.out.println(rs.getString(2)+ " . " +rs.getString(3)+ " . " +rs.getString(4));

                }
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }

    }
}*/
--

INSERT INTO examen2023.locaux (nom_local, nbr_places, presence_machine) VALUES
('Salle A', 30, FALSE),
('Salle B', 40, TRUE),
('Salle C', 50, FALSE),
('Salle D', 25, TRUE);

-- Examens
INSERT INTO examen2023.examens (code_unique, nom_examen, bloc, date_examen, nbr_inscrits, complet, sur_machine) VALUES
('BINV1001', 'Mathématiques Bloc 1', 1, '2025-01-15', 25, FALSE, FALSE),
('BINV2002', 'Informatique Bloc 2', 2, '2025-01-15', 40, FALSE, TRUE),
('BINV3003', 'Algorithmique Bloc 3', 3, '2025-01-16', 30, TRUE, TRUE),
('BINV4004', 'Physique Bloc 2', 2, '2025-01-16', 50, FALSE, FALSE);


