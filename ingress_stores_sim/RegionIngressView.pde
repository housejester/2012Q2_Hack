class RegionIngressView {
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
  
  RegionIngressView(HBaseRegion region, int x, int y, int width, int height, int speed, int particleBatchSize, int particleHeight){
    this.region = region;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.speed = speed;
    this.particleBatchSize = particleBatchSize;
    
    memStore = new ParticleStack(x, width, speed, 1, y, 200, 1, 1, false);
    storeFiles = new ParticleStack(x, width, speed, 100, y+200, 200, 21, 5, true);
    compactedFiles = new ParticleStack(x, width, speed, particleBatchSize, y+400, 200, 1, 1, false);
    deletedFiles = new ParticleStack(x, width, speed, particleBatchSize, y+600, 200, 1, 1, false);
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
      fill(#CC6600);
      stroke(#CC6600);
    }
    storeFiles.draw();
    compactedFiles.draw();
    deletedFiles.draw();
  }
}
