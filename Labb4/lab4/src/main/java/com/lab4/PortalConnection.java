package com.lab4;
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "Labb 4";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "williamnorland";
    static final String PASSWORD = "Jordgubbar10";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
      Class.forName("org.postgresql.Driver");
      Properties props = new Properties();
      props.setProperty("user", user);
      props.setProperty("password", pwd);
      conn = DriverManager.getConnection(db, props);
    }

    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
      
      String query = "INSERT INTO Registrations VALUES(?,?)";
      
      try (PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, student);
        ps.setString(2, courseCode);
        ps.executeUpdate();
        return "{\"success\":true}";
      } catch (SQLException e) {
        return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }  
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){

      String query = "DELETE FROM Registrations WHERE student='"+student+"' AND course='"+courseCode+"'";

      try (PreparedStatement ps = conn.prepareStatement(query)) {
        //ps.setString(1, student);
        //ps.setString(2, courseCode);
        int affectedRows = ps.executeUpdate();
        if(affectedRows == 0)
          throw new SQLException("No student with idnr "+student+" is registered on course "+courseCode);
        return "{\"success\":true}";
      } catch (SQLException e) {
        return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            """
            SELECT jsonb_build_object(
              'student', BasicInformation.idnr,
              'name', BasicInformation.name,
              'login', BasicInformation.login,
              'program', BasicInformation.program,
              'branch', COALESCE(BasicInformation.branch, 'NULL'),
              'finished', (SELECT jsonb_agg(jsonb_build_object(
                  'course', FinishedCourses.courseName,
                  'code', FinishedCourses.course,
                  'credits', FinishedCourses.credits,
                  'grade', FinishedCourses.grade)
                  ) FROM FinishedCourses WHERE FinishedCourses.student = BasicInformation.idnr),
              'registered', (SELECT jsonb_agg(jsonb_build_object(
                  'code', Registrations.course,
                  'course', Courses.name,
                  'status', Registrations.status,
                  'position', WaitingList.position)
                  ) FROM Registrations
                  JOIN Courses ON Courses.code = Registrations.course
                  LEFT JOIN WaitingList ON WaitingList.student = Registrations.student AND WaitingList.course = Registrations.course
                  WHERE Registrations.student = BasicInformation.idnr),
              'seminarCourses', PathToGraduation.seminarCourses,
              'mathCredits', PathToGraduation.mathCredits,
              'totalCredits', PathToGraduation.totalCredits,
              'canGraduate', PathToGraduation.qualified
            ) 
            AS jsondata 
            FROM BasicInformation
            JOIN PathToGraduation ON idnr = PathToGraduation.student
            WHERE BasicInformation.idnr = ?
            GROUP BY idnr, BasicInformation.name, login, program, branch, seminarCourses, mathCredits, totalCredits, qualified;
            """
            );){
            
            st.setString(1, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}