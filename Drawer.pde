class Drawer {
  Processor processor;
  Printer printer;
  Builder builder;
  Settings settings;
  Drawer(Processor t_processor, Printer t_printer, Builder t_builder, Settings t_settings) {
    processor = t_processor;
    printer = t_printer;
    builder = t_builder;
    settings = t_settings;
  }
  void display() {
    int paths_i = 0;
    int display_interp = 10;
    for (Path path : processor.paths) {
      paths_i = paths_i+1;
      stroke((float(paths_i) / float(processor.paths.size())) * 200 + 25,0, 50);
      strokeWeight(4);
      for (int i=0; i < path.vertices.size()-display_interp; i = i+display_interp) {
        PVector p1 = path.vertices.get(i);
        PVector p2 = path.vertices.get(i + display_interp);
        PVector b1 = new PVector(0, 0, 0);
        PVector b2 = new PVector(0, 0, 0);
        
        int layer = int((p1.z - builder.vase.cut_at_z) / settings.layer_height);
       
        
        if( dist(builder.vase.center_x + p1.x, builder.vase.center_y + p1.y, p1.z, builder.vase.center_x, builder.vase.center_y, p1.z) 
            < builder.vase.shapes.sphere(p1.z, builder.vase.hei, builder.vase.sphere_radius, builder.vase.sphere_z) //2D sphere distance from center only
            && p1.z > builder.vase.cut_at_z){ //Don't draw if below the bed
          b1 = p1.copy();
          b2 = p2.copy();
          
          line(
            builder.vase.center_x + b1.x,
            builder.vase.center_y + b1.y,
            b1.z - builder.vase.cut_at_z,
            builder.vase.center_x + b2.x, 
            builder.vase.center_y + b2.y,
            b2.z - builder.vase.cut_at_z
          );        
        }
        

        
      }
    }
  }

  void showPrinterChamber() { 
    pushMatrix();
    translate(printer.x_center_table, printer.y_center_table, 0);
    fill(200);
    stroke(0);
    rectMode(CENTER);
    rect(0, 0, printer.width_table, printer.length_table);
    rectMode(CORNER);
    translate(0, 0, printer.height_printer/2);
    noFill();
    box(printer.width_table, printer.length_table, printer.height_printer);
    popMatrix();
  }
}
