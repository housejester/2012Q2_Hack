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
    
    memStore = new ParticleStack(x, width, speed, particleBatchSize, y, 200, particleHeight);
    storeFiles = new ParticleStack(x, width, speed/2, particleBatchSize*20, y+200, 200, particleHeight*5);
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
      fill(#CC6600);
      stroke(#CC6600);
    }
    storeFiles.draw();
    compactedFiles.draw();
    deletedFiles.draw();
  }
}
