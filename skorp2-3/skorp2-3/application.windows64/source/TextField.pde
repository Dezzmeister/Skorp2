/*
  for (int i = 65; i < 91; i++) {
    if (keys[i] && keys[SHIFT]) {
      println(char(i));
    } else {
      if (keys[i]) {
        println(char(i+32));
      }
    }
  }
  */
public class TextField {
  
  public FieldType textFieldType;
  
  public PGraphics textField;
  public PGraphics returnField;
  
  public int fieldWidth;
  public int fieldHeight;
  
  public int xCoord;
  public int yCoord;
  
  public int maxChars;
  
  public String input = "";
  
  public PFont font;
  
  private boolean keyHasBeenPressed = false;
  private boolean nextPass = false;
  
  public TextField(FieldType type) {
    textFieldType = type;
    
    textField = createGraphics(fieldWidth,fieldHeight,JAVA2D);
    textField.beginDraw();
    textField.background(150);
    textField.endDraw();
    
    returnField = createGraphics(fieldWidth,fieldHeight,JAVA2D);
    returnField.beginDraw();
    returnField.background(0,0);
    returnField.endDraw();
  }
  
  public TextField(int textFieldWidth, int textFieldHeight, FieldType type) {
    fieldWidth = textFieldWidth;
    fieldHeight = textFieldHeight;
    textFieldType = type;
    
    textField = createGraphics(fieldWidth,fieldHeight,JAVA2D);
    textField.beginDraw();
    textField.background(150);
    textField.endDraw();
    
    returnField = createGraphics(fieldWidth,fieldHeight,JAVA2D);
    returnField.beginDraw();
    returnField.background(0,0);
    returnField.endDraw();
  }
  
  public void setMaxChars(int max) {
    maxChars = max;
  }
  
  public void setLocation(int xPos, int yPos) {
    xCoord = xPos;
    yCoord = yPos;
  }
  
  public void drawField() {
    textField.beginDraw();
    textField.rectMode(CORNER);
    textField.background(150);
    textField.noFill();
    textField.strokeWeight(7);
    textField.stroke(0);
    textField.rect(0,0,fieldWidth,fieldHeight);
    if (font != null) {
      textField.textFont(font);
    }
    textField.textAlign(LEFT,CENTER);
    textField.fill(0);
    textField.text(input,15,(textField.height/2));
    textField.endDraw();
    
    imageMode(CENTER);
    image(textField,xCoord,yCoord);
  }
  
  //Does not accept spaces, because Skorp2 fields do not yet need spaces. You can add that if you want though.
  public String acceptInput() {
    if (!keyHasBeenPressed) {
      if (input.length() > maxChars) {
        input = input.substring(0,maxChars);
      }
      for (int i = 65; i < 91; i++) {
        if (keys[i] && keys[SHIFT]) {
          input = input + (char(i));
        } else {
          if (keys[i]) {
            input = input + (char(i+32));
          }
        }
      }
      if (keys['.']) {
        input = input + ".";
      }
      for (int i = 48; i < 58; i++) {
        if (keys[i]) {
          input = input + (char(i));
        }
      }
      if (keyCode == BACKSPACE && input.length() > 0) {
        input = input.substring(0,input.length()-1);
        keyCode = 0;
      }
      
      if (input.length() > 1 && nextPass && input.charAt(input.length()-1) == input.charAt(input.length()-2) && keys[input.charAt(input.length()-1)]) {
        input = input.substring(0,input.length()-1);
        keyHasBeenPressed = true;
      }
      if ((keyPressed && !keys[SHIFT])) {
        keyHasBeenPressed = true;
      } else {
        if (keyPressed && keys[SHIFT]) {
          nextPass = true;
        }
      }
      if (keys[ENTER]) {
        return input;
      }
    }
    if (!keyPressed) {
      keyHasBeenPressed = false;
      nextPass = false;
    }
    return null;
  }
}
  