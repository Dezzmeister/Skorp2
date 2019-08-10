import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 
import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Skorp2 extends PApplet {










//Skorp with mutliplayer (shoot me)

ArrayList<Rectangle> rects;
int numRects = 4;

PImage titlebarIcon;
PImage scroll;
int scrollX = -1600;
int scrollY = -1600;

PGraphics cursor;

int bg = color(150);

final int RED = 0;
final int GREEN = 1;
final int BLUE = 2;
final int EXTRA = 3;

int speed = 5;
int speedMin = 2;
int speedMax = 2;

Server server;
Client client;
Interpreter interpreter;

String ip, mode;
int port;

boolean hosting = false;
boolean connecting = false;
boolean soundOn = true;
boolean liveMode = false;

boolean communicating = false;
boolean started = false;
boolean playing = false;

boolean stopped = false;

boolean gameInitialized = false;

boolean ready = false;
boolean eready = false;

int px = 50, py = 50;
int epx = 100, epy = 100;
float dl = 0, edl = 0;
int ogChance = 300;
int chance = ogChance;
int time = 0;
int stopTime = 0;
int score = 0, escore = 0;

int spacePresses = 0;
int spaceLimit = 20;
int eSpacePresses = 0;

boolean stopSending = false;

boolean waitingForClient = false;

int pWidth = 20;
int pHeight = 20;

int initTime = 0;

boolean[] keys;

PFont blocks20;
PFont blocks60;
PFont blocks70;
PFont blocks150;

String[] musicFile;

boolean hadDeathTime = false;
int deathTime;
int staticTime;
int timeOffset = 0;

boolean collision = false;
boolean ecollision = false;

boolean communicatingOnce = false;

boolean scoreDecreased = false;

boolean clicked = false;
boolean enterPressed = false;

Minim minim;
AudioPlayer song;
AudioPlayer click;

Button initPlay;
Button connect;
Button host;
ArrayList<Button> buttons;

TextField connectingField;
TextField connectingPortField;
TextField hostingPortField;

IconButton soundToggle;

String defaultIP;
String defaultPort;
String defaultMode;
String defaultSoundOn = "";

public void setup() {
  
  
  noCursor();
  
  buttons = new ArrayList<Button>();
  
  blocks20 = createFont("/fonts/harambe9/harambe8.ttf",20,false);
  blocks60 = createFont("/fonts/harambe9/harambe8.ttf",60,false);
  blocks70 = createFont("/fonts/harambe9/harambe8.ttf",70,false);
  blocks150 = createFont("/fonts/harambe9/harambe8.ttf",150,false);
  
  titlebarIcon = loadImage("/images/skorpicon.png");
  surface.setIcon(titlebarIcon);
  
  scroll = loadImage("/images/skorpscroll.png");
  
  loadConfig();
  musicFile = loadStrings("/config/music.txt");
  
  int randSong = (int)random(musicFile.length);
  
  minim = new Minim(this);
  
  song = minim.loadFile("/music/"+musicFile[randSong],2048);
  click = minim.loadFile("/sounds/click.mp3");
  
  surface.setTitle("Skorp");
  
  rects = new ArrayList<Rectangle>();  
  if (hosting) {
    initRects();
  }
  frameRate(60);
  
  keys = new boolean[256];
  
  cursor = createGraphics((int)(height/50.4f),(int)(height/50.4f),JAVA2D);
  cursor.beginDraw();
  cursor.background(0,0);
  cursor.noStroke();
  cursor.fill(0xffD1CBA9);
  cursor.ellipseMode(CENTER);
  cursor.ellipse(cursor.width/2,cursor.height/2,(cursor.width)-3,(cursor.height)-3);
  cursor.endDraw();
  
  initPlay = new Button(width/2,500,300,100);
  initPlay.setFont(blocks70);
  initPlay.setText("PLAY!");
  
  host = new Button(width/2,500,300,75);
  host.setFont(blocks60);
  host.setText("Host");
  
  connect = new Button(width/2,625,300,75);
  connect.setFont(blocks60);
  connect.setText("Connect");
  
  connectingField = new TextField(500,75,FieldType.BASIC);
  connectingField.setLocation(width/2,height/2);
  connectingField.font = blocks60;
  connectingField.setMaxChars(16);
  connectingField.input = ip;
  
  connectingPortField = new TextField(500,75,FieldType.BASIC);
  connectingPortField.setLocation(width/2,height/2);
  connectingPortField.font = blocks60;
  connectingPortField.setMaxChars(6);
  connectingPortField.input = Integer.toString(port);
  
  hostingPortField = new TextField(500,75,FieldType.BASIC);
  hostingPortField.setLocation(width/2,height/2);
  hostingPortField.font = blocks60;
  hostingPortField.setMaxChars(6);
  hostingPortField.input = Integer.toString(port);
  
  soundToggle = new IconButton(width-35,height-35,40,40);
  soundToggle.loadImg("/images/soundon.png");
  soundToggle.loadImg2("/images/soundoff.png");
}

public void loadConfig() {
  for (String s : loadStrings("/config/config.txt")) {
    if (s.length() > 4 && s.substring(0,4).equals("ip: ")) {
      ip = s.substring(s.indexOf(" ")+1);
    }
    if (s.length() > 6 && s.substring(0,6).equals("port: ")) {
      port = PApplet.parseInt(s.substring(s.indexOf(" ")+1));
    }
    if (s.length() > 6 && s.substring(0,6).equals("mode: ")) {
      mode = s.substring(s.indexOf(" ")+1);
      defaultMode = mode;
    }
    if (s.indexOf("no sound") != -1) {
      soundOn = false;
      defaultSoundOn = "no sound";
    }
    if (s.indexOf("live") != -1) {
      liveMode = true;
    }
  }
  if (mode.equals("host")) {
    hosting = true;
  } else {
    connecting = true;
  }
}

public void initRects() {
  int offset = 0;
  
  if (hosting) {
    offset = 2;
    rects.add(generate(0));
    rects.add(generate(1));
  }
  
  for (int i = offset; i < numRects+offset; i++) {
    rects.add(generate(i));
  }
  fixRects();
}

public void fixRects() {
  for (int i = 0; i < rects.size(); i++) {
    for (int j = 0; j < rects.size(); j++) {
      if (rects.get(i).id != rects.get(j).id && rects.get(j).collidesWith(rects.get(i))) {
        rects.get(j).regenerate();
        i = 0;
        j = 0;
      }
    }
  }
  
  if (hosting) {
    px = rects.get(0).x;
    py = rects.get(0).y;
    
    epx = rects.get(1).x;
    epy = rects.get(1).y;
    
    rects.remove(0);
    rects.remove(0);
  }
}

public void sendServerData() {
  
  //The server must send information to begin the game before the client will start to communicate. 
  if (!communicating) {
    String send = "";
    for (Rectangle r : rects) {
      send = send + r.initCompact() + " ";
    }
    
    String playerdata = "init px"+px+" py"+py+" epx"+epx+" epy"+epy+" ready"+ready+ " expect"+rects.size()+" ";
    
    send = send + "end";
    server.write(playerdata+send);
    //println(playerdata+send);
  }
  //println(staticTime-deathTime);
  if (hadDeathTime && staticTime-deathTime <= 3) {
    server.write("reset");
  } else {
    if (hadDeathTime) {
      reset();
    }
  }
  
  //When the server starts receiving data from the client, it knows the client is ready to begin the game so it starts sending normal data here. There are two stages so that the server is not sending too much data all the time.
  if (communicating && !hadDeathTime) {
    String send = "";
    for (Rectangle r : rects) {
      send = send + r.compact() + " ";
    }
    
    String playerdata = "data px"+px+" py"+py+" ready"+ready+" ";
    String data2 = "dl"+dl+" edl"+edl+" time"+time+" score"+score+" escore"+escore+" ";
    
    send = send + "end";
    server.write(playerdata+data2+send);
  }
}

public void readClientData() {
  client = server.available();
  
  if (client != null) {
    String input = client.readString();
    
    if (input.length() > 5 && input.substring(0,5).equals("data ") && input.indexOf("end") != -1) {
      communicating = true;
      communicatingOnce = true;
      
      input = input.substring(input.indexOf(" ")+1,input.indexOf(" end"));
      String[] data = split(input,' ');
      
      for (String s : data) {
        if (s.length() > 2) {
          if (s.substring(0,2).equals("px")) {
            epx = PApplet.parseInt(s.substring(2));
          }
          if (s.substring(0,2).equals("py")) {
            epy = PApplet.parseInt(s.substring(2));
          }
        }
        if (s.indexOf("space") != -1) {
          eSpacePresses = PApplet.parseInt(s.substring(5));
        }
        if (s.length() > 5 && s.substring(0,5).equals("ready")) {
          eready = PApplet.parseBoolean(s.substring(5));
        }
      }
    }
  }
}

public void multiplayer() {
  if (hosting) {
    sendServerData();
    readClientData();
  }
  if (connecting) {
    interpreter.read();
    interpreter.send();
  }
}

public void speedUp(int amount) {
  for (int i = 0; i < rects.size(); i++) {
    rects.get(i).lSpeed += amount;
  }
}
/*
if (hosting) {
    server = new Server(this, port);
  }
  if (connecting) {
    client = new Client(this, ip, port);
    interpreter = new Interpreter(client);
  }
*/
public void initHosting() {
  server = new Server(this, port);
}

public void initConnecting() {
  client = new Client(this, ip, port);
  interpreter = new Interpreter(client);
}

public void drawMenus() {
  if (inMenus) {
    imageMode(CORNER);
    image(scroll,scrollX,scrollY);
    scrollX += 2;
    scrollY += 2;
    
    if (scrollX >= 0) {
      scrollX = -1600;
    }
    if (scrollY >= 0) {
      scrollY = -1600;
    }
    if (inMainMenu) {
      initPlay.drawButton();
      soundToggle.drawButton();
    } else {
      fill(0,200);
      rectMode(CORNER);
      rect(0,0,width,height);
      
      if (inNetOptionsMenu) {
        host.drawButton();
        connect.drawButton();
      }
      if (inHostingMenu && !enterPressed) {
        String portInput = hostingPortField.acceptInput();
        hostingPortField.drawField();
        
        textPort();
        
        if (portInput != null) {
          click();
          port = PApplet.parseInt(portInput);
          hosting = true;
          connecting = false;
          initHosting();
          inMenus = false;
          inHostingMenu = false;
          defaultPort = portInput;
          saveDefaultConfigData();
          enterPressed = true;
        }
      }
      if (inConnectingMenu && !enterPressed) {
        String ipInput = connectingField.acceptInput();
        connectingField.drawField();
        
        textIP();
        
        if (ipInput != null) {
          click();
          ip = ipInput;
          inConnectingMenu = false;
          inConnectingPortMenu = true;
          defaultIP = ipInput;
          enterPressed = true;
        }
      }
      if (inConnectingPortMenu && !enterPressed) {
        String portInput = connectingPortField.acceptInput();
        connectingPortField.drawField();
        
        textPort();
        
        if (portInput != null) {
          click();
          port = PApplet.parseInt(portInput);
          hosting = false;
          connecting = true;
          initConnecting();
          inMenus = false;
          inConnectingPortMenu = false;
          defaultPort = portInput;
          saveDefaultConfigData();
          enterPressed = true;
        }
      } 
      
      if (!keys[ENTER]) {
        enterPressed = false;
      }
    }
    
    drawSkorpTitle();
    
    imageMode(CENTER);
    image(cursor,mouseX,mouseY);
  }
}

public void textIP() {
  fill(0,0,255);
  textFont(blocks60);
  textAlign(CENTER,CENTER);
  text("IP",width/2,(height/2)-80);
}

public void textPort() {
  fill(0,0,255);
  textFont(blocks60);
  textAlign(CENTER,CENTER);
  text("Port",width/2,(height/2)-80);
}

public void saveDefaultConfigData() {
  String[] defaults = new String[4];
  
  if (defaultIP != null) {
    defaults[0] = "ip: "+defaultIP;
  } else {
    defaults[0] = "ip: "+ip;
  }
  defaults[1] = "port: "+defaultPort;
  defaults[2] = "mode: "+defaultMode;
  defaults[3] = defaultSoundOn;
  
  saveStrings("/data/config/config.txt",defaults);
}

public void mouseReleased() {
  if (inMenus) {
    if (inMainMenu && !clicked) {
      if (initPlay.isHovering()) {
        click();
        inMainMenu = false;
        inNetOptionsMenu = true;
        clicked = true;
      }
    }
    if (inMainMenu && soundToggle.isHovering() && !clicked) {
      soundToggle.toggleOn = !soundToggle.toggleOn;
      if (soundToggle.toggleOn) {
        soundOn = true;
        defaultSoundOn = "";
      } else {
        soundOn = false;
        defaultSoundOn = "no sound";
      }
      saveDefaultConfigData();
      click();
      clicked = true;
    }
    if (inNetOptionsMenu && !clicked) {
      if (host.isHovering()) {
        click();
        inHostingMenu = true;
        inNetOptionsMenu = false;
        hosting = true;
        connecting = false;
        clicked = true;
      }
      if (connect.isHovering()) {
        click();
        inConnectingMenu = true;
        inNetOptionsMenu = false;
        connecting = true;
        hosting = false;
        clicked = true;
      }
    }
      
    clicked = false;
  }
}

public void click() {
  if (soundOn) {
    click.rewind();
    click.play();
  }
}

public void drawSkorpTitle() {
  textAlign(CENTER);
  textFont(blocks150);
  fill(255,0,0);
  text("SKORP",(width/2)+(width/64),200);
}

public void draw() {
  
  if (hosting) {
    time = (millis() / 1000) - timeOffset;
    staticTime = millis() / 1000;
  }
  int deathTest = (int)random(chance+10);
  refresh();
  
  drawMenus();
  
  if (soundOn && !inMenus && !song.isPlaying()) {
    song.loop();
  }
  //println(eSpacePresses);
  if (!inMenus) {
    multiplayer();
  }
  
  if (spacePresses > 20) {
    spacePresses = 0;
  }
  
  if (rects.size() > 0) {
    update();
  }
  
  if (communicatingOnce && !inMenus) {
    drawPlayer();
    drawEnemy();
  }
  
  if (ready && eready) {
    playing = true;
  }
  
  if (!inMenus) {
    if (playing) {
      initializeGame();
      if (staticTime >= initTime+3) {
        startMoving();            
      }
      keyAction();
      if (hosting) {
        if (deathTest == chance) {
          dl += 0.001f;
        }
        if (deathTest == chance - 1) {
          edl += 0.001f;
        }
        scoreDecreaseChance();
      }
      drawKillLines();
    }
    //println(dl);
    if (rects.size() > 0) {
      renderRects();
    }
    
    if (dl == 0) {
      spacePresses = 0;
    }
    
    board();
    lineConstraints();
    
    if (hosting && !stopped) {
      if (dl > 0) {
        kill();
      }
      if (edl > 0) {
        eKill();
      }
    }
    
    if (collided() || ecollided()) {
      if (hosting) {
        
        if (!hadDeathTime) {
          deathTime = millis() / 1000;
          hadDeathTime = true;
        }
      }
      stopEverything();
      if (connecting) {
        //exit();
      }
      println("stopped");    
    }
  }
}

public void reset() {
  communicating = false;
  
  ready = false;
  eready = false;
  playing = false;
  
  stopped = false;
  
  rects.clear();
  initRects();
  
  gameInitialized = false;
  started = false;
  
  hadDeathTime = false;
  
  timeOffset = time;
  dl = 0;
  edl = 0;
  if (collision) {
    escore += 1;
    println("escoreYEE");
  }
  if (ecollision) {
    score += 1;
    println("scoreYEE");
  }
  collision = false;
  ecollision = false;
  
  scoreDecreased = false;
}
  
public void board() {
  fill(0);
  rectMode(CORNER);
  rect(0,0,width,35);
  textAlign(CENTER);
  textFont(blocks20);
  fill(0,0,255);
  text("YOU:",100,23);
  text(score,142,23);
  fill(255,0,0);
  text("ENEMY:",230,23);
  text(escore,288,23);
  fill(0,255,0);
  text("Skorp",width/2,23);
  
  if (dl > 0) {
    fill(255,0,0);
    noStroke();
    rect(3*width/4,15,(20-spacePresses)*5,15);
  }
}

public void lineConstraints() {
    if (edl > 0) {
      px = constrain(px,100,width-100);
      py = constrain(py,100,height-135);
    }
}
      
public void drawKillLines() {
  stroke(1);
  strokeCap(SQUARE);
  strokeWeight(10);
  if (hosting) {
    line(width,35,width-(dl*(width-px)),dl*py);
  } else {
    line(0,35,dl*px,dl*py);
  }
  stroke(254);
  if (hosting) {
    line(0,35,edl*epx,edl*epy);
  } else {
    line(width,35,width-(edl*(width-epx)),edl*epy);
  }
}

public void kill() {
  if (time < 20) {
    dl += 0.001f;
  } else {
    if (time < 35 && dl > 0.7f && spacePresses < 15) {
      //last minute save
      dl += 0.0007f;
    } else {
      if (time > 50) {
        dl += 0.005f;
      } else {
        dl += 0.002f;
      }
    }
  }
  if (dl >= 1) {
    dl = 1; 
  } else {
    if (spacePresses >= spaceLimit) {
      spacePresses = 0;
      dl = 0;
    }
  }
}

public void eKill() {
  if (time < 20) {
    edl += 0.001f;
  } else {
    if (time < 35 && edl > 0.7f && eSpacePresses < 15) {
      //last minute save
      edl += 0.0007f;
    } else {
      if (time > 50) {
        edl += 0.005f;
      } else {
        edl += 0.002f;
      }
    }
  }
  if (edl >= 1) {
    edl = 1; 
  } else {
    if (eSpacePresses == spaceLimit) {
      eSpacePresses = 0;
      edl = 0;
    }
  }
}

public void keyAction() {
  if (!stopped) {
    if (keys[UP] || keys['W']) {
      py -= speed;
    }
    if (keys[DOWN] || keys['S']) {
      py += speed;
    }
    if (keys[LEFT] || keys['A']) {
      px -= speed;
    }
    if (keys[RIGHT] || keys['D']) {
      px += speed;
    }
  }
  
  int bound = 12;
  px = constrain(px,bound,width-bound);
  py = constrain(py,bound+35,height-bound);
}

public void stopEverything() {
  stopped = true;
  for (int i = 0; i < rects.size(); i++) {
    rects.get(i).lSpeed = 0;
  }
}

public void scoreDecreaseChance() {
  if (!scoreDecreased) {
    int c1 = (int)random(0,10);
    int c2 = (int)random(0,10);
    
    if (c1 == 1) {
      score -= 1;
    }
    if (c2 == 1) {
      escore -= 1;
    }
    scoreDecreased = true;
  }
}

public boolean collided() {
  loadPixels();
  
  int xc = 0;
  int yc = 0;
  
  for (int i = 0; i < 4; i++) {
    switch(i) {
      case 0:
        xc = px-10;
        yc = py-10;
        break;
      case 1:
        xc = px+10;
        yc = py-10;
        break;
      case 2:
        xc = px+10;
        yc = py+10;
        break;
      case 3:
        xc = px-10;
        yc = py+10;
        break;
    }
    int pix = yc*width+xc;
  
    if (!(pixels[pix] == bg || pixels[pix] == color(0))) {
      if (pixels[pix] == color(255)) {
        ecollision = true;
      }
      collision = true;
      return true;
    }
  }
  return false;
}

public boolean ecollided() {
  loadPixels();
  
  int xc = 0;
  int yc = 0;
  
  for (int i = 0; i < 4; i++) {
    switch(i) {
      case 0:
        xc = epx-10;
        yc = epy-10;
        break;
      case 1:
        xc = epx+10;
        yc = epy-10;
        break;
      case 2:
        xc = epx+10;
        yc = epy+10;
        break;
      case 3:
        xc = epx-10;
        yc = epy+10;
        break;
    }
    int pix = yc*width+xc;
  
    if (!(pixels[pix] == bg || pixels[pix] == color(255))) {
      if (pixels[pix] == color(0)) {
        collision = true;
      }
      ecollision = true;
      return true;
    }
  }
  return false;
}

public void initializeGame() {
  if (!gameInitialized) {
    initTime = millis() / 1000;
    gameInitialized = true;
  }
}

public void startMoving() {
  if (!started) {
    if (hosting) {
      for (int i = 0; i < rects.size(); i++) {
        rects.get(i).setSpeed();
      }
    started = true;
    }
  }
}

public void drawPlayer() {
  rectMode(CENTER);
  noStroke();
  fill(0);
  rect(px,py,pWidth,pHeight);
}

public void drawEnemy() {
  rectMode(CENTER);
  noStroke();
  fill(255);
  rect(epx,epy,pWidth,pHeight);
}

public void refresh() {
  background(bg);
}

public void update() {
  if (hosting) {
    for (Rectangle r : rects) {
      r.update();
    }
  }
}

public void renderRects() {
  for (Rectangle r : rects) {
    r.paint();
  }
}

public int randLength() {
  return (int)random(100,200);
}

public int randColor() {
  return color(random(256),random(256),random(1,255));
}

public int rand(int len) {
  return (int)random(len/2.0f, height-(len/2.0f));
}

public Rectangle generate(int id) {
  int w = randLength();
  int l = randLength();
  int x = rand(w);
  int y = rand(l);
  int c = randColor();
  
  return new Rectangle(x, y, w, l, c, id);    
}

//Reads compact rectangle data (only useful for the client).
public Rectangle readInitCompact(String s) {
    int[] info = PApplet.parseInt(split(s,'.'));
    
    int id;
    int x;
    int y;
    int w;
    int l;
    int c;
    
    if (info.length >= 8) {
      id = info[1];
      x = info[2];
      y = info[3];
      w = info[4];
      l = info[5];
      c = color(info[6],info[7],info[8]);
      
      return new Rectangle(x,y,w,l,c,id);
    } else {
      return new Rectangle();
    }
}

public void keyPressed() {
  if (keyCode < 256) {
    keys[keyCode] = true;
  }
  
  if (keyCode == ENTER && !inMenus) {
    ready = true;
  }
}

public void keyReleased() {
  keys[keyCode] = false;
  if (key == ' ' && dl > 0) {
    spacePresses++;
  }
}
public class Button {  
  float buttonWidth;
  float buttonHeight;
  float xCoor;
  float yCoor;
  
  int fillColor = color(120);
  
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
  
  public void setLocation(float x, float y) {
    if (buttonMode == CENTER) {
      xCoor = x;
      yCoor = y;
    } else {
      xCoor = x+(buttonWidth/2);
      yCoor = y+(buttonHeight/2);
    }
  }
  
  public void setSize(float bWidth, float bHeight) {
    buttonWidth = bWidth;
    buttonHeight = bHeight;
  }
  
  public void buttonMode(int mode) {
    if (mode == CENTER) {
      buttonMode = CENTER;
    } else {
      buttonMode = CORNER;
    }
  }
  
  public void setButton(float x, float y, float bWidth, float bHeight) {
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
  
  public void setTextSize(float size) {
    buttonTextSize = size;
  }
  
  public void setText(String text) {
    buttonText = text;
  }
  
  public void enableButton() {
    enabled = true;
  }
  
  public void disableButton() {
    enabled = false;
  }
  
  public void setFill(int fill) {
    fillColor = fill;
  }
  
  public void setFont(PFont font) {
    buttonFont = font;
    fontSet = true;
  }
  
  public void drawButton() {
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
      
  public boolean isHovering() {
    if (enabled) {
      return (mouseX >= xCoor-(buttonWidth/2) && mouseX <= xCoor+(buttonWidth/2) && mouseY >= yCoor-(buttonHeight/2) && mouseY <= yCoor+(buttonHeight/2));
    }
    return false;
  }
  
  public boolean onClick() {
    if (enabled) {
      return (mousePressed && isHovering());
    }
    return false;
  }
   
}
public class Console {
  
  public Console() {
    
  }
}
public enum FieldType {
  BASIC,
  CHAT,
  CONSOLE;
}
public class IconButton {  
  float buttonWidth;
  float buttonHeight;
  float xCoor;
  float yCoor;
  
  float buttonTextSize = 10;
  String buttonText = "";
  
  int buttonMode = CORNER;
  
  boolean enabled = true;
  
  PImage icon;
  PImage icon2;
  
  int imgMode = CENTER;
  
  boolean noImg = true;
  
  int localVal = -1;
  
  String name = "";
  String desc = "";
  String localName = "";
  String localpackname = "core";
  String localpackversion = "";
  
  boolean initialized = false;
  
  boolean toggle = true;
  boolean toggleOn = true;
  
  IconButton() {
    xCoor = width/2;
    yCoor = height/2;
    buttonWidth = 40;
    buttonHeight = 40;
  }
  
  IconButton(float bWidth, float bHeight) {
    buttonWidth = bWidth;
    buttonHeight = bHeight;
  }
  
  IconButton(float x, float y, float bWidth, float bHeight) {
    xCoor = x;
    yCoor = y;
    buttonWidth = bWidth;
    buttonHeight = bHeight;
  }
  
  public void setPackName(String pack) {
    localpackname = pack;
  }
  
  public String getPackName() {
    return localpackname;
  }
  
  public void setPackVersion(String packVersion) {
    localpackversion = packVersion;
  }
  
  public String getPackVersion() {
    return localpackversion;
  }
  
  public void setLocalName(String lName) {
    localName = lName;
  }
  
  public String getLocalName() {
    return localName;
  }
  
  public boolean isInitialized() {
    return initialized;
  }
  
  public void initialize() {
    initialized = true;
  }
  
  public void loadImg(String filename) {
    icon = loadImage(filename);
    noImg = false;
  }
  
  public void loadImg2(String filename) {
    icon2 = loadImage(filename);
    noImg = false;
  }
  
  public PImage getImg() {
    return icon;
  }
  
  public void setButtonName(String buttonName) {
    name = buttonName;
  }
  
  public void setButtonDesc(String buttonDesc) {
    desc = buttonDesc;
  }
  
  public String getButtonName() {
    return name;
  }
  
  public String getButtonDesc() {
    return desc;
  }
  
  public void register(String buttonName, String buttonDesc) {
    name = buttonName;
    desc = buttonDesc;
  }
  public void register(String buttonName, String buttonDesc, int val) {
    name = buttonName;
    desc = buttonDesc;
    localVal = val;
  }
  
  public void setLocalVal(int val) {
    localVal = val;
  }
  
  public int getLocalVal() {
    return localVal;
  }
  
  public void setImgMode(int mode) {
    if (mode == CORNER) {
      imgMode = CORNER;
    } else {
      imgMode = CENTER;
    }
  }
  
  public void disableImg() {
    noImg = true;
  }
  
  public void enableImg() {
    noImg = false;
  }
  
  public void setLocation(float x, float y) {
    if (buttonMode == CENTER) {
      xCoor = x;
      yCoor = y;
    } else {
      xCoor = x+(buttonWidth/2);
      yCoor = y+(buttonHeight/2);
    }
  }
  
  public void setSize(float bWidth, float bHeight) {
    buttonWidth = bWidth;
    buttonHeight = bHeight;
  }
  
  public void buttonMode(int mode) {
    if (mode == CENTER) {
      buttonMode = CENTER;
    } else {
      buttonMode = CORNER;
    }
  }
  
  public void setButton(float x, float y, float bWidth, float bHeight) {
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
  
  public void setTextSize(float size) {
    buttonTextSize = size;
  }
  
  public void setText(String text) {
    buttonText = text;
  }
  
  public void enableButton() {
    enabled = true;
  }
  
  public void disableButton() {
    enabled = false;
  }
  
  public void drawButton() {
    if (icon.width > buttonWidth || icon.height > buttonHeight) {
      exit();
    }
    if (isHovering()) {
      noStroke();
    } else {
      strokeWeight(2);
      stroke(0);
    }
    fill(170);
    rectMode(CENTER);
    rect(xCoor,yCoor,buttonWidth,buttonHeight,0,0,0,0);
    rectMode(CORNER);
    strokeWeight(1);
    
    if (!noImg) {
      switch (imgMode) {
        case CENTER:
          imageMode(CENTER);
          if (toggleOn) {
            image(icon,xCoor,yCoor);
          } else {
            image(icon2,xCoor,yCoor);
          }
          break;
        case CORNER:
          imageMode(CORNER);
          if (toggleOn) {
            image(icon,xCoor-(buttonWidth/2),yCoor-(buttonHeight/2));
          } else {
            image(icon2,xCoor-(buttonWidth/2),yCoor-(buttonHeight/2));
          }
          break;
      }
    }
  }
      
  public boolean isHovering() {
    if (enabled) {
      return (mouseX >= xCoor-(buttonWidth/2) && mouseX <= xCoor+(buttonWidth/2) && mouseY >= yCoor-(buttonHeight/2) && mouseY <= yCoor+(buttonHeight/2));
    }
    return false;
  }
   
}
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
    println("stopped? : "+stopped);
    if (c.available() > 0) {
      input = c.readString();
      //println(input);
      if (input.indexOf("reset") != -1) {
        if (!hasBeenReset) {
          communicating = false;
          stopped = false;
          ready = false;
          
          playing = false;
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
          prepareToClear = false;
        }
        stopped = false;
        input = input.substring(input.indexOf(" ")+1,input.indexOf(" end"));
        hasBeenReset = false;
        data = split(input,' ');
        
        for (String s : data) {
          if (s.length() > 2) {
            if (s.substring(0,2).equals("px")) {
              epx = PApplet.parseInt(s.substring(2));
            }
            if (s.substring(0,2).equals("py")) {
              epy = PApplet.parseInt(s.substring(2));
            }
            
          }
          if (s.length() > 3) {
            if (s.substring(0,3).equals("epx")) {
              px = PApplet.parseInt(s.substring(3));
            }
            if (s.substring(0,3).equals("epy")) {
              py = PApplet.parseInt(s.substring(3));
            }
          }
          if (s.length() >= 5) {
            if (s.substring(0,5).equals("ready")) {
              eready = PApplet.parseBoolean(s.substring(5));
            }
          }
          
          if (s.length() > 6 && s.substring(0,6).equals("expect")) {
            numRects = PApplet.parseInt(s.substring(6));
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
              epx = PApplet.parseInt(s.substring(2));
            }
            if (s.substring(0,2).equals("py")) {
              epy = PApplet.parseInt(s.substring(2));
            }
            
            if (s.indexOf("dl") == 0) {
              edl = PApplet.parseFloat(s.substring(2));
            }
          }
          
          if (s.indexOf("edl") == 0) {
            dl = PApplet.parseFloat(s.substring(3));
          }
          if (s.indexOf("time") == 0) {
            time = PApplet.parseInt(s.substring(4));
          }
          
          if (s.indexOf("escore") != -1) {
            score = PApplet.parseInt(s.substring(6));
          }
          if (s.indexOf("score") != -1 && s.indexOf("escore") == -1) {
            escore = PApplet.parseInt(s.substring(5));
          }
            
          if (s.length() > 5 && s.substring(0,5).equals("ready")) {
            eready = PApplet.parseBoolean(s.substring(5));
          }
          if (s.length() >= 4 && s.substring(0,4).equals("rect")) {
            int id = PApplet.parseInt(s.substring(s.indexOf(".")+1,s.indexOf(".")+2));
            
            if (rects.size() > 0) {
              rects.get(id-2).readCompact(s);
            }
          }
        }
      }
    }
  }
          
}
boolean inMenus = true;
boolean inMainMenu = true;
boolean inNetOptionsMenu = false;
boolean inHostingMenu = false;
boolean inConnectingMenu = false;
boolean inConnectingPortMenu = false;
public class Rectangle {
  
  //These are public because this small game probably won't have superclasses and if it will then I can always make these private
  private int x, y, w, l;
  private int c;
  
  private int maxC = GREEN;
  
  private int id;
  
  private int lSpeed = 0;
  
  public Rectangle() {
    
  }
  
  public Rectangle(int x, int y, int w, int l, int c, int id) {
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
      this.x = PApplet.parseInt(info[2]);
      this.y = PApplet.parseInt(info[3]);
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
    return ((abs(r.x-x) < (w/2.0f)+(r.w/2.0f) && abs(r.y-y) < (l/2.0f)+(r.l/2.0f)) || (w==r.w) && (l==r.l));
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
        if (x >= (width+(w/2.0f))) {
          x = (int)(-w/2.0f);
        }            
        x += lSpeed;
        break;
      case GREEN:
        if (y <= (-l/2.0f)) {
          y = (int)(height+(l/2.0f));
        }
        y -= lSpeed;
        break;
      case BLUE:
        if (x <= (-w/2.0f)) {
          x = (int)(width+(w/2.0f));
        }
        x -= lSpeed;
        break;
      case EXTRA:
        if (y >= (height+(l/2.0f))) {
          y = (int)(-l/2.0f);
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
        fileData = new String[PApplet.parseInt(input.substring(input.indexOf(":")+1))];
        getFile();
      }
      if (input.indexOf("p0917lNDg618BDItavdjgai62bfio1.") != -1) {
        fileData[PApplet.parseInt(input.charAt(0))] = input.substring(input.indexOf("."));
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
          input = input + (PApplet.parseChar(i));
        } else {
          if (keys[i]) {
            input = input + (PApplet.parseChar(i+32));
          }
        }
      }
      if (keys['.']) {
        input = input + ".";
      }
      for (int i = 48; i < 58; i++) {
        if (keys[i]) {
          input = input + (PApplet.parseChar(i));
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
  
  public void settings() {  size(800,800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Skorp2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
