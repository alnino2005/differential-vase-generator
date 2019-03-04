class GcodeGenerator {
  
  ArrayList<String> gcode;
  Printer printer;
  Settings settings;
  Processor processor;
  float E = 0; // Left extruder
  GcodeGenerator(Printer t_printer, Settings t_settings, Processor t_processor) {
    printer = t_printer;
    settings = t_settings;
    processor = t_processor;
  }
  GcodeGenerator generate() {
    gcode = new ArrayList<String>();
    float extrusion_multiplier = 1;
    startPrint();
    for (Path path : processor.paths) {
     
      for (int i=0; i<path.vertices.size()-1; i++) {

        PVector p1 = path.vertices.get(i); //<>//
        PVector p2 = path.vertices.get(i+1);
        PVector b1 = p1.copy();
        PVector b2 = p2.copy();
        
        b1.z = b1.z - builder.vase.cut_at_z;
        b2.z = b2.z - builder.vase.cut_at_z;
        
        if(getLayerNumber(b1) == 0){
          
          if(i == 0){
            moveTo(b1);
            if (getLayerNumber(b1) < settings.start_fan_at_layer) {  //Print half speed until start_Fan_at_layer (3)
              setSpeed(settings.default_speed/2);
            } else if (getLayerNumber(b1) == settings.start_fan_at_layer) {  //Turn fan on, print normal speed
              setSpeed(settings.default_speed);
              enableFan();
            } else { //Fan stays on. Keep printing
              setSpeed(settings.default_speed);
            }
            
            extrusion_multiplier = getLayerNumber(b1) == 1 ? settings.extrusion_multiplier : 1;
          }
          

        }
         //<>//
        if( b1.z >= 0
         && dist(p1.x + builder.vase.center_x, p1.y + builder.vase.center_y, p1.z, builder.vase.center_x, builder.vase.center_y, p1.z) 
            <= builder.vase.shapes.sphere(p1.z, builder.vase.hei, builder.vase.sphere_radius, builder.vase.sphere_z)
         && dist(p2.x + builder.vase.center_x, p2.y + builder.vase.center_y, p2.z, builder.vase.center_x, builder.vase.center_y, p2.z) 
            <= builder.vase.shapes.sphere(p2.z, builder.vase.hei, builder.vase.sphere_radius, builder.vase.sphere_z)
        ){ //2D cone distance from center only 
        
          extrudeTo(b1, b2, extrusion_multiplier);
          
        }else if(b2.z >= 0
         && dist(builder.vase.center_x + p2.x, builder.vase.center_y + p2.y, p2.z, builder.vase.center_x, builder.vase.center_y, p2.z)
         < builder.vase.shapes.sphere(p2.z, builder.vase.hei, builder.vase.sphere_radius, builder.vase.sphere_z)   //2D cone distance from center only
        ){
          
          moveTo(b2);

        }           
  
      }
      
    }
    
    endPrint();
    return this;
    
  }
  int getLayerNumber(PVector p) {
    return (int)(p.z/settings.layer_height);
  }
  void write(String command) {
    gcode.add(command);
  }
  void moveTo(PVector p) {
    retract();
    write("G1 " + "X" + (builder.vase.center_x + p.x) + " Y" + (builder.vase.center_y + p.y) + " Z" + p.z + " F" + settings.travel_speed);
    recover();
  }
  void moveOnlyTo(PVector p) {
    write("G1 " + "X" + (builder.vase.center_x + p.x) + " Y" + (builder.vase.center_y + p.y) + " Z" + p.z + " F" + settings.travel_speed);
  }
  float extrude(PVector p1, PVector p2) {
    float points_distance = dist(p1.x, p1.y, p2.x, p2.y);
    float volume_extruded_path = settings.getExtrudedPathSection() * points_distance;
    float length_extruded_path = volume_extruded_path / settings.getFilamentSection();
    return length_extruded_path;
  }
  void extrudeTo(PVector p1, PVector p2, float extrusion_multiplier) {
    E+=(extrude(p1, p2) * extrusion_multiplier);
    write("G1 " + "X" + (builder.vase.center_x + p2.x) + " Y" + (builder.vase.center_y + p2.y) + " Z" + p2.z + " E" + E);
  }
  /*void extrudeTo(PVector p1, PVector p2, float extrusion_multiplier, float f) {
    E+=(extrude(p1, p2) * extrusion_multiplier);
    write("G1 " + "X" + p2.x + " Y" + p2.y + " Z" + p2.z + " E" + E + " F" + f);
  }*/
  void retract() {
    E-=settings.retraction_amount;
    write("G1" + " E" + E + " F" + settings.retraction_speed);
  }
  void recover() {
    E+=settings.retraction_amount;
    write("G1" + " E" + E + " F" + settings.retraction_speed);
  }
  void setSpeed(float speed) {
    write("G1 F" + speed);
  }
  void enableFan() {
    write("M 106");
  }
  void disableFan() {
    write("M 107");
  }
  void startPrint() {
    write("G91"); //Relative mode
    write("G1 Z1"); //Up one millimeter
    write("G28 X0 Y0"); //Home X and Y axes
    write("G90"); //Absolute mode
    write("G1 X" + printer.x_center_table + " Y" + printer.y_center_table + " F8000"); //Go to the center
    write("G28 Z0"); //Home Z axis
    write("G1 Z0"); //Go to height 0
    write("T0"); //Select extruder 1
    write("G92 E0"); //Reset extruder position to 0
  }
  void endPrint() {
    PVector last_position = processor.paths.get(processor.paths.size()-1).vertices.get(processor.paths.get(processor.paths.size()-1).vertices.size()-1);
    last_position.z = last_position.z - builder.vase.cut_at_z;
 
    retract(); //Retract filament to avoid filament drop on last layer
 
    //Facilitate object removal
    float end_Z;
    if (printer.height_printer - last_position.z > 10) {
     end_Z = last_position.z + 10;
    } else {
     end_Z = last_position.z + (printer.height_printer - last_position.z);
    }
    moveTo(new PVector(printer.x_center_table, printer.length_table - 10, end_Z));
    recover(); //Restore filament position
    write("M 107"); //Turn fans off
  }
  void export() {
    //Create a unique name for the exported file
    String name_save = "gcode_"+day()+""+hour()+""+minute()+"_"+second()+".g";
    //Convert from ArrayList to array (required by saveString function)
    String[] arr_gcode = gcode.toArray(new String[gcode.size()]);
    // Export GCODE
    saveStrings(name_save, arr_gcode);
  }
}
