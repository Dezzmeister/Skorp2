public class ServerHandler {
  //Small but useful class for TCP server-side data management. UDP methods will be added.
  
  private Server s;
  private Client c;
  
  private String clientEndKey = " end";
  private String serverEndKey = clientEndKey;
  private String[] fileData;
  private String fileName;
  
  public ServerHandler(Server s, Client c) {
    this.s = s;
    this.c = c;
  }
  
  //TCP was made for this
  public void sendFile(String[] file, String filename) {
    server.write("datafile." + filename + ":"+file.length);
    
    for (int i = 0; i < file.length; i++) {
      //This nonsense is here for reasons I will not explain because I'm not in the mood to
      file[i] = i + " p0917lNDg618BDItavdjgai62bfio1." + file[i];
      server.write(file[i]);
    }
    server.write("file end");
  }
  
  //DO NOT INCLUDE DELIMITING SPACES IN THE PARAMETERS! The method adds them automatically.
  //You should, however, include data identifiers.
  public void formatData(String header, String[] data) {
    
    String tempData = header;
    
    for (String s : data) {
      tempData = tempData + " " + s;
    }
    tempData = tempData + " " + serverEndKey;
    
    sendData(tempData);
  }
  
  //Same rules apply for this method as the one above. The only difference is that this returns the formatted data instead of sending it.
  public String getFormattedData(String header, String[] data) {
    
    String tempData = header;
    
    for (String s : data) {
      tempData = tempData + " " + s;
    }
    
    return tempData + " " + serverEndKey;
  }
  
  public void sendData(String data) {
    server.write(data);
  }
  
  public String[] getData() {
    c = s.available();
    if (c != null) {
      String input = c.readString();
      if (input.indexOf(clientEndKey) != -1) {
        return split(input.substring(0,input.indexOf(clientEndKey)), ' ');
      }
    }
    return null;
  }
  
  public void setClientEndKey(String s) {
    clientEndKey = s;
  }
  
  public void setServerEndKey(String s) {
    serverEndKey = s;
  }
  
  public String getDataHeader() {
    c = s.available();
    if (c != null) {
      String input = c.readString();
      if (input.indexOf(clientEndKey) != -1) {
        return input.substring(0,input.indexOf(" "));
      }
    }
    return null;
  }
  
  //If no data is being sent by the client and/or the data does not constitute a file, this method will return null. Otherwise, it will output an incoming file from the client by recursively checking for more file data, until 
  public String[] getFile() {
    c = s.available();
    if (c != null) {
      String input = c.readString();
      if (input.length() >= 8 && input.substring(0,8).equals("datafile")) {
        fileName = input.substring(input.indexOf(".")+1,input.indexOf(":"));
        fileData = new String[int(input.substring(input.indexOf(":")+1))];
        getFile();
      }
      if (input.indexOf("p0917lNDg618BDItavdjgai62bfio1.") != -1) {
        fileData[int(input.charAt(0))] = input.substring(input.indexOf("."));
        getFile();
      }
      if (input.substring(0,8).equals("file end")) {
        
        //Reassigns fileData to prepare for the next file, then returns its previous contents
        String[] tempFileData = fileData;
        fileData = new String[0];
        return tempFileData;
      }
    }
    
    //Small but important precaution, in case the final packet is lost - the method will wait for it, then return fileData instead of simply returning null
    if (fileData.length > 1) {
      getFile();
    }
    return null;
  }
  
  public String getLastFileName() {
    return fileName;
  }
  
  public String getFileName() {
    String filename = fileName;
    fileName = null;
    return filename;
  }
}