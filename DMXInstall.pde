import dmxP512.*;
import processing.net.*;
import processing.serial.*;
import themidibus.*;

MidiBus bus;

Server server;
Client client;
String input;
float data[];

float prevX = 0;
float prevY = 0;
float prevD = 1600;
float prevXmin = 0;
float prevYmin = 0;
float prevXmax = 500;
float prevYmax = 500;

PrintWriter effectOutput;
PrintWriter output;
PrintWriter logger;
int count = 1;

//declaring two sets of global color values
int hue1 = 0;
int saturation1 = 255;
int brightness1 = 255;
int alpha1 = 255;

int hue2 = 127;
int saturation2 = 255;
int brightness2 = 255;
int alpha2 = 255;

Boolean splitSwitch = false;
Boolean colSwitch = false;
Boolean blackswitch = false;
boolean reversed = false;
Boolean gridSwitch = false;
Boolean colorFlop = false;
Boolean personSwitch = true;
Boolean armsMode = false;
Boolean kinectColor = true;
//declaring global effect speed values
float globalAngle = 0;
float globalSpeed = 30;
int globalWidth = 0;
float globalRotation = 0;
int switchFrequency = 100;
int transition = 10;


//light information for interface connectivity
DmxP512 dmxOutput;
int universeSize = 256;
String DMXPRO_PORT = "/dev/tty.usbserial-EN224919";
int DMXPRO_BAUDRATE = 115000;
ArrayList<ThreeCh> Lights3Ch;
int numLights = 22;
Boolean lightBlack = false;
Boolean[] lightPositions = new Boolean[5];

float smFactor = 0.2;

//Declaring places for the effects to live
int numEffects = 9;
ArrayList<Boolean> modes;
ArrayList<PGraphics> Layers;

PGraphics gcom;
//declaring which effects we have
GradientScan gradScan;
//no automatic scroll
GradientScan2 gradScan2;
GradientScan2 gradScan22;
HardFlip hardFlip;
RotatingBar bar;
SplitGradient splitGrad;
Fountain f1;
Fountain f2;



void setup(){
  size(500,500);
  rectMode(CENTER);
  colorMode(HSB);
  frameRate(30);
  
  server  = new Server(this, 5050);
  
  bus = new MidiBus(this, "APC MINI", "APC MINI");
  
   gcom = createGraphics(width,height);
  
  dmxOutput = new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  
  Lights3Ch = new ArrayList<ThreeCh>();
  
  for(int i = 0; i < lightPositions.length; i++){
   lightPositions[i] = false; 
  }
  
  for(int i = 0; i < numLights; i++){
    PVector nextLoc = new PVector(radius * sin(currentAngle) + width / 2,radius * cos(currentAngle) + height / 2);
    Lights3Ch.add(new ThreeCh(i*3,nextLoc));
    currentAngle += (lightSpacing);
  }
  
  Layers = new ArrayList<PGraphics>();
  for(int i = 0; i < numEffects; i++){
   Layers.add(createGraphics(width, height));
  }
  
  modes = new ArrayList<Boolean>(numEffects);
  for(int i = 0; i < numEffects; i++){
   modes.add(false);
  }
  
  for(int i = 0; i < modes.size(); i++){
    if(i == 0){
      modes.set(i, true);
    }else{
     modes.set(i, false);
    }
  }
  
  gradScan = new GradientScan();
  hardFlip = new HardFlip();
  gradScan2 = new GradientScan2(true);
  gradScan22 = new GradientScan2(false);
  bar = new RotatingBar(false);
  splitGrad = new SplitGradient();
  f1 = new Fountain(prevX, prevY);
  f2 = new Fountain(prevX, prevY);
}

