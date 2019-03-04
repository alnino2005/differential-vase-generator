import java.util.Collections;
import java.util.Comparator; 
import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
PeasyCam cam; // Peasy cam for 3d views
import controlP5.*;
ControlP5 cp5; // Control P5 for GUI
Builder builder;
void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 800);
  //cam.lookAt(-169, -115, 91, 0);
  //cam.setDistance(1);
  //cam.setRotations(1.55, -1, 3.12);
  builder = new Builder();
  // Initialize Control P5
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  setGui();

}
void draw() {
  background(255);
  builder.visualize();
  
  gui();

}

// ENABLE CONTOLP5 WITH PEASYCAM
void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  if (cp5.isMouseOver()) {
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}
