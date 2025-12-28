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
            conn= DriverManager.getConnection(url,"postgres","Itachi2004");
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
