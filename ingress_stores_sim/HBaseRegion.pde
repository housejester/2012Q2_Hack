class HBaseRegion {
  int regionIndex;
  int memStoreCount;
  boolean flushing;
  boolean compacting;
  
  HBaseRegion(int regionIndex){
    this.regionIndex = regionIndex;
  }

  void display(){
  }
  
  void addPuts(int count){
    memStoreCount += count;
  }
  
  void requestFlush(){
    flushing = true;
  }
  
  void requestCompaction(){
    compacting = true;
  }
}

