import dmxP512.*;
import processing.net.*;
import processing.serial.*;
import themidibus.*;

MidiBus bus;

Server server;
Client client;
String input;
float data[];

int numFiles = 8;
String[] effectFiles = new String[numFiles];
int currentFile = 0;


float prevX = 0;
float prevY = 0;
float prevD = 1600;
float prevXmin = 0;
float prevYmin = 0;
float prevXmax = 500;
float prevYmax = 500;

PrintWriter output;
PrintWriter effectOutput;
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
Boolean kinectColor = false;
//declaring global effect speed values
float globalAngle = 0;
float globalSpeed = 30;
int globalWidth = 0;
float globalRotation = 0;
int switchFrequency = 100;
int transition = 10;

int lastFrameSeen = 0;
int masterFirst = 0;
int masterNext = 0;
int firstFrame = 0;
int lastFrame = 0;
int shortDuration = 48;
int longDuration = 600;
int gracePeriod = 150;
boolean inTransitionOff = false;
boolean inTransitionOn = false;
boolean inTransition = false;
boolean personOffScreen = true;
int currentEffectNum = 0;


//light information for interface connectivity
DmxP512 dmxOutput;
int universeSize = 256;
String DMXPRO_PORT = "/dev/tty.usbserial-EN224919";
int DMXPRO_BAUDRATE = 115000;
ArrayList<ThreeCh> Lights3Ch;
int numLights = 22;
Boolean lightBlack = false;
Boolean[] lightPositions = new Boolean[5];
String[] lightFiles = new String[5];



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
  
  for(int i = 0; i < numFiles; i ++){
     effectFiles[i] = "effectFile" + i + ".txt";
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
  
  lightFiles[0] = "positions.txt";
  lightFiles[1] = "positions2.txt";
  lightFiles[2] = "positions3.txt";
  lightFiles[3] = "positions4.txt";
  lightFiles[4] = "positions5.txt";
  readEffectFile(0);
}

