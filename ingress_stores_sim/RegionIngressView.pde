class RegionIngressView {
  int x;
  int y;
  int height;
  int width;
  int speed;

  HBaseRegion region;
  ParticleStack memStore;
  ParticleStack storeFiles;
  HBaseSchema schema;
  
  RegionIngressView(HBaseRegion region, int x, int y, int width, int height, int speed, HBaseSchema schema){
    this.region = region;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.speed = speed;
    this.schema = schema;
    
    memStore = new ParticleStack(x, width, speed, 1, y, 150, 1, 1, false);
    storeFiles = new ParticleStack(x, width, speed, 100, y+150, 180, 21, 5, true);
  }

  void setup(){
    memStore.setup();
    storeFiles.setup();
  }
  int lastStoreFileCount = 0;
  
  void draw(){
    memStore.setParticleCount(region.memStorePutsCount);
    if(region.flushing){
      fill(#FF0000);
      stroke(#FF0000);
    }else{
      fill(255);
      stroke(255);
    }
    memStore.draw();
    schema.decorateMemStore(region, memStore);
    
    if(lastStoreFileCount > region.storeFiles.size()){
      //storeFileCount different!  the region must have compacted.
      storeFiles.compact();
    }
    lastStoreFileCount=region.storeFiles.size();
    storeFiles.setParticleCount(region.storeFilePutsCount);
    
    if(region.compacting){
      fill(#FF0000);
      stroke(#FF0000);
    }else{
      fill(#FF9966);
      stroke(#FF9966);
    }
    storeFiles.draw();
    schema.decorateStoreFiles(region, storeFiles);
  }
}