void draw(){
  background(0);
  client = server.available();
  if( client!= null){
   input = client.readString();
   input = input.substring(0, input.length());
   data = float(split(input, ','));
   
   float curX;
   float curY;
   float avgD;
   float Xmin;
   float Ymin;
   float Xmax;
   float Ymax;
   int sw;
   if(data.length == 8){
     curX = data[0];
     curY = data[1];
     avgD = data[2];
     Xmin = data[3];
     Ymin = data[4];
     Xmax = data[5];
     Ymax = data[6];
     sw = int(data[7]);
     //println(data[7]);
     if(curX >=0){
       prevX = 512 - curX;
       //println(prevX);
     }
     if(curY >= 0){
       prevY = curY;
     }
     if(avgD >= 0){
      prevD = avgD; 
     }
     if(Xmin >= 0){
       prevXmin = Xmin;
     }
     if(Ymin >= 0){
       prevYmin = Ymin; 
     }
     if(Xmax >= 0){
       prevXmax = Xmax; 
     }
     if(Ymax >= 0){
       prevYmax = Ymax; 
     }
    }
 }
  //Where the effects live
  if(modes.get(0)){
    PGraphics g = Layers.get(0);
    globalWidth = 0;
    globalSpeed = 4;
    if(kinectColor){
    int tmp = int(map(prevX, 0, width, 0, 255));
    if(tmp > 255){
     tmp = 255; 
    }
    int tmp2 = int(map(prevD, 1600, 3400, 0, 255));
    if(tmp2 > 255){
     tmp2 = 255; 
    }
    hue1 = tmp;
    brightness1 = tmp2;
    }else{
     globalSpeed = int(map(prevD, 1600, 3400, 2, 40));
    }
    if(globalSpeed < 0){
     globalSpeed = 1; 
    }
    //globalSpeed = map(prevD, 1600, 3750,  0 , 20);
    //globalSpeed = 4;
    //globalAngle = int(map(prevX, 30, 492, 5 * PI / 6, PI / 6));
    if(lightPositions[0] == true || lightPositions[1] == true){
      globalAngle = 0;
    }else if(lightPositions[2] == true || lightPositions[3] == true){
      globalAngle = 0;
    }else if(lightPositions[4] == true){
      globalAngle = PI / 4;
     }
   
    g.beginDraw();
    g.background(0);
    if(splitSwitch == true){
      gradScan.sw(false);
      gradScan.update(hue1, saturation1, brightness1, hue2, saturation2, brightness2, globalSpeed, globalAngle, globalWidth);
      gradScan.display(g);
      gradScan.sw(true);
      gradScan.update(hue2, saturation2, brightness2, hue1, saturation1, brightness1, globalSpeed, globalAngle, globalWidth);
      gradScan.display(g);
    }else{
      gradScan.sw(false);
      gradScan.update(hue1, saturation1, brightness1, hue2, saturation2, brightness2, globalSpeed, globalAngle, globalWidth);
      gradScan.display(g);
      gradScan.sw(true);
      gradScan.update(hue1, saturation1, brightness1, hue2, saturation2, brightness2, globalSpeed, globalAngle, globalWidth);
      gradScan.display(g);
    }
    if(gradScan.loc.x > width / 2){
      gradScan.loc.x = -width / 2  ;
    }else if(gradScan.loc.x < -width /2){
      gradScan.loc.x = width / 2;
    }
    g.endDraw();
    pushMatrix();
    translate(width/2, height /2);
    rotate(globalAngle);
    //tint(255, map(transition, 10, 0, 0, 255));
    image(g,gradScan.loc.x,gradScan.loc.y);
    image(g,gradScan.loc.x - g.width, gradScan.loc.y);
    popMatrix();
  }
  
  
  if(modes.get(1)){
    //switchFrequency = int(map(prevD, 1600, 3000, 50, 15));
    switchFrequency = 18;
    if(switchFrequency == 0){
     switchFrequency = 1; 
    }
    if(frameCount % switchFrequency == 0){
     if(colorFlop == true){
      colorFlop = false; 
     }else{
      colorFlop = true; 
     }
    }
    
    if(lightPositions[1] == true || lightPositions[3] == true){
     globalAngle = 0; 
    }else if(lightPositions[2] == true){
     globalAngle = PI/2; 
    }else if(lightPositions[4] == true){
      globalAngle = PI / 4;
    }
    //globalAngle = int(map(prevX, 30, 492, 7 * PI / 8, PI / 8));
     //globalAngle = int(map(prevD, 1600, 3750, , width));
   PGraphics g = Layers.get(1);
   
   if(colorFlop == true){
      hardFlip.update(globalAngle, hue1, saturation1, brightness1, hue2, saturation2, brightness2);
    }else{
      hardFlip.update(globalAngle, hue2, saturation2, brightness2, hue1, saturation1, brightness1); 
    }
   hardFlip.display(g);
   image(g,0,0);
  }
  
  if(modes.get(2)){
   PGraphics g = Layers.get(2);
   float pos = map(prevX, 0, 550, -width, width/4);
   //globalWidth = int(map(prevD, 1600, 3750, 0, width));
   globalWidth = 2 * width / 5;
   if(lightPositions[2] == true){
    globalAngle = 0; 
   }
   else if(lightPositions[1] == true){
     globalAngle = PI/2;
   }
   if(splitSwitch == true){
      rectMode(CORNER);
      noStroke();
      fill(hue2, saturation2, brightness2);
      rect(0,height/2, width, height/2);
      noStroke();
      fill(hue1, saturation1, brightness1);
      rect(0,0, width, height/2);
      gradScan2.sw(false);
      gradScan2.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      gradScan2.sw(true);
      gradScan2.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      pushMatrix();
      translate(width/2, height /2);
      rotate(globalAngle);
      image(g,gradScan2.loc.x, gradScan2.loc.y);
      popMatrix();
   }else{
      background(hue2, saturation2, brightness2);
      gradScan2.sw(false);
      gradScan2.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      gradScan2.sw(true);
      gradScan2.update(hue2, brightness2, saturation2, hue1, saturation1, brightness1, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      pushMatrix();
      translate(width/2, height /2);
      rotate(globalAngle);
      image(g,gradScan2.loc.x, gradScan2.loc.y);
      popMatrix();
   }
  }
  
  if(modes.get(3)){
    if(!armsMode){
      globalAngle = map(prevX, 30, 492, -PI/32, PI/32);
      globalRotation += globalAngle;
      globalWidth = 6 * width / 9;
    }else{
      globalRotation = map(prevYmin - prevYmax, 0, height / 2, PI / 2, 3 * PI / 2);
      globalWidth = 6 * width / 9;
    }
   
   //background(hue2, saturation2, brightness2);
   PGraphics g = Layers.get(3);
   float pos = -width/2;
   //float pos = map(globalSpeed, 0, 50, -width, width/4);;
   if(splitSwitch == true){
   bar.sw(false);
   bar.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, pos, globalAngle, globalWidth);
   bar.display(g);
   bar.sw(true);
   bar.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, pos, globalAngle, globalWidth);
   bar.display(g);
   pushMatrix();
    translate(width/2, height /2);
    rotate(globalRotation);
    image(g,bar.loc.x, bar.loc.y);
    popMatrix();
   }else{
   //background(hue2,brightness2, saturation2);
   bar.sw(false);
   bar.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, pos, globalAngle, globalWidth);
   bar.display(g);
   bar.sw(true);
   bar.update(hue2, brightness2, saturation2, hue1, saturation1, brightness1, pos, globalAngle, globalWidth);
   bar.display(g);
   pushMatrix();
   translate(width/2, height /2);
   rotate(globalRotation);
   image(g,bar.loc.x, bar.loc.y);
   popMatrix();
   }
  }
  
  
  //Split from center
  if(modes.get(4)){
   PGraphics g = Layers.get(4);
   int x = int(map(prevX, 0, width, -width / 2, width /2));
   //globalAngle += map(prevD, 1600, 3750, 0, PI / 4);
   globalWidth = int(map(prevD, 1600, 3750, 40, 10));
   if(splitSwitch == true){
    rectMode(CORNER);
    splitGrad.sw(false);
    splitGrad.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, globalSpeed, globalWidth);
    splitGrad.display(g);
    splitGrad.sw(true);
    splitGrad.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, globalSpeed, globalWidth);
    splitGrad.display(g);
    pushMatrix();
    translate(width/2 + x, height/2);
    rotate(globalAngle);
    image(g, -width /2, -height / 2);
    popMatrix();
   }else{
    splitGrad.sw(false);
    splitGrad.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, globalSpeed, globalWidth);
    splitGrad.display(g);
    splitGrad.sw(true);
    splitGrad.update(hue2, brightness2, saturation2, hue1, saturation1, brightness1, globalSpeed, globalWidth);
    splitGrad.display(g);
    pushMatrix();
    translate(width/2 + x, height/2);
    rotate(globalAngle);
    image(g, -width / 2, -height / 2);
    popMatrix();
   }
  }
  
  if(modes.get(5)){
   PGraphics g = Layers.get(5);
   g.colorMode(HSB);
   g.beginDraw();
   int tmp3 = 20;

   if(kinectColor){
     int tmp = int(map(prevX, 0, width, 0, 255));
    if(tmp > 255){
     tmp = 255; 
    }
    hue1 = tmp;
   }else{
     tmp3 = int(map(prevD, 1600, 3750, 50, 2));
     if(tmp3 < 1){
        tmp3 = 1; 
      }
   }
   if(frameCount % tmp3 == 0){
   if(colorFlop == true){
    colorFlop = false; 
   }else{
    colorFlop = true; 
   }
   }
   if(colorFlop == true){
     g.fill(hue1, brightness1, saturation1, 90);
     g.noStroke();
     g.rect(0,0, width, height / 2);
     g.fill(hue2, brightness2, saturation2, 90);
     g.rect(0, height / 2, width, height/2);
   }else{
     g.fill(hue2, brightness2, saturation2, 90);
     g.noStroke();
     g.rect(0,0, width, height / 2);
     g.fill(hue1, brightness1, saturation1, 90);
     g.rect(0, height / 2, width, height/2);
   }
   g.endDraw();
   image(g, 0, 0);
  }
  
  if(modes.get(6)){
   PGraphics g = Layers.get(6);
   g.beginDraw();
   g.colorMode(HSB);
   g.background(hue2, saturation2, brightness2);
   color c = color(hue1, saturation1, brightness1);
   f1.run(prevX, prevY, prevXmin, prevYmin, c, g);
   f2.run(prevX, prevY, prevXmax, prevYmax, c, g);
   g.endDraw();
   image(g,0,0);
  }
  
  if(modes.get(7)){
   PGraphics g = Layers.get(7);
   g.beginDraw();
   g.colorMode(RGB);
   colorMode(RGB);
   g.loadPixels();
   color c1 = color(hue1, saturation1, brightness1);
   color c2 = color(hue2, saturation2, brightness2);
   for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
     g.pixels[i + j * width] = lerpColor(c1, c2, map(sin(i * PI / 25), -1, 1, 0, 1.0));
    }
   }
   g.updatePixels();
   g.endDraw();
   image(g, 0, 0);
  }
  if(modes.get(8)){
    int tmp = int(map(prevX, 50, width - 50, 0, 255));
    int tmp2 = int(map(prevD, 1600, 3200, 0, 255));
    hue1 = tmp;
    brightness1 = tmp2;
    hue2 = 255 - tmp;
    brightness2 = tmp2;
   PGraphics g = Layers.get(8);
   g.beginDraw();
   g.colorMode(HSB);
   g.background(0, alpha1);
   g.fill(hue1, saturation1, brightness1, alpha1);
   g.rect(0,0, width, height/2);
   g.fill(hue2, saturation2, brightness2, alpha1);
   g.rect(0, height / 2, width, height/2);
   g.endDraw();
   //tint(255, 25);
   image(g, 0, 0);
  }
  
  //apply the effect to the lights
  for(int j = 0; j < modes.size(); j++){
    if(modes.get(j) == true){
      PGraphics g = Layers.get(j);
 
  for(int i = 1; i < Lights3Ch.size() * 3; i++){
    colorMode(HSB);
    ThreeCh l = Lights3Ch.get(i / 3);
    if(!l.black){
    color c = l.sampleColor(g);
    dmxOutput.set(i, int(red(c)));
    i++;
    dmxOutput.set(i, int(green(c)));
    i++;
    dmxOutput.set(i, int(blue(c)));
    noStroke();
    fill(c);
    l.display();
   }else{
    color c = l.sampleColor(g);
    dmxOutput.set(i, 0);
    i++;
    dmxOutput.set(i, 0);
    i++;
    dmxOutput.set(i, 0);
    noStroke();
    fill(c);
    l.display();
   }
  }
  }
 }
 lightBlack = false;
 if(keyPressed == true){
   if(key == 'm'){
 lightArranger(Lights3Ch);
   }
 }
 if(gridSwitch == true){
  displayGrid(); 
 }
}

