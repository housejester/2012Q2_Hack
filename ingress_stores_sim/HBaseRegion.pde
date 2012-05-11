class HBaseRegion {
  int regionIndex;
  int memStoreCount;
  int storeFileCount;
  boolean flushing;
  boolean compacting;
  
  HBaseRegion(int regionIndex){
    this.regionIndex = regionIndex;
  }

  void display(){
  }
  
  void addPuts(int count){
    memStoreCount += count;
    if(memStoreCount >= 100){
      requestFlush();
    }
  }
  
  void requestFlush(){
    flushing = true;
  }
 
  void flushMemStore(){
    storeFileCount += memStoreCount;
    memStoreCount = 0;
    flushing = false;
  }
  
  void requestCompaction(){
    compacting = true;
  }
}

