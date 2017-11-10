class GradientScan{
  
  //private variables for this object
  color c1;
  color c2;
  PVector loc;
  PVector vel;
  int w = 200;
  float angle = 0;
  
  //constructor
  GradientScan(){
    loc = new PVector(-width/2,-height/2);
    vel = new PVector(10, 0);
  }
  
  //update the info
  void update(int hu, int sat, int bri, int hu2, int sat2, int bri2, float sp, float an, int wid){
    c1 = color(hu, sat, bri);
    c2 = color(hu2, sat2, bri2);
    vel.x = sp;
    loc.add(vel);
    w = wid;
    //angle = an;
  }
  
  void display(PGraphics g){
    g.beginDraw();
    g.rotate(angle);
  for(int i = 0; i < w / 2; i++){
   g.stroke(c1);
   g.line(i, 0, i, g.height);
  }
  for(int i = w / 2; i < g.width / 2; i++){
      color c = lerpColor(c1, c2, map(i, w /2, g.width / 2, 0 , 1.0));
      g.stroke(c);
      g.line(i, 0, i, g.height);
  }
  for(int i = g.width / 2; i < g.width - w / 2; i++){
     color c = lerpColor(c2, c1, map(i, g.width / 2, g.width - w / 2, 0, 1.0));
     g.stroke(c);
     g.line(i, 0, i, g.height);
  }
  for(int i = g.width - w / 2; i < g.width; i++){
   g.stroke(c1);
   g.line(i, 0, i, g.height);
  }
  g.endDraw();
  }
}