void keyPressed(){
  if(key == 'z'){
   lightBlackout(Lights3Ch); 
 }
 if(key == 'l'){
   readLightFile("positions.txt");
   for(int i = 0; i < lightPositions.length; i++){
    if(i != 0){
     lightPositions[i] = false;
    }else{
     lightPositions[i] = true; 
    }
   }
 }
 if(key == 'k'){
   readLightFile("positions2.txt");
   for(int i = 0; i < lightPositions.length; i++){
    if(i != 1){
     lightPositions[i] = false;
    }else{
     lightPositions[i] = true; 
    }
   }
 }
 if(key == 'j'){
   readLightFile("positions3.txt");
   for(int i = 2; i < lightPositions.length; i++){
    if(i != 0){
     lightPositions[i] = false;
    }else{
     lightPositions[i] = true; 
    }
   }
 }
 if(key == 'h'){
   readLightFile("positions4.txt");
   for(int i = 3; i < lightPositions.length; i++){
    if(i != 0){
     lightPositions[i] = false;
    }else{
     lightPositions[i] = true;
    }
   }
 }
 if(key == 's'){
   saveEffectFile();
 }
 if(key == 'x'){
  logger.flush();
  logger.close();
  exit();
 }
 if(key == 'g'){
  if(gridSwitch == true){
   gridSwitch = false; 
  }else{
   gridSwitch = true; 
  }
 }
}

