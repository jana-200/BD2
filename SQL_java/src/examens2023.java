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
            conn= DriverManager.getConnection(url,"postgres" ,"...");
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
}
