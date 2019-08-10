public class Rectangle {
  
  //These are public because this small game probably won't have superclasses and if it will then I can always make these private
  private int x, y, w, l;
  private color c;
  
  private int maxC = GREEN;
  
  private int id;
  
  private int lSpeed = 0;
  
  public Rectangle() {
    
  }
  
  public Rectangle(int x, int y, int w, int l, color c, int id) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.l = l;
    this.c = c;
    this.id = id;
    
    maxC = getMaxColor();
  }
  
  public void regenerate() {
    w = randLength();
    l = randLength();
    x = rand(w);
    y = rand(l);
    c = randColor();
    
    maxC = getMaxColor();
  }
  
  //rect,id,x,y,w,l,r,g,b
  //rect.id.x.y.w.l.r.g.b
  
  //Compacts necessary data to create a rectangle so that it can be sent to the client.
  public String initCompact() {
    return "rect."+id+"."+x+"."+y+"."+w+"."+l+"."+red(c)+"."+green(c)+"."+blue(c);
  }
  
  //rect,id,x,y
  //rect.id.x.y
  
  //Compacts necessary data to update an existing rectangle so that it can be sent to the client.
  public String compact() {
    return "rect."+id+"."+x+"."+y;
  }
  
  //Reads update data (only useful for the client).
  public void readCompact(String s) {
    String[] info = split(s,'.');
    
    if (info.length >= 4) {
      this.x = int(info[2]);
      this.y = int(info[3]);
    }
  }
  
  public void updateCoords(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public void setSpeed() {
    int rand = (int)random(2);
    int sub = 0;
    int add = 0;
    
    lSpeed = speed;
    
    if (rand == 0) {
      sub = (int)random(0,speedMin);
    } else {
      add = (int)random(0,speedMax);
    }
    
    lSpeed -= sub;
    lSpeed += add;
  }
    
    
  public boolean collidesWith(Rectangle r) {
    return ((abs(r.x-x) < (w/2.0)+(r.w/2.0) && abs(r.y-y) < (l/2.0)+(r.l/2.0)) || (w==r.w) && (l==r.l));
  }
  
  public int getMaxColor() {
    float r = red(c);
    float g = green(c);
    float b = blue(c);
    
    int rand = (int)random(4);
    if (rand == 2) {
      return EXTRA;
    }
    
    if (r > g) {
      if (r > b) {
        return RED;
      } else {
        return BLUE;
      }
    } else {
      if (g > b) {
        return GREEN;
      } else {
        return BLUE;
      }
    }
  }
  
  public void update() {
    
    switch(maxC) {
      case RED:
        if (x >= (width+(w/2.0))) {
          x = (int)(-w/2.0);
        }            
        x += lSpeed;
        break;
      case GREEN:
        if (y <= (-l/2.0)) {
          y = (int)(height+(l/2.0));
        }
        y -= lSpeed;
        break;
      case BLUE:
        if (x <= (-w/2.0)) {
          x = (int)(width+(w/2.0));
        }
        x -= lSpeed;
        break;
      case EXTRA:
        if (y >= (height+(l/2.0))) {
          y = (int)(-l/2.0);
        }
        y += lSpeed;
        break;
    }
  }
  
  public void paint() {
    rectMode(CENTER);
    fill(c);
    strokeWeight(1);
    stroke(1);
    rect(x,y,w,l);
  }
}