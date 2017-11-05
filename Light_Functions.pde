//light-related global variables
float currentAngle = 0.10;
float radius = 200.0;
float lightSpacing = 0.37;


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