class HBaseRegion {
  int regionIndex;
  int memStorePutsCount;
  int storeFilePutsCount;
  boolean flushing;
  boolean compacting;
  ArrayList storeFiles;
  int ttlCount = 0;
  boolean fullTTL = false;
  
  HBaseRegion(int regionIndex){
    this.regionIndex = regionIndex;
    storeFiles = new ArrayList();
  }

  void addPuts(int count){
    memStorePutsCount += count;
    if(memStorePutsCount >= 100){
      requestFlush();
    }
  }

  void ttl(int ttlCount){
    this.ttlCount += ttlCount;
    if(this.ttlCount == this.storeFilePutsCount){
      fullTTL = true;
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
  
  void compactStores(long pause){
    long compactPutsCount = storeFilePutsCount;
    try{
      Thread.sleep(pause);
    }catch(Exception ex){}
    int remove =  (int)min(ttlCount, compactPutsCount);
    if(!fullTTL){
      remove = min(remove, (int)(compactPutsCount / 3));
    }
    storeFilePutsCount -= remove;
    ttlCount = 0;
    fullTTL = false;
    storeFiles.clear();
    compacting = false;
  }
  
  void requestCompaction(){
    compacting = true;
  }
}


