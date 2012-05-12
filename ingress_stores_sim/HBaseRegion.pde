class HBaseRegion {
  int regionIndex;
  int memStorePutsCount;
  int storeFilePutsCount;
  boolean flushing;
  boolean compacting;
  ArrayList storeFiles;
  
  HBaseRegion(int regionIndex){
    this.regionIndex = regionIndex;
    storeFiles = new ArrayList();
  }

  void display(){
  }
  
  void addPuts(int count){
    memStorePutsCount += count;
    if(memStorePutsCount >= 100){
      requestFlush();
    }
  }
  
  void requestFlush(){
    flushing = true;
  }
 
  void flushMemStore(long pause){
    int puts = memStorePutsCount;
    storeFiles.add(puts);
    storeFilePutsCount += puts;
    memStorePutsCount -= puts;
    flushing = false;
    try{
      Thread.sleep(pause);
    }catch(Exception ex){}
    if(storeFiles.size() > 3){
      compacting = true;
    }
  }
  
  void requestCompaction(){
    compacting = true;
  }
}

