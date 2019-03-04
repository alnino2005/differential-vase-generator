class Builder {
  Printer printer = new Printer();
  Settings settings = new Settings();
  Processor processor = new Processor();

  Drawer drawer;
  GcodeGenerator gcodeGenerator;
  //Vase vase;
  Differential vase;
  Builder() {
    println("Builder()");
    addCreator();
    update();
  }
  void addCreator() {
    //vase = new Vase(printer, settings, printer.x_center_table, printer.y_center_table);
    vase = new Differential(printer, settings, printer.x_center_table, printer.y_center_table);
    
    vase.generate();
    processor = new Processor();
    processor.addObject(vase);
    processor.sortPaths();

  }
  void update() {    

    drawer = new Drawer(processor, printer, builder, settings);
    //gcodeGenerator = new GcodeGenerator(printer, settings, processor);
  }
  void visualize() {
    drawer.showPrinterChamber();
    drawer.display();
  }
  void exportGcode() {
    gcodeGenerator = new GcodeGenerator(printer, settings, processor);
    gcodeGenerator.generate().export();
  }
}


void setGui() {
  cp5.setAutoDraw(false);
  float start_X = 10;
  float inc_X = 10;
  float start_Y = 10;
  float inc_Y = 10;
  cp5.addSlider("center_x")               .setPosition(start_X, start_Y+=inc_Y).setRange(0, builder.printer.width_table).setCaptionLabel("Center X").setColorCaptionLabel(100).setValue(builder.printer.width_table / 2);
  cp5.addSlider("center_y")               .setPosition(start_X, start_Y+=inc_Y).setRange(0, builder.printer.length_table).setCaptionLabel("Center Y").setColorCaptionLabel(100).setValue(builder.printer.length_table / 2);
  
  cp5.addSlider("cut_at_z")               .setPosition(start_X, start_Y+=2*inc_Y).setRange(0, builder.printer.height_printer).setCaptionLabel("Cut at Z").setColorCaptionLabel(100).setValue(builder.vase.cut_at_z);

  cp5.addSlider("sphere_z")               .setPosition(start_X, start_Y+=2*inc_Y).setRange(builder.printer.height_printer * -1, builder.printer.height_printer).setCaptionLabel("Sphere Z").setColorCaptionLabel(100).setValue(builder.printer.height_printer / 2);
  cp5.addSlider("sphere_radius")          .setPosition(start_X, start_Y+=inc_Y).setRange(builder.printer.width_table * -1, builder.printer.width_table).setCaptionLabel("Sphere Radius").setColorCaptionLabel(100).setValue(builder.printer.width_table / 2);

  cp5.addButton("Regenerate").setPosition(10, height-100).setHeight(40).setWidth(int(0.2*width)-10).setColorLabel(10).setColorBackground(color(0, 200, 0));
  cp5.addButton("Export GCODE").setPosition(10, height-50).setHeight(40).setWidth(int(0.2*width)-10).setColorLabel(10).setColorBackground(color(0, 200, 0));
}
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) { 
    if (theEvent.getController().getName()=="center_x") {
      builder.vase.setCenter(cp5.getController("center_x").getValue(), builder.vase.center_y);
      builder.update();
    } else if (theEvent.getController().getName()=="center_y") {
      builder.vase.setCenter(builder.vase.center_x, cp5.getController("center_y").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="cut_at_z") {
      builder.vase.setCutAtZ(cp5.getController("cut_at_z").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="sphere_z") {
      builder.vase.setSphere(cp5.getController("sphere_z").getValue(), builder.vase.sphere_radius);
      builder.update();
    } else if (theEvent.getController().getName()=="sphere_radius") {
      builder.vase.setSphere(builder.vase.sphere_z, cp5.getController("sphere_radius").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="Regenerate") {
      builder.vase.generate();
      builder.processor = new Processor();
      builder.processor.addObject(builder.vase);
      builder.processor.sortPaths();
      builder.update();
    } else if (theEvent.getController().getName()=="Export GCODE") {
      builder.exportGcode();
    }
  }
}
