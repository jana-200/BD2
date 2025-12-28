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
                    conn= DriverManager.getConnection(url,"postgres" ,"Itachi2004");
                } catch (SQLException e) {
                    System.out.println("Impossible de joindre le server !");
                    System.exit(1);
                }

                System.out.println("nationnalité ? ");
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
