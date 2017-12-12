class SplitGradient{
  color c1;
  color c2;
  PVector loc;
  PVector vel;
  int w = 200;
  float angle = 0;
  Boolean type = false;
  Boolean colorFlip = false;
  
  PGraphics gTemp;
  
  SplitGradient(){
   loc = new PVector(-width/2, -height/2);
   vel = new PVector(10,0);
   gTemp = createGraphics(width+1000, height);
  }
  
  void update(int hu, int sat, int bri, int hu2, int sat2, int bri2, int alp, float sp, int wid){
    if(colorFlip == true){
      c1 = color(hu, sat, bri, alp);
      c2 = color(hu2, sat2, bri2, alp);
    }else{
      c2 = color(hu, sat, bri, alp);
      c1 = color(hu2, sat2, bri2, alp);
    }
    vel.x = sp;
    loc.add(vel);
    //w = wid;
    w = int(map(frameCount % wid, 1, wid, gTemp.width + 250, 1));
    if(frameCount % wid == 0){
     if(colorFlip == true){
      colorFlip = false; 
     }else{
      colorFlip = false; 
     }
    }
  }
  
  void display(PGraphics g){
   colorMode(RGB);
   gTemp.beginDraw();
   //gTemp.background(0, 10);
   for(int i = 0; i < w / 2; i++){
   if(type == true){
     gTemp.stroke(c1);
     gTemp.line(i, 0, i, gTemp.height/2);
   }else{
     gTemp.stroke(c1);
     gTemp.line(i, gTemp.height/2, i, gTemp.height);
   }
  }
  for(int i = w / 2; i < gTemp.width / 2; i++){
      color c = lerpColor(c1, c2, map(i, w /2, gTemp.width / 2, 0 , 1.0));
      if(type == true){
       gTemp.stroke(c);
       gTemp.line(i, 0, i, gTemp.height/2);
      }else{
       gTemp.stroke(c);
       gTemp.line(i, gTemp.height/2, i, gTemp.height);
      }
  }
  for(int i = gTemp.width / 2; i < gTemp.width - w / 2; i++){
     color c = lerpColor(c2, c1, map(i, gTemp.width / 2, gTemp.width - w / 2, 0, 1.0));
     gTemp.stroke(c);
     if(type == true){
       gTemp.line(i, 0, i, gTemp.height/2);
     }else{
       gTemp.line(i,gTemp.height/2, i, gTemp.height);
     }
  }
  for(int i = gTemp.width - w / 2; i < gTemp.width; i++){
     gTemp.stroke(c1);
   if(type == true){
     gTemp.line(i, 0, i, gTemp.height/2);
   }else{
     gTemp.line(i, gTemp.height/2, i, gTemp.height);
   }
  }
  gTemp.endDraw();
  g.beginDraw();
  //g.background(0);
  g.tint(255, 50);
  g.image(gTemp, -500, 0);
  g.endDraw();
  colorMode(HSB);
  }
  
  void sw(Boolean ty){
   type = ty; 
  }
  
  void checkEdges(){
   if(loc.x > width){
     
   }
  }
}