import dmxP512.*;

//declaring two sets of global color values
int hue1 = 0;
int saturation1 = 255;
int brightness1 = 255;
int alpha1 = 255;

int hue2 = 127;
int saturation2 = 255;
int brightness2 = 255;
int alpha2 = 255;


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
int numLights = 17;


//Declaring places for the effects to live
int numEffects = 1;
ArrayList<Boolean> modes;
ArrayList<PGraphics> Layers;


//declaring which effects we have
GradientScan gradScan;



void setup(){
  size(500,500);
  rectMode(CENTER);
  colorMode(HSB);
  frameRate(30);
  
  
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
   Layers.add(createGraphics(width + 200, height + 200, P2D));
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
  
  
  
  //Where the effects live
  if(modes.get(0)){
    PGraphics g = Layers.get(0);
    g.background(0);
    gradScan.update(hue1, brightness1, saturation1, hue2, saturation2, brightness2, globalSpeed);
    gradScan.display(g, globalAngle, globalWidth);
    image(g,0,0);
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