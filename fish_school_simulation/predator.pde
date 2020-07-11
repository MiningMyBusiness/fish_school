class predator {

  PVector location;
  float speed;
  PVector head_dir;
  float diam;
  
  
  predator() {
    location = new PVector(0,0);
    head_dir = new PVector(0,0);
    speed = 0.0;
    diam = 0.0;
  }
  
  void reset(PVector click1, PVector head, float cruise, float r) {
    location = click1;
    head_dir = head;
    speed = cruise;
    diam = r;
  }
  
  void update_location() {
    PVector velocity = PVector.mult(head_dir, speed);
    location.add(velocity);
  }
  
  void display() {
    fill(0);
    ellipse(location.x, location.y, diam, diam);
  }
  
}
