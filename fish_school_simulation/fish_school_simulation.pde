class Zoid {
  
  PVector location;
  PVector head_dir;
  float speed;
  float bl = 3.0;
  float mu_speed = 2.0;
  float max_cruise_speed = 4.0;
  float std_speed = 1.0;
  float max_speed = 25.0*bl*4.0;
  float rep_zone;
  float ori_zone;
  float attr_zone;
  boolean escape_mode = false;
  int in_escape_mode_for = 0;
  int max_frames_escape = 5;
  float pred_thresh; // dist predator detection
  
  Zoid(float x, float y, float rep_mult, float ori_mult, float attr_mult, float pred_mult, float body_length, float max_speed_mult) {
    bl = body_length/4.0;
    max_speed = max_speed_mult*bl*4.0;
    location = new PVector(x,y);
    head_dir = new PVector(random(1), random(1));
    head_dir.normalize();
    speed = (randomGaussian()*std_speed + mu_speed)*bl*4.0;
    rep_zone = bl*4.0*rep_mult;
    ori_zone = rep_zone*ori_mult;
    attr_zone = ori_zone*attr_mult;
    pred_thresh = pred_mult*bl*4.0;
  }
  
  void update_zones(float rep_mult, float ori_mult, float attr_mult) {
    rep_zone = bl*4.0*rep_mult;
    ori_zone = rep_zone*ori_mult;
    attr_zone = ori_zone*attr_mult;
  }
  
  PVector repulsion(ArrayList<Zoid> zoids) {
    PVector sum = new PVector(0,0);
    int count = 0;
    for (int i=0; i < zoids.size(); i++) {
      // compute distance between zoids
      Zoid other = zoids.get(i);
      float dist_bet = PVector.dist(location, other.location);
      if ((dist_bet > 0) && (dist_bet < rep_zone)) { // zone of repulsion
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        sum.add(diff);
        count ++;
      }
    }
    if (count > 0) {
      sum.div(count);
      sum.normalize();
    }
    return sum;
  }
  
  PVector orientation(ArrayList<Zoid> zoids) {
    PVector sum = new PVector(0.0,0.0);
    int count = 0;
    for (int i=0; i < zoids.size(); i++) {
      // compute distance between zoids
      Zoid other = zoids.get(i);
      float dist_bet = PVector.dist(location, other.location);
      if ((dist_bet >= rep_zone) && (dist_bet < ori_zone)) { // zone of orientation
        sum.add(other.head_dir);
        count ++;
      }
    }
    if (count > 0) {
      sum.div(count);
      sum.normalize();
    }
    return sum;
  }
  
  PVector attraction(ArrayList<Zoid> zoids) {
    PVector sum = new PVector(0.0,0.0);
    int count = 0;
    for (int i=0; i < zoids.size(); i++) {
      // compute distance between zoids
      Zoid other = zoids.get(i);
      float dist_bet = PVector.dist(location, other.location);
      if ((dist_bet >= ori_zone) && (dist_bet < attr_zone)) { // zone of orientation
        PVector diff = PVector.sub(other.location, location);
        diff.normalize();
        sum.add(diff);
        count ++;
      }
    }
    if (count > 0) {
      sum.div(count);
      sum.normalize();
    }
    return sum;
  }
  
  PVector school(ArrayList<Zoid> zoids) {
    PVector rep_vec = repulsion(zoids);
    PVector ori_vec = orientation(zoids);
    PVector attr_vec = attraction(zoids);
    PVector school_vec = new PVector(0,0);
    school_vec.add(rep_vec);
    school_vec.add(ori_vec);
    school_vec.add(attr_vec);
    school_vec.normalize();
    return school_vec;
  }
  
  float match_speed(ArrayList<Zoid> zoids) {
    float sum = 0;
    float count = 0;
    for (Zoid other: zoids) {
      // compute distance between zoids
      float dist_bet = PVector.dist(location, other.location);
      if ((dist_bet >= rep_zone) && (dist_bet < ori_zone)) { // zone of orientation
        sum += other.speed;
        count += 1.0;
      }
    }
    if (count > 0) {
      sum = sum/count;
    }
    return sum;
  }
  
  PVector update_escape_mode(PVector pred_loc) {
    PVector escape_dir = new PVector(0.0,0.0);
    float dist_bet = PVector.dist(location, pred_loc);
    if (dist_bet < pred_thresh && !escape_mode) {
      escape_mode = true;
    }
    if (escape_mode) {
      if (in_escape_mode_for <= max_frames_escape) { 
        escape_dir = PVector.sub(location, pred_loc);
        escape_dir.normalize();
        in_escape_mode_for ++;
      } else {
        escape_mode = false;
        in_escape_mode_for = 0;
      }
    }
    return escape_dir;
  }
  
  void update_state(ArrayList<Zoid> zoids, PVector pred_loc, boolean integrate) {
    PVector school_vec = school(zoids);
    PVector escape_vec = update_escape_mode(pred_loc);
    float new_speed = match_speed(zoids);
    if (new_speed != 0) {
      speed = constrain(new_speed, 0, max_cruise_speed*bl*4.0);
    }
    if (!escape_mode) {
      if (school_vec.mag() > 0) {
        head_dir = school_vec;
      }
    } else {
      speed = max_speed;
      if (!integrate) {
        head_dir = escape_vec;
      } else {
        PVector new_head_dir = school_vec;
        new_head_dir.add(escape_vec);
        if (new_head_dir.mag() > 0) {
          head_dir = new_head_dir;
          head_dir.normalize();
        } else {
          if (random(1) > 0.5) {
            head_dir.rotate(HALF_PI);
          } else {
            head_dir.rotate(-HALF_PI);
         }
        }
       }
      }
    }
    
  void update_position() {
    PVector velocity = PVector.mult(head_dir, speed*bl*2.0*(1/33.0));
    location = PVector.add(location, velocity);
    if (location.x < 0) {
      location.x = width;
    } 
    if (location.x > width) {
      location.x = 0;
    }
    if (location.y < 0) {
      location.y = height;
    }
    if (location.y > height) {
      location.y = 0;
    }
  }
  
  void display() {
    float theta = head_dir.heading() + PI/2;
    if (!escape_mode) {
      fill(175);
    } else {
      fill(255,0,0);
    }
    stroke(0);
    pushMatrix();
    translate(location.x,location.y);
    rotate(theta);
    beginShape();
    vertex(0, -bl*2);
    vertex(-bl, bl*2);
    vertex(bl, bl*2);
    endShape(CLOSE);
    popMatrix();
  }
}
