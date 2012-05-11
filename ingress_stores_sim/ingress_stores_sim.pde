HBaseRegionServer regionServer;
RegionIngressViz regionIngressViz;
ArrayList flushQueue;

int particlesPerSecond = 40000;
int totalRegions = 8000;
int numRegionServers = 8;
int regionWidth = 3;
int gapWidth = 3;
int speed = 20;
int particleBatchSize = 1;

int avgParticleSize = 4096;
int maxRenderedParticlesize = 64 * 1024 * 1024;
long maxMemStoreAll = 4 * 1024 * 1024 * 1024L;

float particlesPerMilli = 0;
long lastMilli = millis();

void setup() {
  flushQueue = new ArrayList();
  size(1324, 768);
  background(51);
  int margin = 10;

  int widgetWidth = width - margin;
  int widgetX = (int)((width-widgetWidth)/2);
  
  int fullRegionWidth = regionWidth+gapWidth;
  int numstacks = widgetWidth / fullRegionWidth;
  int memStoreY = 0;
  int maxRenderedParticles = 200;
  int particleHeight = 1;
  
  println("num regions displayed: "+numstacks);

  float pctRegions = (float)numstacks/totalRegions;
  particlesPerMilli = (particlesPerSecond * pctRegions) / 1000;
  println("ppmilli="+particlesPerMilli);

  regionServer = new HBaseRegionServer(totalRegions, numstacks, avgParticleSize, 50, maxMemStoreAll, flushQueue);
  regionIngressViz = new RegionIngressViz(regionServer, widgetX, 0, widgetWidth, height, regionWidth, gapWidth, speed, particleBatchSize, particleHeight);
  regionIngressViz.setup();
  
  thread("storeFlusher");
}

void storeFlusher() throws Exception{
  while(true){
    Thread.sleep(10);
    if(regionServer.isAboveGlobalMemThreshold()){
      println("above mem threshold");
      int largest = -1;
      int largestIndex = -1;
      for(int i=0;i<regionServer.regions.length;i++){
        if(regionServer.regions[i].memStoreCount > largest){
          largest = regionServer.regions[i].memStoreCount;
          largestIndex = i;
        }
      }
      if(largest != -1){
        regionServer.flushRegion(largestIndex);
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
    synchronized(flushQueue){
      if(flushQueue.size() > 0){
        regionServer.flushRegion((Integer)flushQueue.get(0));
        flushQueue.remove(0);
      }
    }
  }
}

void draw() {
  long nowMillis = millis();
  long millisSinceLast = nowMillis - lastMilli;
  lastMilli = nowMillis;

  int numP = ceil(particlesPerMilli * millisSinceLast);
  regionServer.addPuts(numP);
  regionIngressViz.draw();
}


