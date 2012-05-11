class HBaseRegionServer { 
  int totalRegions;
  int visibleRegions;
  HBaseRegion[] regions;
  long totalPutsInMemory;
  
  HBaseRegionServer(int totalRegions, int visibleRegions){
    this.totalRegions = totalRegions;
    this.visibleRegions = visibleRegions;
    regions = new HBaseRegion[visibleRegions];
    for(int i=0;i<visibleRegions;i++){
      regions[i] = new HBaseRegion(i);
    }
  }
  
  void addPuts(int numP){
    totalPutsInMemory += numP;
    for(int i=0;i<numP;i++){
      int which = (int)random(regions.length);
      regions[which].addPuts(1);
    }
    if(totalPutsInMemory > 1000){
      int which = (int)random(regions.length);
      regions[which].requestFlush();
    }
  }
  
}
