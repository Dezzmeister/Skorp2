/*  
  Skorp 2 by Joe Desmond
  
  This code is poorly written because it is old and I did not know as much.
*/

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import processing.net.*;

import java.util.*;

//Skorp with mutliplayer (shoot me)

ArrayList<Rectangle> rects;
int numRects = 4;

PImage titlebarIcon;
PImage scroll;
int scrollX = -1600;
int scrollY = -1600;

PGraphics cursor;

color bg = color(150);

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
float deathTime;
int staticTime;
int timeOffset = 0;
int inGameTime;

boolean collision = false;
boolean ecollision = false;

boolean communicatingOnce = false;

boolean scoreDecreased = false;

boolean clicked = false;
boolean enterPressed = false;

boolean firstCollision = false;

boolean hardmode = false;

boolean keyBeenPressed = false;

boolean clickedRemove = false;
int clX = 0, clY = 0;

Minim minim;
AudioPlayer song;
AudioPlayer click;

Button initPlay;
Button connect;
Button host;
Button keyBindMenu;
Button backToNetMenu;
ArrayList<Button> buttons;

TextField connectingField;
TextField connectingPortField;
TextField hostingPortField;

TextField keychar;

IconButton soundToggle;

String defaultIP;
String defaultPort;
String defaultMode;
String defaultSoundOn = "";

KeybindEntry testEntry;

ArrayList<KeybindEntry> keybinds;

int gamecount = 0;

void setup() {
  size(800,800);
  
  noCursor();
  
  buttons = new ArrayList<Button>();
  keybinds = new ArrayList<KeybindEntry>();
  
  blocks20 = createFont("/fonts/harambe9/harambe8.ttf",20,false);
  blocks60 = createFont("/fonts/harambe9/harambe8.ttf",60,false);
  blocks70 = createFont("/fonts/harambe9/harambe8.ttf",70,false);
  blocks150 = createFont("/fonts/harambe9/harambe8.ttf",150,false);
  
  titlebarIcon = loadImage("/images/skorpicon.png");
  surface.setIcon(titlebarIcon);
  
  scroll = loadImage("/images/skorpscroll.png");
  
  loadConfig();
  loadKeybinds();
  musicFile = loadStrings("/config/music.txt");
  
  testEntry = new KeybindEntry("CAPS","Yootbar, Foos bar Qatar for Dakar I drive a cool car yee yee yee bar");
  keybinds.add(testEntry);
  
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
  
  cursor = createGraphics((int)(height/50.4),(int)(height/50.4),JAVA2D);
  cursor.beginDraw();
  cursor.background(0,0);
  cursor.noStroke();
  cursor.fill(#D1CBA9);
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
  
  keyBindMenu = new Button(width/2,height-50,300,75);
  keyBindMenu.setFont(blocks60);
  keyBindMenu.setText("Keybinds");
  
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
  
  keychar = new TextField(FieldType.INVISIBLE);
  
  soundToggle = new IconButton(width-35,height-35,40,40);
  soundToggle.loadImg("/images/soundon.png");
  soundToggle.loadImg2("/images/soundoff.png");
}

void loadConfig() {
  for (String s : loadStrings("/config/config.txt")) {
    if (s.length() > 4 && s.substring(0,4).equals("ip: ")) {
      ip = s.substring(s.indexOf(" ")+1);
    }
    if (s.length() > 6 && s.substring(0,6).equals("port: ")) {
      port = int(s.substring(s.indexOf(" ")+1));
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

void loadKeybinds() {
  for (String s : loadStrings("/config/keybinds.txt")) {
    keybinds.add(new KeybindEntry(s.substring(0,s.indexOf(" ")),s.substring(s.indexOf(" ")+1)));
  }
}

void initRects() {
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

void fixRects() {
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

void sendServerData() {
  
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
      println("reset");
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

void readClientData() {
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
            epx = int(s.substring(2));
          }
          if (s.substring(0,2).equals("py")) {
            epy = int(s.substring(2));
          }
        }
        if (s.indexOf("space") != -1) {
          eSpacePresses = int(s.substring(5));
        }
        if (s.length() > 5 && s.substring(0,5).equals("ready")) {
          eready = boolean(s.substring(5));
        }
      }
    }
  }
}

void multiplayer() {
  if (hosting) {
    sendServerData();
    readClientData();
  }
  if (connecting) {
    interpreter.read();
    interpreter.send();
  }
}

void speedUp(int amount) {
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
void initHosting() {
  server = new Server(this, port);
}

void initConnecting() {
  client = new Client(this, ip, port);
  interpreter = new Interpreter(client);
}

void drawMenus() {
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
        keyBindMenu.drawButton();
      }
      if (inHostingMenu && !enterPressed) {
        String portInput = hostingPortField.acceptInput();
        hostingPortField.drawField();
        
        textPort();
        
        if (portInput != null) {
          click();
          port = int(portInput);
          hosting = true;
          connecting = false;
          initHosting();
          inMenus = false;
          inHostingMenu = false;
          defaultPort = portInput;
          saveDefaultConfigData();
          inGameTime = millis() / 1000;
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
          port = int(portInput);
          hosting = false;
          connecting = true;
          initConnecting();
          inMenus = false;
          inConnectingPortMenu = false;
          defaultPort = portInput;
          saveDefaultConfigData();
          inGameTime = millis() / 1000;
          enterPressed = true;
        }
      }
      if (inKeybindMenu && !enterPressed) {
        textKeybinds();
        for (int i = 0; i < keybinds.size(); i++) {
          keybinds.get(i).drawAt(50,(i * 100) + 200);
          
          keybinds.get(i).clickLoop();
          if (keybinds.get(i).lastPressed == 2) {
            char c = keychar.readChar();
            
            if (c != 0 && c != BACKSPACE) {
              click();
              keybinds.get(i).activator = Character.toString(c);
              keybinds.get(i).lastPressed = 0;
              enterPressed = true;
            }
          }
          if (keybinds.get(i).lastPressed == 3) {
            char c = keychar.readChar();
            if (c != 0 && c != BACKSPACE && !keyBeenPressed) {
              keybinds.get(i).text = keybinds.get(i).text + Character.toString(c);
              keyBeenPressed = true;
            }
            if (c == BACKSPACE && !keyBeenPressed) {
              keybinds.get(i).text = (keybinds.get(i).text.length() > 0) ? keybinds.get(i).text.substring(0,keybinds.get(i).text.length()-1) : keybinds.get(i).text;
              keyBeenPressed = true;
            }
            if (!keyPressed) {
              keyBeenPressed = false;
            }
          }
         
        }
      }
      
      if (!keys[ENTER]) {
        enterPressed = false;
      }
    }
    if (!inKeybindMenu) {
      drawSkorpTitle();
    }
    
    imageMode(CENTER);
    image(cursor,mouseX,mouseY);
  }
}

