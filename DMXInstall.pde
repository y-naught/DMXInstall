import dmxP512.*;
import processing.serial.*;
import themidibus.*;

MidiBus bus;

//declaring two sets of global color values
int hue1 = 0;
int saturation1 = 255;
int brightness1 = 255;
int alpha1 = 255;

int hue2 = 127;
int saturation2 = 255;
int brightness2 = 255;
int alpha2 = 255;

Boolean colSwitch = false;

//declaring global effect speed values
float globalAngle = 0;
float globalSpeed = 30;
int globalWidth = 0;


//light information for interface connectivity
DmxP512 dmxOutput;
int universeSize = 256;
String DMXPRO_PORT = "COM5";
int DMXPRO_BAUDRATE = 115000;
ArrayList<ThreeCh> Lights3Ch;
int numLights = 19;


//Declaring places for the effects to live
int numEffects = 1;
ArrayList<Boolean> modes;
ArrayList<PGraphics> Layers;

PGraphics gcom;
//declaring which effects we have
GradientScan gradScan;



void setup(){
  size(500,500, P2D);
  rectMode(CENTER);
  colorMode(HSB);
  frameRate(30);
  
  bus = new MidiBus(this, 0, -1);
  
   gcom = createGraphics(width,height,P2D);
  
  dmxOutput = new DmxP512(this, universeSize, false);
  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  
  Lights3Ch = new ArrayList<ThreeCh>();
  
  for(int i = 0; i < numLights; i++){
    PVector nextLoc = new PVector(radius * sin(currentAngle) + width / 2,radius * cos(currentAngle) + height / 2);
    Lights3Ch.add(new ThreeCh(i*3,nextLoc));
    currentAngle += (lightSpacing);
  }
  
  Layers = new ArrayList<PGraphics>();
  for(int i = 0; i < numEffects; i++){
   Layers.add(createGraphics(width, height, P2D));
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
}

void draw(){
  background(0);
  
  
  //Where the effects live
  if(modes.get(0)){
    PGraphics g = Layers.get(0);
    
    //PGraphics gcom = createGraphics(width,height,P2D);
    g.beginDraw();
    g.background(0);
    gradScan.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, globalSpeed, globalAngle, globalWidth);
    gradScan.display(g);
    if(gradScan.loc.x > width / 2){
      gradScan.loc.x = -width / 2  ;
    }
    g.endDraw();
    //g.beginDraw();
    //g.pushMatrix();
    pushMatrix();
    translate(width/2, height /2);
    rotate(globalAngle);
    //g.beginDraw();
    image(g,gradScan.loc.x,gradScan.loc.y);
    image(g,gradScan.loc.x - g.width, gradScan.loc.y);
    popMatrix();
    //g.endDraw();
    //g.popMatrix();
    //image(g,0,0);
  }
  
  
  
  
  
  //apply the effect to the lights
  for(int j = 0; j < modes.size(); j++){
    if(modes.get(j) == true){
      PGraphics g = Layers.get(j);
 
  for(int i = 1; i < Lights3Ch.size() * 3; i++){
    colorMode(HSB);
    ThreeCh l = Lights3Ch.get(i / 3);
    color c = l.sampleColor(g);
    dmxOutput.set(i, int(red(c)));
    i++;
    dmxOutput.set(i, int(green(c)));
    i++;
    dmxOutput.set(i, int(blue(c)));
    noStroke();
    fill(c);
    l.display();
   }
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
 if(note.pitch() == 56){
   for(int i = 0; i < modes.size(); i++){
    if(i == 0){
      Boolean m = modes.get(i);
      m = true;
      modes.set(i, m);
    }else{
      Boolean m = modes.get(i);
      m = false; 
      modes.set(i, m);
   }
  }
 }
 if(note.pitch() == 89){
   if(colSwitch == true){
    colSwitch = false;
   }
   else{
    colSwitch = true; 
  }
 }
}