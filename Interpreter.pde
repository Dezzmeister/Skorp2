public class Interpreter {
  
  //This class is for interpreting data from and sending the right data to a Skorp server
  
  Client c;
  
  String input;
  String[] data;
  
  boolean hasBeenReset = false;
  boolean prepareToClear = false;
  
  public Interpreter(Client c) {
    this.c = c;
    
  }
  
  //Example: data px50 py40 readytrue end
  public void send() {
    //communicating is a boolean that tells if the client has received necessary data to start the game. When the server starts receiving data from the client, it knows that the client is ready and normal communication will begin.
    if (communicating) {
      String data = "data px"+px+" py"+py+" ready"+ready+" space"+spacePresses+" end";
      
      c.write(data);
    }
    if (collided() && communicating) {
      server.write("reset");
      ready = false;
    }
    if (c.available() > 0 && communicating) {
      String inputStr = c.readString();
      if (inputStr != null && inputStr.length() >= 5 && inputStr.substring(0,5).equals("init ")) {
        //communicating = false;
        //rects.clear();
      }
    }
  }

  public void read() {
    //println("stopped? : "+stopped);
    if (c.available() > 0) {
      input = c.readString();
      //println(input);
      if (input.indexOf("HALT") != -1) {
        stopped = true;
      }
      
      if (input.indexOf("reset") != -1) {
        if (!hasBeenReset) {
          communicating = false;
          stopped = false;
          ready = false;
          
          started = false;
          gameInitialized = false;
          hasBeenReset = true;
          prepareToClear = true;
        }
      }
      if (input.indexOf("stopit") != -1) {
        stopSending = true;
      }
      if (input.length() > 5 && input.substring(0,5).equals("init ") && input.indexOf("end") != -1 && !communicating) {
        if (prepareToClear) {
          rects.clear();
          playing = false;
          prepareToClear = false;
        }
        stopped = false;
        input = input.substring(input.indexOf(" ")+1,input.indexOf(" end"));
        hasBeenReset = false;
        data = split(input,' ');
        
        for (String s : data) {
          if (s.length() > 2) {
            if (s.substring(0,2).equals("px")) {
              epx = int(s.substring(2));
            }
            if (s.substring(0,2).equals("py")) {
              epy = int(s.substring(2));
            }
            
          }
          if (s.length() > 3) {
            if (s.substring(0,3).equals("epx")) {
              px = int(s.substring(3));
            }
            if (s.substring(0,3).equals("epy")) {
              py = int(s.substring(3));
            }
          }
          if (s.length() >= 5) {
            if (s.substring(0,5).equals("ready")) {
              eready = boolean(s.substring(5));
            }
          }
          
          if (s.length() > 6 && s.substring(0,6).equals("expect")) {
            numRects = int(s.substring(6));
          }
          
          if (s.length() >= 4 && s.substring(0,4).equals("rect")) {
            if (rects.size() < numRects) {
              rects.add(readInitCompact(s));
            } else {
              communicating = true;
              communicatingOnce = true;
            }
          }
        }
      }
      if (input.length() > 5 && input.substring(0,5).equals("data ") && input.indexOf("end") != -1) {
        input = input.substring(input.indexOf(" ")+1,input.indexOf(" end"));
        data = split(input,' ');
      
        for (String s : data) {
          if (s.length() > 2) {
            if (s.substring(0,2).equals("px")) {
              epx = int(s.substring(2));
            }
            if (s.substring(0,2).equals("py")) {
              epy = int(s.substring(2));
            }
            
            if (s.indexOf("dl") == 0) {
              edl = float(s.substring(2));
            }
          }
          
          if (s.indexOf("edl") == 0) {
            dl = float(s.substring(3));
          }
          if (s.indexOf("time") == 0) {
            time = int(s.substring(4));
          }
          
          if (s.indexOf("escore") != -1) {
            score = int(s.substring(6));
          }
          if (s.indexOf("score") != -1 && s.indexOf("escore") == -1) {
            escore = int(s.substring(5));
          }
            
          if (s.length() > 5 && s.substring(0,5).equals("ready")) {
            eready = boolean(s.substring(5));
          }
          if (s.length() >= 4 && s.substring(0,4).equals("rect")) {
            int id = int(s.substring(s.indexOf(".")+1,s.indexOf(".")+2));
            
            if (rects.size() > 0) {
              rects.get(id-2).readCompact(s);
            }
          }
        }
      }
    }
  }
          
}