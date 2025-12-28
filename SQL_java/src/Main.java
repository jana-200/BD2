import java.sql.*;

public class Main {
    public static void main(String[] args) {

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

        try {
            Statement s = conn.createStatement();
            try(ResultSet rs= s.executeQuery("SELECT * "+"FROM gestion_evenements.festival_view;"))
            {
                while(rs.next()) {
                    System.out.println("nom du festival : "+rs.getString(1));
                }
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }



    }
}