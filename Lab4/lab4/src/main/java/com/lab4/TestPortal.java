package com.lab4;

public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();
   
         // TO RESET THE DATABASE
         // psql -U williamnorland "Labb 4"
         // \i Labb4/lab4/resources/resetState.sql


         // Write your tests here. Add/remove calls to pause() as desired. 
         // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)
         
         prettyPrint(c.getInfo("2222222222")); 
         pause();

         // Should work
         System.out.println(c.register("2222222222", "CCC111")); 
         pause();

         prettyPrint(c.getInfo("2222222222")); 
         pause();

         // Should give error already registered
         System.out.println(c.register("2222222222", "CCC111")); 
         pause();

         // Should work
         System.out.println(c.unregister("2222222222", "CCC111"));
         pause();

         prettyPrint(c.getInfo("2222222222"));
         pause();

         // Should give error already unregistered
         System.out.println(c.unregister("2222222222", "CCC111")); 
         pause();

         // Should give error does not have prerequisites
         System.out.println(c.register("2222222222", "CCC444"));
         pause();

         // Should work check that 2222222222 is registered
         System.out.println(c.register("2222222222", "CCC333"));
         System.out.println(c.register("1111111111", "CCC333"));
         System.out.println(c.register("3333333333", "CCC333"));
         prettyPrint(c.getInfo("2222222222"));
         pause();         

         // Should work check that 2222222222 is unregistered
         System.out.println(c.unregister("2222222222", "CCC333"));
         prettyPrint(c.getInfo("2222222222"));
         pause();

         // Should work check that 1111111111 is registered
         prettyPrint(c.getInfo("1111111111"));
         pause();

         // Should work check that 2222222222 is waiting at last position in queue
         System.out.println(c.register("2222222222", "CCC333"));
         prettyPrint(c.getInfo("2222222222"));
         pause();

         // Should work check that 2222222222 is unregistered
         System.out.println(c.unregister("2222222222", "CCC333"));
         prettyPrint(c.getInfo("2222222222"));
         pause();

         // Should work check that 2222222222 is registered, check position is still last
         System.out.println(c.register("2222222222", "CCC333"));
         prettyPrint(c.getInfo("2222222222"));
         pause();

         // Should work check that 333... is still waiting even though 111... is unregistered
         System.out.println(c.register("3333333333", "CCC222"));
         System.out.println(c.unregister("1111111111", "CCC222"));
         prettyPrint(c.getInfo("3333333333"));
         pause();

         // SQL injecting the db
         System.out.println(c.unregister("2222222222", "X' OR 'a'='a"));
         prettyPrint(c.getInfo("2222222222"));
         pause();

      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.5.1.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      
      }
   }
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}