void controllerChange(int channel, int number, int value){
 if(number == 48){
   if(colSwitch == true){
   hue1 = value * 2;
   }else{
    hue2 = value * 2; 
   }
 }
 if(number == 49){
   if(colSwitch == true){
   saturation1 = value * 2;
   }else{
    saturation2 = value * 2; 
   }
 }
 if(number == 50){
   if(colSwitch == true){
   brightness1 = value * 2;
   }else{
    brightness2 = value * 2; 
   }
  }
  if(number == 51){
   globalAngle = map(value, 0, 127, 0, TWO_PI);
  }
  if(number == 52){
   globalSpeed = map(value, 0, 127, 0, 50); 
  }
  if(number == 53){
   globalWidth =int(map(value, 0, 127, 0, width)); 
  }
  if(number == 56){
   currentAngle = map(value, 0, 127, 0, TWO_PI);
   lightReset(Lights3Ch);
 }
}

void noteOn(Note note){
  
  if(note.pitch() == 0){
    readLightFile("positions.txt");
    bus.sendNoteOn(0, 0, 127);
    for(int i = 0; i < 4; i++){
      if(i != 0){
      bus.sendNoteOn(0, i, 0);
      }
    }
    for(int i = 0; i < lightPositions.length; i++){
        if(i != 0){
         lightPositions[i] = false;
        }else{
         lightPositions[i] = true; 
        }
     }
  }
  if(note.pitch() == 1){
    readLightFile("positions2.txt");
    bus.sendNoteOn(0, 1, 127);
    for(int i = 0; i < 4; i++){
      if(i != 1){
      bus.sendNoteOn(0, i, 0);
      }
    }
    for(int i = 0; i < lightPositions.length; i++){
        if(i != 1){
         lightPositions[i] = false;
        }else{
         lightPositions[i] = true; 
        }
     }
  }
  if(note.pitch() == 2){
    readLightFile("positions3.txt");
    bus.sendNoteOn(0, 2, 127);
    for(int i = 0; i < 4; i++){
      if(i != 2){
      bus.sendNoteOn(0, i, 0);
      }
    }
    for(int i = 0; i < lightPositions.length; i++){
        if(i != 2){
         lightPositions[i] = false;
        }else{
         lightPositions[i] = true; 
        }
     }
  }
  if(note.pitch() == 3){
    readLightFile("positions4.txt");
    bus.sendNoteOn(0, 3, 127);
    for(int i = 0; i < 4; i++){
      if(i != 3){
      bus.sendNoteOn(0, i, 0);
      }
    }
    for(int i = 0; i < lightPositions.length; i++){
        if(i != 3){
         lightPositions[i] = false;
        }else{
         lightPositions[i] = true; 
        }
     }
  }
  if(note.pitch() == 4){
    readLightFile("positions5.txt");
    bus.sendNoteOn(0, 3, 127);
    for(int i = 0; i < 4; i++){
      if(i != 4){
      bus.sendNoteOn(0, i, 0);
      }
    }
    for(int i = 0; i < lightPositions.length; i++){
        if(i != 4){
         lightPositions[i] = false;
        }else{
         lightPositions[i] = true; 
        }
     }
  }
  if(note.pitch() == 55){
   for(int i = 0; i < modes.size(); i++){
    if(i == 8){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 55, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, 55, 0);
   }
  }
 }
 if(note.pitch() == 56){
   for(int i = 0; i < modes.size(); i++){
    if(i == 0){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 56, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 57){
   for(int i = 0; i < modes.size(); i++){
    if(i == 1){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 57, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 58){
   for(int i = 0; i < modes.size(); i++){
    if(i == 2){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 58, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 59){
   for(int i = 0; i < modes.size(); i++){
    if(i == 3){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 59, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 60){
   for(int i = 0; i < modes.size(); i++){
    if(i == 4){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 60, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 61){
   for(int i = 0; i < modes.size(); i++){
    if(i == 5){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 61, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 62){
   for(int i = 0; i < modes.size(); i++){
    if(i == 6){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 62, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 63){
   for(int i = 0; i < modes.size(); i++){
    if(i == 7){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
      bus.sendNoteOn(0, 63, 127);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
      bus.sendNoteOn(0, i + 56, 0);
   }
  }
 }
 if(note.pitch() == 64){
   if(colSwitch == true){
    colSwitch = false;
    bus.sendNoteOn(0, 64, 0);
   }
   else{
    colSwitch = true; 
    bus.sendNoteOn(0, 64, 127);
  }
 }
 if(note.pitch() == 67){
  if(reversed == true){
   reversed = false;
   bus.sendNoteOn(0, 67, 0);
  }else{
   reversed = true; 
   bus.sendNoteOn(0, 67, 127);
  }
 }
 if(note.pitch() == 70){
  printConsole(); 
 }
 if(note.pitch() == 98){
   if(splitSwitch == true){
    splitSwitch = false;
    bus.sendNoteOn(0, 97, 127);
   }
   else{
    splitSwitch = true;
    bus.sendNoteOn(0, 97, 0);
  }
 }
}

void printConsole(){
 if(logger == null){
 logger = createWriter("effects.txt");
 }
 logger.println("");
 logger.println("#" + count);
 logger.println("");
 logger.println(hue1);
 logger.println(saturation1);
 logger.println(brightness1);
 logger.println(hue2);
 logger.println(saturation2);
 logger.println(brightness2);
 logger.println(colSwitch);
 logger.println(reversed);
 logger.println(globalAngle);
 logger.println(globalSpeed);
 logger.println(globalWidth);
 logger.println(splitSwitch); 
 count++;
}

void displayGrid(){
  stroke(0);
  strokeWeight(1);
 for(int i = 0; i < width; i+=50){
  line(i, 0, i, height); 
 }
 for(int i = 0; i < height; i+=50){
  line(0, i, width, i); 
 }
}

void saveEffectFile(){
  effectOutput = createWriter("effectFile2.txt");
  effectOutput.println(hue1);
  effectOutput.println(saturation1);
  effectOutput.println(brightness1);
  effectOutput.println(hue2);
  effectOutput.println(saturation2);
  effectOutput.println(brightness2);
  effectOutput.println(splitSwitch);
  effectOutput.println(colSwitch);
  effectOutput.println(blackswitch);
  effectOutput.println(reversed);
  effectOutput.println(gridSwitch);
  effectOutput.println(colorFlop);
  effectOutput.println(globalAngle);
  effectOutput.println(globalSpeed);
  effectOutput.println(globalWidth);
  effectOutput.println(globalRotation);
  effectOutput.println(switchFrequency);
  effectOutput.println(transition);
  for(int i = 0; i < lightPositions.length; i++){
    if(lightPositions[i]){
      effectOutput.println(i);
    }
  }
  for(int i = 0; i < modes.size(); i++){
    if(modes.get(i)){
  effectOutput.println(i);
    }
  }
  effectOutput.println(armsMode);
  effectOutput.println(kinectColor);
  effectOutput.flush();
  effectOutput.close();
}