void draw(){
  background(0, 25);
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
   if(data.length > 8){
    server.write(1); 
   }
   if(data.length >= 8){
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
     if(sw == 1 && personSwitch != true && frameCount > firstFrame + gracePeriod && frameCount - lastFrameSeen < 150 && currentEffectNum < 1){
       //println(sw);
       personSwitch = true;
       masterFirst = frameCount + shortDuration;
       masterNext = frameCount + longDuration + shortDuration;
       firstFrame = frameCount;
       lastFrame = frameCount + shortDuration;
       inTransitionOn = true;
       personOffScreen = false;
       println("inTransitionOn");
     }
     if(sw == 0 && personSwitch == true){
       personSwitch = false;
       lastFrameSeen = frameCount;
       firstFrame = frameCount + gracePeriod;
       //println("inTransitionOff");
     }
     if(sw >= 1){
      lastFrameSeen = frameCount; 
     }
    }
  }
  if(!personSwitch && frameCount - lastFrameSeen == 250){
     inTransitionOff = true; 
     lastFrame = frameCount + shortDuration;
     println("inTransitionOff");
  }
   if(masterNext - frameCount == 0 && frameCount - lastFrameSeen < 150){
     firstFrame = frameCount;
     lastFrame = frameCount + shortDuration;
     masterFirst = frameCount + shortDuration;
     masterNext = frameCount + longDuration + shortDuration;
     inTransition = true;
     println("inTransition");
   }
   
   if(inTransition == true && frameCount - lastFrameSeen < 150){
    int f = lastFrame - frameCount;
    if(f > shortDuration / 2){
      alpha1 = int(map(f, shortDuration, shortDuration / 2, 255 , 0));
    }else{
      alpha1 = int(map(f, shortDuration / 2, 0, 0 , 255));
    }
    
    if(masterNext - frameCount == longDuration + shortDuration/2){
      if(currentEffectNum < numFiles-1){
      currentEffectNum++;
      }else{
       currentEffectNum = int(random(1,numEffects)); 
      }
      readEffectFile(currentEffectNum);
    }
    if(f <= 0){
     inTransition = false; 
     masterFirst = frameCount;
     masterNext = frameCount + longDuration;
     println("inTransitionfalse");
    }
   }
   if(inTransitionOn){
     int f = (lastFrame - frameCount);
     //if(f == shortDuration){
     // masterNext = frameCount; 
     //}
     if(f > shortDuration / 2){
      alpha1 = int(map(f, shortDuration, shortDuration / 2, 255 , 0));
    }else{
      alpha1 = int(map(f, shortDuration / 2, 0, 0 , 255));
    }
     if(f == shortDuration / 2){
       currentEffectNum = 1;
       readEffectFile(currentEffectNum);
     }
     if(f <= 0){
      inTransitionOn = false; 
      masterNext = frameCount + longDuration; 
      println("inTransitionOnfalse");
     }
   }
   if(inTransitionOff){
     int f = lastFrame - frameCount;
     if(f > shortDuration / 2){
      alpha1 = int(map(f, shortDuration, shortDuration / 2, 255 , 0));
    }else{
      alpha1 = int(map(f, shortDuration / 2, 0, 0 , 255));
    }
     if(f == shortDuration / 2){
       currentEffectNum = 0;
       readEffectFile(currentEffectNum);
     }
     if(f <= 0){
      inTransitionOff = false;
      println("inTransitionOfffalse");
     }
   }
  
  
  //Where the effects live
  if(modes.get(0)){
    PGraphics g = Layers.get(0);
    globalWidth = 0;
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
      globalSpeed = int(map(prevD, 1600, 3400, 2, 20));
    }
    
    //globalSpeed = map(prevD, 1600, 3750,  0 , 20);
    //globalAngle = int(map(prevX, 30, 492, 5 * PI / 6, PI / 6));
    //if(lightPositions[0] == true || lightPositions[1] == true){
    //  globalAngle = PI / 2;
    //}else if(lightPositions[2] == true || lightPositions[3] == true){
    //  globalAngle = 0;
    //}else if(lightPositions[4] == true){
    //  globalAngle = PI / 4;
    //}
    g.beginDraw();
    g.background(0, alpha1);
    if(splitSwitch == true){
      gradScan.sw(false);
      gradScan.update(hue1, saturation1, brightness1, hue2, saturation2, brightness2,alpha1, globalSpeed, globalAngle, globalWidth);
      gradScan.display(g);
      gradScan.sw(true);
      gradScan.update(hue2, saturation2, brightness2, hue1, saturation1, brightness1,alpha1, globalSpeed, globalAngle, globalWidth);
      gradScan.display(g);
    }else{
      gradScan.sw(false);
      gradScan.update(hue1, saturation1, brightness1, hue2, saturation2, brightness2,alpha1, globalSpeed, globalAngle, globalWidth);
      gradScan.display(g);
      gradScan.sw(true);
      gradScan.update(hue1, saturation1, brightness1, hue2, saturation2, brightness2,alpha1, globalSpeed, globalAngle, globalWidth);
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
    tint(255, alpha1);
    image(g,gradScan.loc.x,gradScan.loc.y);
    image(g,gradScan.loc.x - g.width, gradScan.loc.y);
    popMatrix();
  }
  
  
  if(modes.get(1)){
    switchFrequency = int(map(prevD, 1600, 3000, 50, 15));
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
      hardFlip.update(globalAngle, hue1, saturation1, brightness1, hue2, saturation2, brightness2, alpha1);
    }else{
      hardFlip.update(globalAngle, hue2, saturation2, brightness2, hue1, saturation1, brightness1, alpha1); 
    }
   hardFlip.display(g);
   tint(255, alpha1);
   image(g,0,0);
  }
  
  if(modes.get(2)){
   PGraphics g = Layers.get(2);
   float pos = map(prevX, 0, 550, -width, width/4);
   //globalWidth = int(map(prevD, 1600, 3750, 0, width));
   //if(lightPositions[2] == true){
   // globalAngle = 0; 
   //}
   //else if(lightPositions[1] == true){
   //  globalAngle = PI/2;
   //}
   if(splitSwitch == true){
      rectMode(CORNER);
      noStroke();
      fill(hue2, saturation2, brightness2, alpha1);
      rect(0,height/2, width, height/2);
      noStroke();
      fill(hue1, saturation1, brightness1, alpha1);
      rect(0,0, width, height/2);
      gradScan2.sw(false);
      gradScan2.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      gradScan2.sw(true);
      gradScan2.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      pushMatrix();
      translate(width/2, height /2);
      rotate(globalAngle);
      tint(255, alpha1);
      image(g,gradScan2.loc.x, gradScan2.loc.y);
      popMatrix();
   }else{
      background(hue2, saturation2, brightness2, alpha1);
      gradScan2.sw(false);
      gradScan2.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      gradScan2.sw(true);
      gradScan2.update(hue2, brightness2, saturation2, hue1, saturation1, brightness1, alpha1, pos, globalAngle, globalWidth);
      gradScan2.display(g);
      pushMatrix();
      translate(width/2, height /2);
      rotate(globalAngle);
      tint(255, alpha1);
      image(g,gradScan2.loc.x, gradScan2.loc.y);
      popMatrix();
   }
  }
  
  if(modes.get(3)){
    if(!armsMode){
      globalAngle = map(prevX, 30, 492, -PI/32, PI/32);
      globalRotation += globalAngle;
      //globalWidth = int(map(prevD, 1600, 3750, width / 4, width));
    }else{
      globalRotation = map(prevYmin - prevYmax, 0, height / 2, PI / 2, 3 * PI / 2);
    }
   PGraphics g = Layers.get(3);
   float pos = -width/2;
   //float pos = map(globalSpeed, 0, 50, -width, width/4);;
   if(splitSwitch == true){
   bar.sw(false);
   bar.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, pos, globalAngle, globalWidth);
   bar.display(g);
   bar.sw(true);
   bar.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, pos, globalAngle, globalWidth);
   bar.display(g);
   pushMatrix();
    translate(width/2, height /2);
    rotate(globalRotation);
    tint(255, alpha1);
    image(g,bar.loc.x, bar.loc.y);
    popMatrix();
   }else{
   //background(hue2,brightness2, saturation2);
   bar.sw(false);
   bar.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, pos, globalAngle, globalWidth);
   bar.display(g);
   bar.sw(true);
   bar.update(hue2, brightness2, saturation2, hue1, saturation1, brightness1, alpha1, pos, globalAngle, globalWidth);
   bar.display(g);
   pushMatrix();
   translate(width/2, height /2);
   rotate(globalRotation);
   tint(255, alpha1);
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
    splitGrad.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, globalSpeed, globalWidth);
    splitGrad.display(g);
    splitGrad.sw(true);
    splitGrad.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, globalSpeed, globalWidth);
    splitGrad.display(g);
    pushMatrix();
    translate(width/2, height/2);
    rotate(globalAngle);
    tint(255, alpha1);
    image(g, -width /2, -height / 2);
    popMatrix();
   }else{
    splitGrad.sw(false);
    splitGrad.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, alpha1, globalSpeed, globalWidth);
    splitGrad.display(g);
    splitGrad.sw(true);
    splitGrad.update(hue2, brightness2, saturation2, hue1, saturation1, brightness1, alpha1, globalSpeed, globalWidth);
    splitGrad.display(g);
    pushMatrix();
    translate(width/2, height/2);
    rotate(globalAngle);
    tint(255, alpha1);
    image(g, -width / 2, -height / 2);
    popMatrix();
   }
  }
  
  if(modes.get(5)){
   PGraphics g = Layers.get(5);
   g.colorMode(HSB);
   g.beginDraw();
   int tmp3 = 18;
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
   tint(255, alpha1);
   image(g, 0, 0);
  }
  
  if(modes.get(6)){
   PGraphics g = Layers.get(6);
   g.beginDraw();
   g.colorMode(HSB);
   g.background(hue2, saturation2, brightness2, alpha1);
   color c = color(hue1, saturation1, brightness1, alpha1);
   f1.run(prevX, prevY, prevXmin, prevYmin, c, g);
   f2.run(prevX, prevY, prevXmax, prevYmax, c, g);
   g.endDraw();
   tint(255, alpha1);
   image(g,0,0);
  }
  
  if(modes.get(7)){
   PGraphics g = Layers.get(6);
   g.beginDraw();
   g.colorMode(RGB);
   colorMode(RGB);
   g.loadPixels();
   color c1 = color(hue1, saturation1, brightness1, alpha1);
   color c2 = color(hue2, saturation2, brightness2, alpha1);
   for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
     g.pixels[i + j * width] = lerpColor(c1, c2, map(sin(i * PI / 25), -1, 1, 0, 1.0));
    }
   }
   g.updatePixels();
   g.endDraw();
   tint(255, alpha1);
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

