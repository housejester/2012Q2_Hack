class RegionIngressViz {
  HBaseRegionServer regionServer;
  
  SingleRegionIngressView[] regions;
  int width;
  int x;
  int y;

  RegionIngressViz(HBaseRegionServer regionServer, int x, int y, int width, int height, int regionWidth, int regionGap, int speed, int particleBatchSize, int particleHeight){
    this.regionServer = regionServer;
    this.width = width;
    this.x = x;
    this.y = y;
    
    int numRegions = regionServer.regions.length;
    regions = new SingleRegionIngressView[numRegions];
    int fullRegionWidth = regionWidth + regionGap;
    for(int i=0; i<regions.length; i++){
      regions[i] = new SingleRegionIngressView(regionServer.regions[i], x+(i*fullRegionWidth), y, regionWidth, height, speed, particleBatchSize, particleHeight);
    }
  }

  void setup(){
    for(int i=0; i<regions.length;i++){
      regions[i].setup();
    }
  }

  void draw(){
    for(int i=0; i<regions.length;i++){
      regions[i].draw();
    }
    int numDashes = this.width/4;
    stroke(100);
    for(int i=0;i<numDashes;i++){
      line(x+(i*4),y+100,x+(i*4)+1,y+100);
    }
  }
}

class SingleRegionIngressView {
  int x;
  int y;
  int height;
  int width;
  int speed;
  int particleBatchSize;

  HBaseRegion region;
  ParticleStack memStore;
  ParticleStack storeFiles;
  ParticleStack compactedFiles;
  ParticleStack deletedFiles;
  
  SingleRegionIngressView(HBaseRegion region, int x, int y, int width, int height, int speed, int particleBatchSize, int particleHeight){
    this.region = region;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.speed = speed;
    this.particleBatchSize = particleBatchSize;
    
    memStore = new ParticleStack(x, width, speed, particleBatchSize, y, 200, particleHeight);
    storeFiles = new ParticleStack(x, width, speed/2, particleBatchSize*20, y+200, 200, particleHeight);
    compactedFiles = new ParticleStack(x, width, speed, particleBatchSize, y+400, 200, particleHeight);
    deletedFiles = new ParticleStack(x, width, speed, particleBatchSize, y+600, 200, particleHeight);
  }

  void setup(){
    memStore.setup();
    storeFiles.setup();
    compactedFiles.setup();
    deletedFiles.setup();
  }

  void draw(){
    memStore.setParticleCount(region.memStoreCount);
    if(region.flushing){
      fill(#FF0000);
      stroke(#FF0000);
    }else{
      fill(255);
      stroke(255);
    }
    memStore.draw();
    
    storeFiles.setParticleCount(region.storeFileCount);
    if(region.compacting){
      fill(#FF0000);
      stroke(#FF0000);
    }else{
      fill(255);
      stroke(255);
    }
    storeFiles.draw();
    compactedFiles.draw();
    deletedFiles.draw();
  }
}
