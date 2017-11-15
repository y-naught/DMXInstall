class HardFlip{
  float angle = 0;
  color c1;
  color c2;
  
  HardFlip(){
    c1 = color(255,255,255);
    c2 = color(235,255,255);
  }
  
  void update(float ang, int hu, int sat, int bri, int hu2, int sat2, int bri2){
    c1 = color(hu, sat, bri);
    c2 = color(hu2, sat2, bri2);
    angle = ang;
  }
  
  void display(PGraphics g){
    g.beginDraw();
    g.translate(g.width / 2, g.height / 2);
    g.rotate(angle);
    g.noStroke();
    g.fill(c1);
    g.rect(-width / 2, -height / 2, width / 2, height);
    g.fill(c2);
    g.rect(0, -height / 2, width / 2, height);
    
    g.endDraw();
  }
}