void textIP() {
  fill(0,0,255);
  textFont(blocks60);
  textAlign(CENTER,CENTER);
  text("IP",width/2,(height/2)-80);
}

void textPort() {
  fill(0,0,255);
  textFont(blocks60);
  textAlign(CENTER,CENTER);
  text("Port",width/2,(height/2)-80);
}

void textKeybinds() {
  fill(255,255,0);
  textFont(blocks60);
  textAlign(CENTER,CENTER);
  text("Keybinds",width/2,80);
}

void saveDefaultConfigData() {
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

void mouseReleased() {
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
      if (keyBindMenu.isHovering()) {
        click();
        inNetOptionsMenu = false;
        inKeybindMenu = true;
        clicked = true;
      }
    }
    if (inKeybindMenu && !clicked) {
      textKeybinds();
      for (int i = 0; i < keybinds.size(); i++) {    
        keybinds.get(i).clickLoop();
        if (keybinds.get(i).lastPressed == 1) {
          keybinds.remove(i);
          clicked = true;
        }
      }
      
      if (backToNetMenu != null && backToNetMenu.isHovering()) {
        click();
        inNetOptionsMenu = true;
        inKeybindMenu = false;
        clicked = true;
      }
    }
      
    clicked = false;
  }
}

void click() {
  if (soundOn) {
    click.rewind();
    click.play();
  }
}

void drawSkorpTitle() {
  textAlign(CENTER);
  textFont(blocks150);
  fill(255,0,0);
  text("SKORP",(width/2)+(width/64),200);
}

