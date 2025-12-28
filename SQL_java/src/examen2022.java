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
                    System.out.println(rs.getString(2) + " . " + rs.getDate(3) + " . " + rs.getInt(4));
                }
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }

    }
}
