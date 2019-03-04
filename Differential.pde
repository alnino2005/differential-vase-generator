class Differential extends Creator {
  ArrayList<Node> nodes;
  
  float center_x;
  float center_y;
  float hei = 50;
  float cut_at_z = 0;
  
  float sphere_z = printer.height_printer / 2;
  float sphere_radius = printer.width_table / 2;

  float _maxForce = 0.9; // Maximum steering force
  float _maxSpeed = 1; // Maximum speed
  float _desiredSeparation = 80;
  float _separationCohesionRation = 1.1;
  float _maxEdgeLen = 5;

  float base_mult = 2;
  float overall_mult = 0.2;
  

  
  /*float _maxForce = 0.9; // Maximum steering force
float _maxSpeed = 1; // Maximum speed
float _desiredSeparation = 9;
float _separationCohesionRation = 1.1;
float _maxEdgeLen = 5;
*/
  DifferentialLine _diff_line;  
  Shapes shapes;

  
  //From Creator, just to make this work
  float len = 10;
  float wid = 10;
  int sides = 4;
  float tot_layers = 0;
  float increment_rotation = 0;
  float amount_oscillation_XY = 0;
  float increment_oscillation_XY = 0;
  float amount_oscillation_Z = 0;
  float increment_oscillation_Z = 0;
  int array_loc = 0;
  float array_oscillation_multiplier_XY = 1;
  float amount_array_oscillation_XY = 0;
  float array_bet_layer_progress = 0;
  String[] array_values = loadStrings(dataPath("")+"/data.txt");

  Differential(Printer t_printer, Settings t_settings, float c_x, float c_y) {
    super(t_printer, t_settings);
    center_x = c_x;
    center_y = c_y;
  }
  
  void generate() {
    println("Generate");

    paths = new ArrayList<Path>();
    
    float z = 0;

    tot_layers = hei / settings.layer_height;
    
    float nodesStart = 20;
    float angInc = TWO_PI/nodesStart;
    _diff_line = new DifferentialLine(_maxForce, _maxSpeed, _desiredSeparation, _separationCohesionRation, _maxEdgeLen);
    shapes = new Shapes();
    for (float a=0; a<TWO_PI; a+=angInc) {
      _diff_line.addNode(new Node(0, 0, _diff_line.maxForce, _diff_line.maxSpeed, _diff_line.desiredSeparation, _diff_line.separationCohesionRation));
    }


    for (int layer = 0; layer<tot_layers; layer++) {
      println("Layer: "+layer+"/"+tot_layers+" (" + (float(layer)/tot_layers)*hei + ")");
      _diff_line.run();
      z += settings.layer_height;

      Path new_path = new Path();
      for (int current_point = 0; current_point < nodes.size(); current_point++) {
        float x;
        float y;
        
        if(current_point == nodes.size() - 1){
          x = nodes.get(0).position.x * (((((float(layer)/tot_layers) * base_mult) - base_mult) * -1 ) + 1) * overall_mult;
          y = nodes.get(0).position.y * (((((float(layer)/tot_layers) * base_mult) - base_mult) * -1 ) + 1) * overall_mult;
        }else{
          x = nodes.get(current_point).position.x * (((((float(layer)/tot_layers) * base_mult) - base_mult) * -1 ) + 1) * overall_mult;
          y = nodes.get(current_point).position.y * (((((float(layer)/tot_layers) * base_mult) - base_mult) * -1 ) + 1) * overall_mult;
        }         
        

        PVector next_point = new PVector(x, y, z);
        new_path.addPoint(next_point); 


        
      
      }

      paths.add(new_path);

    }
    
  }
  
  class Shapes{
    
    float cone(int z, float hei, float wid){
   
      return (((z/hei) -1) * -1) * wid;
   
    }
    float sphere(float z, float hei, float radius, float sphere_z){
      return ((cos(asin( (z/hei) )) * radius) + sphere_z);
   
    }
  }
  
  
  class DifferentialLine {
    float maxForce;
    float maxSpeed;
    float desiredSeparation;
    float separationCohesionRation;
    float maxEdgeLen;
    DifferentialLine(float mF, float mS, float dS, float sCr, float eL) {
      nodes = new ArrayList<Node>();
      maxSpeed = mF;
      maxForce = mS;
      desiredSeparation = dS;
      separationCohesionRation = sCr;
      maxEdgeLen = eL;
    }
    void run() {
      for (Node n : nodes) {
        n.run(nodes);
      }
      growth();
    }
    void addNode(Node n) {
      nodes.add(n);
    }
    void addNodeAt(Node n, int index) {
      nodes.add(index, n);
    }
    void growth() {
      for (int i=0; i<nodes.size()-1; i++) {
        Node n1 = nodes.get(i);
        Node n2 = nodes.get(i+1);
        float d = PVector.dist(n1.position, n2.position);
        if (d>maxEdgeLen) { // Can add more rules for inserting nodes
          int index = nodes.indexOf(n2);
          PVector middleNode = PVector.add(n1.position, n2.position).div(2);
          addNodeAt(new Node(middleNode.x, middleNode.y, maxForce, maxSpeed, desiredSeparation, separationCohesionRation), index);
        }
      }
    }


  }
  
  class Node {
    PVector position;
    PVector velocity;
    PVector acceleration;
    float maxForce;
    float maxSpeed;
    float desiredSeparation;
    float separationCohesionRation;
    Node(float x, float y) {
      acceleration = new PVector(0, 0);
      velocity =PVector.random2D();
      position = new PVector(x, y);
    }
    Node(float x, float y, float mF, float mS, float dS, float sCr) {
      acceleration = new PVector(0, 0);
      velocity =PVector.random2D();
      position = new PVector(x, y);
      maxSpeed = mF;
      maxForce = mS;
      desiredSeparation = dS;
      separationCohesionRation = sCr;
    }
    void run(ArrayList<Node> nodes) {
      differentiate(nodes);
      update();
      //render();
    }
    void applyForce(PVector force) {
      acceleration.add(force);
    }
    void differentiate(ArrayList<Node> nodes) {
      PVector separation = separate(nodes);
      PVector cohesion = edgeCohesion(nodes);
      separation.mult(separationCohesionRation);
      //cohesion.mult(1.0);
      applyForce(separation);
      applyForce(cohesion);
    }
    void update() {
      velocity.add(acceleration);
      velocity.limit(maxSpeed);
      position.add(velocity);
      acceleration.mult(0);
    }
    PVector seek(PVector target) {
      PVector desired = PVector.sub(target, position);
      desired.setMag(maxSpeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxForce);
      return steer;
    }
    void render() {
      fill(0);
      ellipse(position.x, position.y, 2, 2);
    }
    PVector separate(ArrayList<Node> nodes) {
      PVector steer = new PVector(0, 0);
      int count = 0;
      for (Node other : nodes) {
        float d = PVector.dist(position, other.position);
        if (d>0 && d < desiredSeparation) {
          PVector diff = PVector.sub(position, other.position);
          diff.normalize();
          diff.div(d); // Weight by distance
          steer.add(diff);
          count++;
        }
      }
      if (count>0) {
        steer.div((float)count);
      }
      if (steer.mag() > 0) {
        steer.setMag(maxSpeed);
        steer.sub(velocity);
        steer.limit(maxForce);
      }
      return steer;
    }
    PVector edgeCohesion (ArrayList<Node> nodes) {
      PVector sum = new PVector(0, 0);      
      int this_index = nodes.indexOf(this);
      if (this_index!=0 && this_index!=nodes.size()-1) {
        sum.add(nodes.get(this_index-1).position).add(nodes.get(this_index+1).position);
      } else if (this_index == 0) {
        sum.add(nodes.get(nodes.size()-1).position).add(nodes.get(this_index+1).position);
      } else if (this_index == nodes.size()-1) {
        sum.add(nodes.get(this_index-1).position).add(nodes.get(0).position);
      }
      sum.div(2);
      return seek(sum);
    }
  }

  Differential setCenter(float x, float y) {
    center_x = constrain(x, 0, printer.width_table);
    center_y = constrain(y, 0, printer.length_table);
    return this;
  }
  
  Differential setCutAtZ(float z) {
    cut_at_z = z;
    return this;
  }
  
  Differential setSphere(float z, float radius) {
    sphere_z = z;
    sphere_radius = radius;
    return this;
  }
  
  
}
