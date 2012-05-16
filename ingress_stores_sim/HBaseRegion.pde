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
    synchronized(storeFiles){
      storeFiles.add(puts);
    }
    storeFilePutsCount += puts;
    memStorePutsCount -= puts;
    flushing = false;
    try{
      Thread.sleep(pause);
    }catch(Exception ex){}
  }
  
  void compactStores(long pause){
    long compactPutsCount = storeFilePutsCount;
    int lastStoreSize = 0;
    int numStores = 0;
    synchronized(storeFiles){
      numStores = storeFiles.size();
      lastStoreSize = (Integer)storeFiles.get(storeFiles.size()-1);
    }
    int remove =  (int)min(ttlCount, compactPutsCount);
    if(!fullTTL){
      remove = min(remove, (int)(compactPutsCount / 3));
    }else{
      remove = remove - (int)(lastStoreSize/2);
    }
    float ttlPct = (float)remove / compactPutsCount;
    float invTtlPct = 1 - ttlPct;
    //compactions are faster with more deletes
    long compactionTime = 10 + (long)invTtlPct * pause;
    
    try{
      Thread.sleep(compactionTime);
    }catch(Exception ex){}
    storeFilePutsCount -= remove;
    ttlCount = 0;
    fullTTL = false;
    synchronized(storeFiles){
      for(int i=numStores-1; i>0;i--){
        storeFiles.remove(i);
      }
    }
    compacting = false;
  }
  
  void requestCompaction(){
    compacting = true;
  }
}