void draw() {

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
          dl += 0.001;
        }
        if (deathTest == chance - 1) {
          edl += 0.001;
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
    
    if (communicating && gamecount==0 && hosting) {
      if (!hadDeathTime) {
        deathTime = (millis() / 1000)-2.9;
        hadDeathTime = true;
      }
      stopEverything();
    }
    
    if (((collided() || ecollided()) && communicating && (staticTime - inGameTime) > 3)) {
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

void reset() {
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
  if (collision && firstCollision) {
    escore += 1;
    println("escoreYEE");
  }
  if (ecollision) {
    score += 1;
    println("scoreYEE");
  }
  
  if (gamecount==0) {
    score = 0;
    escore = 0;
  }
  gamecount++;
  firstCollision = true;
  collision = false;
  ecollision = false;
  
  scoreDecreased = false;
}
  
void board() {
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

void lineConstraints() {
    if (edl > 0) {
      px = constrain(px,100,width-100);
      py = constrain(py,100,height-135);
    }
}
      
void drawKillLines() {
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

void kill() {
  if (staticTime - inGameTime < 20) {
    dl += 0.001;
  } else {
    if (staticTime - inGameTime < 35 && dl > 0.7 && spacePresses < 15) {
      //last minute save
      dl += 0.0007;
    } else {
      if (staticTime - inGameTime > 50) {
        dl += 0.005;
      } else {
        dl += 0.002;
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

void eKill() {
  if (staticTime - inGameTime < 20) {
    edl += 0.001;
  } else {
    if (staticTime - inGameTime < 35 && edl > 0.7 && eSpacePresses < 15) {
      //last minute save
      edl += 0.0007;
    } else {
      if (staticTime - inGameTime > 50) {
        edl += 0.005;
      } else {
        edl += 0.002;
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

void keyAction() {
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

void stopEverything() {
  stopped = true;
  server.write("HALT");
  for (int i = 0; i < rects.size(); i++) {
    rects.get(i).lSpeed = 0;
  }
}

void scoreDecreaseChance() {
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

boolean collided() {
  loadPixels();
  
  int xc = 0;
  int yc = 0;
  
  for (int i = 0; i < 6; i++) {
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
      case 4:
        xc = px-10;
        yc = py;
        break;
      case 5:
        xc = px;
        yc = py-10;
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

boolean ecollided() {
  loadPixels();
  
  int xc = 0;
  int yc = 0;
  
  for (int i = 0; i < 6; i++) {
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
      case 4:
        xc = epx-10;
        yc = epy;
        break;
      case 5:
        xc = epx;
        yc = epy-10;
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

void initializeGame() {
  if (!gameInitialized) {
    initTime = millis() / 1000;
    gameInitialized = true;
  }
}

void startMoving() {
  if (!started) {
    if (hosting) {
      for (int i = 0; i < rects.size(); i++) {
        rects.get(i).setSpeed();
      }
    started = true;
    }
  }
}

void drawPlayer() {
  rectMode(CENTER);
  noStroke();
  fill(0);
  rect(px,py,pWidth,pHeight);
}

void drawEnemy() {
  rectMode(CENTER);
  noStroke();
  fill(255);
  rect(epx,epy,pWidth,pHeight);
}

void refresh() {
  background(bg);
}

void update() {
  if (hosting) {
    for (Rectangle r : rects) {
      r.update();
    }
  }
}

void renderRects() {
  for (Rectangle r : rects) {
    r.paint();
  }
}

public int randLength() {
  return (int)random(100,200);
}

public color randColor() {
  return color(random(256),random(256),random(1,255));
}

public int rand(int len) {
  return (int)random(len/2.0, height-(len/2.0));
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
    int[] info = int(split(s,'.'));
    
    int id;
    int x;
    int y;
    int w;
    int l;
    color c;
    
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

void keyPressed() {
  if (keyCode < 256) {
    keys[keyCode] = true;
  }
  
  if (keyCode == ENTER && !inMenus) {
    ready = true;
  }
}

void keyReleased() {
  keys[keyCode] = false;
  if (key == ' ' && dl > 0) {
    spacePresses++;
  }
}