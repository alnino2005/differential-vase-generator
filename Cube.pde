class Cube extends Creator {
  Cube(Printer t_printer, Settings t_settings) {
    super(t_printer, t_settings);
  }
  void generate(float c_x, float c_y, float length_side_cube) {
    paths = new ArrayList<Path>();
    float tot_layers = length_side_cube / settings.layer_height;
    float angle_increment = TWO_PI / 4.0f;
    float z = 0;
    for (int layer = 0; layer<tot_layers; layer++) {
      z += settings.layer_height;
      paths.add(new Path());
      for (float angle = 0; angle<=TWO_PI; angle+=angle_increment) {
        float x = c_x + cos(angle) * length_side_cube;
        float y = c_y + sin(angle) * length_side_cube;
        PVector next_point = new PVector(x, y, z);
        paths.get(paths.size()-1).addPoint(next_point);
      }
    }
  }
}
