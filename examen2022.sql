-- examen 2022 --
CREATE SCHEMA examen2022;

CREATE TABLE examen2022.articles(
    id_article SERIAL PRIMARY KEY,
    nom_article VARCHAR(50) NOT NULL CHECK (trim(nom_article) <> ''),
    prix INTEGER NOT NULL CHECK ( prix >0 ),
    poids INTEGER NOT NULL CHECK(poids>0),
    quantite_max INTEGER CHECk(quantite_max>0) DEFAULT NULL
);

CREATE TABLE examen2022.commandes(
    id_commande SERIAL PRIMARY KEY,
    nom_client VARCHAR(50) NOT NULL CHECK (trim(nom_client) <> ''),
    date_commande DATE NOT NULL,
    type VARCHAR(50) NOT NULL CHECK(type IN ('livraison', 'à emporter')),
    poids_total INTEGER CHECk(poids_total>0) DEFAULT 0

);

CREATE TABLE examen2022.lignes_de_commande(
    commande INTEGER REFERENCES examen2022.commandes(id_commande),
    article INTEGER REFERENCES examen2022.articles(id_article),
    quantite INTEGER NOT NULL CHECK(quantite>0),
    PRIMARY KEY (commande,article)

);

CREATE OR REPLACE FUNCTION examen2022.ajouter_article_commande(_commande INTEGER, _article INTEGER ) RETURNS INTEGER AS $$
    DECLARE
        toReturn INTEGER;
    BEGIN

        SELECT COUNT(*) INTO toReturn
        FROM (
            SELECT lc.article
            FROM examen2022.lignes_de_commande lc
            GROUP BY lc.article
            HAVING COUNT(DISTINCT lc.commande) >= 2
        ) AS subquery;


        IF EXISTS(SELECT 1 FROM examen2022.lignes_de_commande lc WHERE lc.article=_article AND lc.commande=_commande) THEN
            UPDATE examen2022.lignes_de_commande SET quantite=quantite+1 WHERE article=_article AND commande=_commande;
        ELSE
            INSERT INTO examen2022.lignes_de_commande(commande, article, quantite) VALUES (_commande,_article,1);
        end if;

        RETURN toReturn;

    END;

    $$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION examen2022.tg_bf_ajouter_article_commande() RETURNS TRIGGER AS $$
    DECLARE
        _qte_max INTEGER;
        _qte_article INTEGER;
        _prix_tot INTEGER;
        _prix_article INTEGER;
        _type VARCHAR(50);
    BEGIN
        IF(NOT EXISTS(SELECT * FROM examen2022.lignes_de_commande lc WHERE lc.article=NEW.article AND lc.commande=NEW.commande)) then
            _qte_article=1;
        ELSE
            SELECT lc.quantite INTO _qte_article FROM examen2022.lignes_de_commande lc WHERE lc.article=NEW.article AND lc.commande=NEW.commande;
        end if;

        SELECT a.quantite_max INTO _qte_max FROM examen2022.articles a WHERE a.id_article=NEW.article;

        IF(_qte_article>_qte_max) then
            RAISE 'Attention, la quantité maximale autorisée par article a été dépassée';
        end if;

        SELECT SUM(a.prix*lc.quantite) INTO _prix_tot
        FROM examen2022.lignes_de_commande lc, examen2022.articles a
        WHERE lc.commande=NEW.commande AND lc.article=a.id_article;

        SELECT a.prix INTO _prix_article FROM examen2022.articles a WHERE a.id_article=NEW.article;

        SELECT c.type INTO _type FROM examen2022.commandes c WHERE c.id_commande=NEW.commande;

        IF ( _type='livraison' AND _prix_tot + _prix_article >1000 ) THEN
            RAISE 'Le prix total est beaucoup trop grand';
        end if;

        RETURN NEW;

    end;

    $$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION examen2022.tg_af_ajouter_article_commande() RETURNS TRIGGER AS $$
    DECLARE
        _poids_article INTEGER;
    BEGIN
        SELECT a.poids INTO _poids_article FROM examen2022.articles a WHERE a.id_article=NEW.article;

        UPDATE examen2022.commandes SET poids_total=poids_total+_poids_article WHERE id_commande=NEW.commande;

        RETURN NEW;
    end;
    $$LANGUAGE plpgsql;

CREATE TRIGGER tg_af_ajouter_article_commande AFTER INSERT ON examen2022.lignes_de_commande
FOR EACH ROW EXECUTE PROCEDURE examen2022.tg_af_ajouter_article_commande();

CREATE TRIGGER tg_bf_ajouter_article_commande BEFORE INSERT ON examen2022.lignes_de_commande
FOR EACH ROW EXECUTE PROCEDURE examen2022.tg_bf_ajouter_article_commande();

SELECT examen2022.ajouter_article_commande(1,1);

CREATE OR REPLACE VIEW examen2022.clients_view AS
SELECT c.nom_client, c.id_commande, c.date_commande, COALESCE(SUM(lc.quantite), 0)
FROM examen2022.commandes c
LEFT OUTER JOIN examen2022.lignes_de_commande lc ON lc.commande=c.id_commande
WHERE c.type='livraison'
GROUP BY c.nom_client, c.id_commande, c.date_commande ;

--partie java
/*
 import java.sql.*;
import java.util.Scanner;

public class examen2022 {
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

        System.out.println("nom du client ? ");
        String client = s.nextLine();

        try {
            // Using PreparedStatement to prevent SQL injection
            String query = "SELECT * FROM examen2022.clients_view WHERE nom_client = ?";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, client);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println(rs.getString(1) + " . " + rs.getString(2) + " . " + rs.getDate(3) + " . " + rs.getInt(4));
                }
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }

    }
}

 */


-- Insérer des articles
INSERT INTO examen2022.articles (nom_article, prix, poids, quantite_max) VALUES
('Article 1', 100, 5, 50),
('Article 2', 200, 10, 20),
('Article 3', 300, 15, 30);

-- Insérer des commandes
INSERT INTO examen2022.commandes (nom_client, date_commande, type) VALUES
('Client 1', '2024-12-01', 'livraison'),
('Client 2', '2024-12-02', 'à emporter'),
('Client 3', '2024-12-03', 'livraison');

-- Insérer des lignes de commande
INSERT INTO examen2022.lignes_de_commande (commande, article, quantite) VALUES
(2, 1, 10), -- Article 1, Commande 2
(2, 2, 5), -- Article 2, Commande 2
(3, 2, 1), -- Article 2, Commande 3
(3, 3, 1); -- Article 3, Commande 3

