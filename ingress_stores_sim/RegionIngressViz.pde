class RegionIngressViz {
  HBaseRegionServer regionServer;
  
  RegionIngressView[] regions;
  int width;
  int x;
  int y;

  RegionIngressViz(HBaseRegionServer regionServer, int x, int y, int width, int height, int regionWidth, int regionGap, int speed, int particleBatchSize, int particleHeight){
    this.regionServer = regionServer;
    this.width = width;
    this.x = x;
    this.y = y;
    
    int numRegions = regionServer.regions.length;
    regions = new RegionIngressView[numRegions];
    int fullRegionWidth = regionWidth + regionGap;
    for(int i=0; i<regions.length; i++){
      regions[i] = new RegionIngressView(regionServer.regions[i], x+(i*fullRegionWidth), y, regionWidth, height, speed, particleBatchSize, particleHeight);
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


