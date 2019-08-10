

public class KeybindEntry {
  private PGraphics box;
  public String activator;
  public String text;
  private IconButton remove;
  
  private int x, y;
  private int line;
  public int id;
  
  public int lastPressed = 0;
  
  public KeybindEntry(String activator, String text) {
    this.activator = activator;
    this.text = text;
    remove = new IconButton(x+680,y+20,20,20);
    remove.loadImg("images/smallremove.png");
    box = createGraphics(700,75);
    box.beginDraw();
    box.fill(120);
    box.strokeWeight(2);
    box.rectMode(CORNER);
    box.rect(0,0,box.width,box.height);
    box.fill(0);
    box.textAlign(CENTER,CENTER);
    box.textFont(blocks60);
    box.text(activator,125,(box.height/2)-(box.height/16));
    box.strokeWeight(4);
    box.line(230,0,230,box.height);
    box.textAlign(LEFT,CENTER);
    box.textFont(blocks20);
    box.text(text,250,0,450,75);
    box.endDraw();
  }
  
  public void drawAt(int x, int y) {
    this.x = x;
    this.y = y;
    
    box.beginDraw();
    box.fill(120);
    box.strokeWeight(2);
    box.rectMode(CORNER);
    box.rect(0,0,box.width,box.height);
    box.fill(0);
    box.textAlign(CENTER,CENTER);
    box.textFont(blocks60);
    box.text(activator,125,(box.height/2)-(box.height/16));
    box.strokeWeight(4);
    box.line(230,0,230,box.height);
    box.textAlign(LEFT,CENTER);
    box.textFont(blocks20);
    box.text(text,250,0,450,75);
    box.endDraw();
    
    imageMode(CORNER);
    image(box,x,y);
    
    remove.xCoor = x+688;
    remove.yCoor = y+12;
    remove.drawButton();
  }
  
  public int clickLoop() {
    if (mousePressed && remove.isHovering()) {  //Remove button clicked
      click();
      lastPressed = 1;
      return 1;
    }
    if (mousePressed && mouseX > x && mouseX < x+230 && mouseY > y && mouseY < y + box.height) {  //Key field clicked
      click();
      lastPressed = 2;
      return 2;
    }
    if (mousePressed && mouseX > (x + 230) && mouseX < x + box.width && mouseY > y && mouseY < y + box.height && !remove.isHovering()) {  //Text field clicked
      click();
      lastPressed = 3;
      return 3;
    }
    if (mousePressed) {
      lastPressed = 0;
    }
    
    return 0;
  }
  
}