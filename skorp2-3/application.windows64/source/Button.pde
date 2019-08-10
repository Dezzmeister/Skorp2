public class Button {  
  float buttonWidth;
  float buttonHeight;
  float xCoor;
  float yCoor;
  
  color fillColor = color(120);
  
  float buttonTextSize = 10;
  String buttonText = "";
  
  int buttonMode = CORNER;
  
  boolean enabled = true;
  
  PGraphics button;
  boolean usingGraphics = false;
  
  PFont buttonFont;
  boolean fontSet = false;
  
  Button() {
    xCoor = width/2;
    yCoor = height/2;
    buttonWidth = width/16;
    buttonHeight = height/16;
  }
  
  Button(float bWidth, float bHeight) {
    buttonWidth = bWidth;
    buttonHeight = bHeight;
  }
  
  Button(float x, float y, float bWidth, float bHeight) {
    xCoor = x;
    yCoor = y;
    buttonWidth = bWidth;
    buttonHeight = bHeight;
    //button = createGraphics((int)bWidth,(int)bHeight);
    //usingGraphics = true;
  }
  
  void setLocation(float x, float y) {
    if (buttonMode == CENTER) {
      xCoor = x;
      yCoor = y;
    } else {
      xCoor = x+(buttonWidth/2);
      yCoor = y+(buttonHeight/2);
    }
  }
  
  void setSize(float bWidth, float bHeight) {
    buttonWidth = bWidth;
    buttonHeight = bHeight;
  }
  
  void buttonMode(int mode) {
    if (mode == CENTER) {
      buttonMode = CENTER;
    } else {
      buttonMode = CORNER;
    }
  }
  
  void setButton(float x, float y, float bWidth, float bHeight) {
    if (buttonMode == CENTER) {
      xCoor = x;
      yCoor = y;
    } else {
      xCoor = x+(bWidth/2);
      yCoor = y+(bHeight/2);
    }
    buttonWidth = bWidth;
    buttonHeight = bHeight;
  }
  
  void setTextSize(float size) {
    buttonTextSize = size;
  }
  
  void setText(String text) {
    buttonText = text;
  }
  
  void enableButton() {
    enabled = true;
  }
  
  void disableButton() {
    enabled = false;
  }
  
  void setFill(color fill) {
    fillColor = fill;
  }
  
  void setFont(PFont font) {
    buttonFont = font;
    fontSet = true;
  }
  
  void drawButton() {
    if (!usingGraphics) {
      if (isHovering()) {
        noStroke();
      } else {
        strokeWeight(2);
        stroke(0);
      }
      fill(fillColor);
      rectMode(CENTER);
      rect(xCoor,yCoor,buttonWidth,buttonHeight);
      textAlign(CENTER,CENTER);
      fill(0);
      textSize(buttonTextSize);
      if (fontSet) {
        textFont(buttonFont);
      }
      text(buttonText,xCoor+(width/128),yCoor-(buttonWidth/64));
    } else {
      button.beginDraw();
      button.background(120);
      if (isHovering()) {
        button.noStroke();
      } else {
        button.strokeWeight(2);
        button.stroke(0);
      }
      button.fill(120);
      button.rectMode(CENTER);
      button.rect(xCoor,yCoor,buttonWidth,buttonHeight);
      button.textAlign(CENTER,CENTER);
      button.fill(0);
      button.textSize(buttonTextSize);
      if (fontSet) {
        button.textFont(buttonFont);
      }
      button.text(buttonText,xCoor+(width/64),yCoor-(buttonWidth/64));
      button.endDraw();
      image(button,xCoor,yCoor);
    }
  }
      
  boolean isHovering() {
    if (enabled) {
      return (mouseX >= xCoor-(buttonWidth/2) && mouseX <= xCoor+(buttonWidth/2) && mouseY >= yCoor-(buttonHeight/2) && mouseY <= yCoor+(buttonHeight/2));
    }
    return false;
  }
  
  boolean onClick() {
    if (enabled) {
      return (mousePressed && isHovering());
    }
    return false;
  }
   
}