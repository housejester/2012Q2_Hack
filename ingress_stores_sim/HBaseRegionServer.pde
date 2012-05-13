class HBaseRegionServer { 
  int totalRegions;
  int visibleRegions;
  HBaseRegion[] allRegions;
  HBaseRegion[] regions;
  long totalPutsInMemory;
  int avgPutSizeBytes;
  long serverMemoryBytes;
  long memStoreItemThreshold;
  ArrayList flushQueue;
  ArrayList compactionQueue;
  
  HBaseRegionServer(int totalRegions, int visibleRegions, int avgPutSizeBytes, int compressionPct, long serverMemoryBytes){
    this.totalRegions = totalRegions;
    this.visibleRegions = visibleRegions;
    this.avgPutSizeBytes = avgPutSizeBytes - (int)(avgPutSizeBytes * ((float)compressionPct/100.0));
    this.flushQueue = new ArrayList();
    this.compactionQueue = new ArrayList();
    
    memStoreItemThreshold = serverMemoryBytes / this.avgPutSizeBytes;
    println("memStoreItemThreshold = "+memStoreItemThreshold);
    
    allRegions = new HBaseRegion[totalRegions];
    regions = new HBaseRegion[visibleRegions];
    println("totalRegions:"+totalRegions+",visibleRegions:"+visibleRegions+",allRegions.length:"+allRegions.length);
    for(int i=0;i<totalRegions;i++){
      allRegions[i] = new HBaseRegion(i);
      if(i<visibleRegions){
        regions[i] = allRegions[i];
      }
    }
    (new Thread( new StoreFlusher(this, 20) )).start();
    (new Thread( new StoreCompactor(this, 20) )).start();
  }
  
  void flushRegion(int index){
    HBaseRegion region = allRegions[index];
    totalPutsInMemory -= region.memStorePutsCount;
    region.flushMemStore(15);
    if(!region.compacting && region.storeFiles.size() >= 3){
      region.compacting = true;
      synchronized(compactionQueue){
        compactionQueue.add(region.regionIndex);
      }
    }
  }

  void compactRegion(int index){
    HBaseRegion region = allRegions[index];
    region.compactStores(30);
  }
  
  boolean isAboveGlobalMemThreshold(){
    return totalPutsInMemory > memStoreItemThreshold;
  }
  
  void addPuts(int numP){
    totalPutsInMemory += numP;
    for(int i=0;i<numP;i++){
      int which = (int)random(allRegions.length);
      boolean before = allRegions[which].flushing;
      allRegions[which].addPuts(1);
      if(!before && allRegions[which].flushing){
        //add 'which' to flush queue.
        synchronized(flushQueue){
          flushQueue.add(which);
        }
      }
    }
  }
  
  boolean compactCheck(){
    if(compactionQueue.size() > 0){
      compactRegion((Integer)compactionQueue.get(0));
      synchronized(compactionQueue){
        compactionQueue.remove(0);
      }
      return true;
    }
    return false;
  }
  
  boolean flushCheck(){
    if(isAboveGlobalMemThreshold()){
      int largest = -1;
      int largestIndex = -1;
      for(int i=0;i<allRegions.length;i++){
        if(allRegions[i].memStorePutsCount > largest){
          largest = allRegions[i].memStorePutsCount;
          largestIndex = i;
        }
      }
      if(largest != -1){
        flushRegion(largestIndex);
        synchronized(flushQueue){
          boolean done = false;
          for(int i=flushQueue.size()-1;!done && i>=0; i--){
            if((Integer)flushQueue.get(i) == largestIndex){
              flushQueue.remove(i);
              done=true;
            }
          }
        }
      }
    }
    if(flushQueue.size() > 0){
      flushRegion((Integer)flushQueue.get(0));
      synchronized(flushQueue){
        flushQueue.remove(0);
      }
      return true;
    }
    return false;
  } 
}

class StoreFlusher implements Runnable{
  HBaseRegionServer regionServer;
  long sleepInterval;
  StoreFlusher(HBaseRegionServer regionServer, long sleepInterval){
    this.regionServer = regionServer;
    this.sleepInterval = sleepInterval;
  }    
  void run() {
    while(true){
      if(!regionServer.flushCheck()){
        try{
          Thread.sleep(sleepInterval);
        }catch(Exception ex){}
      }
    }
  }
}

class StoreCompactor implements Runnable{
  HBaseRegionServer regionServer;
  long sleepInterval;
  StoreCompactor(HBaseRegionServer regionServer, long sleepInterval){
    this.regionServer = regionServer;
    this.sleepInterval = sleepInterval;
  }    
  void run() {
    while(true){
      if(!regionServer.compactCheck()){
        try{
          Thread.sleep(sleepInterval);
        }catch(Exception ex){}
      }
    }
  }
}

