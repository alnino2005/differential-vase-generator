class Processor {
  ArrayList<Creator> objects = new ArrayList<Creator>();
  ArrayList<Path> paths;
  Processor addObject(Creator object) {
    objects.removeAll(objects);
    objects.add(object);
    return this;
  }
  
  void sortPaths() {
  paths = new ArrayList<Path>();
  //Put all the outlines of the objects in one ArrayList
  for (Creator obj : objects) {
    for (Path out : obj.paths) {

      paths.add(out);
      
    }
  }

}
}
