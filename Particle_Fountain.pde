class Fountain{
  ArrayList<Particle> particles;
  PVector location;
  int count = 10;
  
  Fountain(float x, float y){
    location = new PVector(x, y);
    particles = new ArrayList<Particle>();
  }
  
  void run(float x, float y, float dirX, float dirY, color c, PGraphics g){
    location.x = x;
    location.y = y;
    for(int i = 0; i < count; i ++){
      particles.add(new Particle(x, y, dirX, dirY));
    }
    for(int i = 0; i < particles.size(); i++){
      Particle p = particles.get(i);
      p.update(c);
      p.display(g);
      if(p.dead){
       particles.remove(i); 
      }
    }
  }
}

class Particle{
 PVector location;
 PVector velocity;
 color c = color(0,0,0);
 float speed = 15;
 float size = random(15, 25);
 boolean dead = false;
 
 Particle(float x, float y, float dirX, float dirY){
   location = new PVector(x, y);
   velocity = new PVector(-(x - dirX + random(-20, 20)), y - 50 - dirY + random(-20, 20));
   velocity.normalize();
   velocity.mult(-speed);
 }
 
 void update(color Cnew){
  location.add(velocity);
  c = Cnew;
 }
 
 void display(PGraphics g){
   g.noStroke();
   g.fill(c);
   g.ellipse(location.x, location.y, size, size);
 }
 
 void checkEdges(){
  if(location.x < 0 || location.x > 500 || location.y < 0 || location.y > 500){
    dead = true;
  }
 }
}