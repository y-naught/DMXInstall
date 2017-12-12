class GradientScan2{

  //private variables for this object
  color c1;
  color c2;
  PVector loc;
  PVector vel;
  int w = 200;
  float angle = 0;
  Boolean type = false;
  Boolean barOn = false;
  
  //constructor
  GradientScan2(Boolean t){
    loc = new PVector(-width/2,-height/2);
    type = t;
  }
  
  //update the info
  void update(int hu, int sat, int bri, int hu2, int sat2, int bri2, int alp, float pos, float an, int wid){
    if(type == true){
      c1 = color(hu, sat, bri, alp);
      c2 = color(hu2, sat2, bri2, alp);
    }else{
      c2 = color(hu, sat, bri, alp);
      c1 = color(hu2, sat2, bri2, alp);
    }
    loc.x = pos;
    w = wid;
    //angle = an;
  }
  
  void display(PGraphics g){
    colorMode(RGB);
    g.beginDraw();
    g.rotate(angle);
  for(int i = 0; i < w / 2; i++){
     g.stroke(c1);
     if(type == true){
       g.line(i, 0, i, g.height/2);
     }else{
       g.line(i, g.height/2, i, g.height);
     }
  }
  
  for(int i = w / 2; i < g.width / 2; i++){
    color c;
      c = lerpColor(c1, c2, map(i, w /2, g.width / 2, 0 , 1.0));
      g.stroke(c);
      if(type == true){
       g.line(i, 0, i, g.height/2);
     }else{
       g.line(i, g.height/2, i, g.height);
     }
  }
  
  for(int i = g.width / 2; i < g.width - w / 2; i++){
    color c;
      c = lerpColor(c2, c1, map(i, g.width / 2, g.width - w / 2, 0, 1.0));
      g.stroke(c);
      if(type == true){
       g.line(i, 0, i, g.height/2);
     }else{
       g.line(i, g.height/2, i, g.height);
     }
  }
  for(int i = g.width - w / 2; i < g.width; i++){
    g.stroke(c1);
    if(type == true){
       g.line(i, 0, i, g.height/2);
     }else{
       g.line(i, g.height/2, i, g.height);
     }
  }
  g.endDraw();
  colorMode(HSB);
  }
  
  void sw(Boolean ty){
   type = ty; 
  }
}