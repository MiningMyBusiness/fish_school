ArrayList<Zoid> zoids;
int num_zoids = 250;
boolean pred_exists = false;
boolean pred_create_state = false;
boolean clicked_once = false;
PVector first_click;
PVector second_click;

predator pred;
HScrollbar hs_rep, hs_ori, hs_attr;  // Two scrollbars
float hs_rep_start = 25;
float hs_ori_start = 250;
float hs_attr_start = 500;
int hs_width=200;

float body_length = 12.0;
float max_speed = 15.0; // max speed of zoid in body_lengths/sec
float pred_max_ratio = 0.5; // fraction of zoid max speed
float pred_body_length = body_length*3; // predator 

float rep_mult = 1.0; // number of body lengths radius of repulsion zone
float ori_mult = 1.0; // times larger than repulsion zone radius
float attr_mult = 1.0; // times larger than orientation zone radius
float pred_mult = 7.0; // number of body lengths at which predator is detected

void settings() {
  size(1280,720);
}

void setup() {
  frameRate(8);
  pred = new predator();
  zoids = new ArrayList<Zoid>();
  for (int i = 0; i < num_zoids; i++) {
    zoids.add(new Zoid(random(width),random(height),rep_mult,ori_mult,attr_mult,pred_mult,body_length,max_speed));
  }
  hs_rep = new HScrollbar(hs_rep_start,height-25,hs_width,16,1);
  hs_ori = new HScrollbar(hs_ori_start,height-25,hs_width,16,1);
  hs_attr = new HScrollbar(hs_attr_start,height-25,hs_width,16,1);
}

void draw() {
 background(3, 244, 252);
 
 textSize(20);
 fill(0);
 text("Repulsion zone size", hs_rep_start, height-40);
 float rep_pos = hs_rep.getPos();
 rep_mult = ((rep_pos - hs_rep_start)/float(hs_width))*5 + 1.0;
 hs_rep.update();
 hs_rep.display();
 
 fill(0);
 text("Orientation zone size", hs_ori_start, height-40);
 float ori_pos = hs_ori.getPos();
 ori_mult = ((ori_pos - hs_ori_start)/float(hs_width))*5 + 1.0;
 hs_ori.update();
 hs_ori.display();
 
 fill(0);
 text("Attraction zone size", hs_attr_start, height-40);
 float attr_pos = hs_attr.getPos();
 attr_mult = ((attr_pos - hs_attr_start)/float(hs_width))*5 + 1.0;
 hs_attr.update();
 hs_attr.display();
 
 textSize(24);
 fill(0);
 String show_text = "Repulsion: "+nf(rep_mult, 0, 2)+" body lengths || ";
 if (ori_mult > 1) {
   show_text += "Orientation: "+nf(rep_mult*ori_mult, 0, 2)+" body lengths || ";
 } else {
   show_text += "Orientation: N/A BLs || ";
 }
 if (attr_mult > 1) {
   show_text += "Attraction: "+nf(rep_mult*ori_mult*attr_mult, 0, 2)+" body lengths";
 } else {
   show_text += "Attraction: N/A BLs";
 }
 text(show_text, 25,25);
 PVector pred_loc = new PVector(-5000,-5000);
 if (pred_exists) {
   pred_loc = pred.location;
   pred.display();
   pred.update_location();
   if (pred.location.x < 0 || pred.location.x > width || pred.location.y < 0 || pred.location.y > height) {
     pred_exists = false;
   }
 }
 float speed_sum = 0.0;
 for (int i=0; i < zoids.size(); i++) {
   Zoid z = zoids.get(i);
   z.display();
   z.update_state(zoids, pred_loc, true);
   z.update_position();
   z.update_zones(rep_mult, ori_mult, attr_mult);
   speed_sum += z.speed;
 }
 
 speed_sum = speed_sum/float(zoids.size());
 textSize(15);
 fill(0);
 text("Avg. zoid speed: "+nf(speed_sum/body_length, 0, 2)+" body lengths/sec", width - 400, 60); 
 
 if (pred_create_state) {
   textSize(15);
   fill(0);
   text("Click for predator", width - 200, 75);
   if (clicked_once) {
     text("Registered first click", width - 200, 100);
   }
 }
 
}


void keyPressed() {
  if (key == 'p' || key == 'P') {
    pred_create_state = true;
  }
}


void keyReleased() {
  if (key == 'p' || key == 'P') {
    pred_create_state = false;
    clicked_once = false;
  }
}


void mouseClicked() {
  if (pred_create_state) {
    if (!clicked_once) {
      clicked_once = true;
      first_click = new PVector(mouseX, mouseY);
    } else {
      second_click = new PVector(mouseX, mouseY);
      PVector pred_heading = PVector.sub(second_click, first_click);
      pred_heading.normalize();
      pred.reset(first_click, pred_heading, body_length*max_speed*pred_max_ratio,pred_body_length);
      pred_exists = true;
    }
  }
}