void firstTransition(){
  //switches from the resting effect to the first effect of the experience
  
}

void switchNext(){
   //switches from the first effect to the next effect
   
}

void switchOff(){
  //holdes the current effect and the resting position on sumultaneously
  
}

void readEffectFile(int i){
  //reads in data for an effect file
  String[] tmp = loadStrings(effectFiles[i]);
  hue1 = int(tmp[0]);
  saturation1 = int(tmp[1]);
  brightness1 = int(tmp[2]);
  hue2 = int(tmp[3]);
  saturation2 = int(tmp[4]);
  brightness2 = int(tmp[5]);
  splitSwitch = boolean(tmp[6]);
  colSwitch = boolean(tmp[7]);
  blackswitch = boolean(tmp[8]);
  reversed = boolean(tmp[9]);
  gridSwitch = boolean(tmp[10]);
  colorFlop = boolean(tmp[11]);
  globalAngle = float(tmp[12]);
  globalSpeed = float(tmp[13]);
  globalWidth = int(tmp[14]);
  globalRotation = float(tmp[15]);
  switchFrequency = int(tmp[16]);
  transition = int(tmp[17]);
  int lp = int(tmp[18]);
  for(int j = 0; j < lightPositions.length; j++){
     if(j != lp){
       lightPositions[j] = false; 
     }else{
       readLightFile(lightFiles[j]);
       lightPositions[j] = true; 
     }
  }
  int md = int(tmp[19]);
  for(int k = 0; k < modes.size(); k++){
     if(k != md){
       modes.set(k, false);
     }else{
       modes.set(k, true); 
     }
  }
  armsMode = boolean(tmp[20]);
  kinectColor = boolean(tmp[21]);
}

void saveEffectFile(){
  effectOutput = createWriter("effectFile1.txt");
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
  effectOutput.flush();
  effectOutput.close();
}