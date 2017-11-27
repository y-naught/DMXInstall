//light-related global variables
float currentAngle = 0.10;
float radius = 200.0;
float lightSpacing = 0.33;


//a function to be able to rotate the lights about an axis
void lightArranger(ArrayList<ThreeCh> lights){
  for(int i = 0; i < lights.size(); i++){
    ThreeCh l = lights.get(i);
    if(mouseX > l.location.x - l.sz / 2 && mouseX < l.location.x + l.sz / 2 && mouseY > l.location.y - l.sz / 2 && mouseY- l.sz / 2 < l.location.y + l.sz / 2){
      l.move(mouseX, mouseY);
    }
  }
}

//a function to reset the lights to the original configuration
void lightReset(ArrayList<ThreeCh> lights){
 for(int i = 0; i < lights.size(); i ++){
   float x = radius * sin(-currentAngle) + width / 2;
   float y = radius * cos(-currentAngle) + height / 2;
   currentAngle += lightSpacing;
   ThreeCh l = lights.get(i);
   l.move(x, y);
 }
}

void lightBlackout(ArrayList<ThreeCh> lights){
 for(int i = 0; i < lights.size(); i++){
  ThreeCh l = lights.get(i);
    if(mouseX > l.location.x - l.sz / 2 && mouseX < l.location.x + l.sz / 2 && mouseY > l.location.y - l.sz / 2 && mouseY- l.sz / 2 < l.location.y + l.sz / 2){
      if(l.black == true){
       l.black = false; 
      }else{
       l.black = true; 
      }
    }
 }
}

void readLightFile(String s){
 String[] positions = loadStrings(s);
 for(int i = 0; i < numLights; i++){
   ThreeCh l = Lights3Ch.get(i);
   l.move(float(positions[i*3]),float(positions[i*3+1]));
   l.black = boolean(positions[i*3+2]);
 }
}

void saveLightPreset(){
  output = createWriter("positions4.txt");
  for(int i = 0; i < numLights; i++){
    ThreeCh l = Lights3Ch.get(i);
    output.println(l.location.x);
    output.println(l.location.y);
    output.println(l.black);
  }
  output.flush();
  output.close();
}