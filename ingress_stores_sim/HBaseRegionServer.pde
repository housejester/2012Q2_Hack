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
  
  HBaseRegionServer(int totalRegions, int visibleRegions, int avgPutSizeBytes, int compressionPct, long serverMemoryBytes, ArrayList flushQueue){
    this.totalRegions = totalRegions;
    this.visibleRegions = visibleRegions;
    this.avgPutSizeBytes = avgPutSizeBytes - (int)(avgPutSizeBytes * ((float)compressionPct/100.0));
    this.flushQueue = flushQueue;
    
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
  }
  
  void flushRegion(int index){
    HBaseRegion region = allRegions[index];
    totalPutsInMemory -= region.memStorePutsCount;
    region.flushMemStore(15);
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
  
}
