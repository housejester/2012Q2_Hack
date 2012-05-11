class HBaseRegionServer { 
  int totalRegions;
  int visibleRegions;
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
    
    float pctTotalServer = (float)visibleRegions / totalRegions;
    long memorySlice = (long)(serverMemoryBytes * pctTotalServer);
    memStoreItemThreshold = memorySlice / this.avgPutSizeBytes;
    println("pctTotalServer:"+pctTotalServer+",memorySlice:"+memorySlice+",memStoreItemThreshold = "+memStoreItemThreshold);
    
    regions = new HBaseRegion[visibleRegions];
    for(int i=0;i<visibleRegions;i++){
      regions[i] = new HBaseRegion(i);
    }
  }
  
  void flushRegion(int index){
    HBaseRegion region = regions[index];
    totalPutsInMemory -= region.memStoreCount;
    region.flushMemStore();
  }
  
  boolean isAboveGlobalMemThreshold(){
    return totalPutsInMemory > memStoreItemThreshold;
  }
  
  void addPuts(int numP){
    totalPutsInMemory += numP;
    for(int i=0;i<numP;i++){
      int which = (int)random(regions.length);
      boolean before = regions[which].flushing;
      regions[which].addPuts(1);
      if(!before && regions[which].flushing){
        //add 'which' to flush queue.
        synchronized(flushQueue){
          flushQueue.add(which);
        }
      }
    }
  }
  
}
