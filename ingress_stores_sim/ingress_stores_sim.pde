HBaseRegionServer regionServer;
RegionIngressViz regionIngressViz;
ArrayList flushQueue;

int particlesPerSecond = 40000;
int totalRegions = 1024 * 8;
int numRegionServers = 8;
int regionWidth = 10;
int gapWidth = 3;
int speed = 10;

int avgParticleSize = 2048 * 300;
int maxRenderedParticlesize = 64 * 1024 * 1024;
long maxMemStoreAll = 4 * 1024 * 1024 * 1024L;

float particlesPerMilli = 0;
long lastMilli = millis();

void setup() {
  flushQueue = new ArrayList();
  size(1324, 768);
  background(51);
  int margin = 0;

  int widgetWidth = width - margin;
  int widgetX = (int)((width-widgetWidth)/2);
  
  int fullRegionWidth = regionWidth+gapWidth;
  int regionsOnServer = totalRegions/numRegionServers;
  int numstacks = min(widgetWidth / fullRegionWidth, regionsOnServer);
  
  int memStoreY = 0;
  
  println("num regions displayed: "+numstacks);

  particlesPerMilli = ((float)particlesPerSecond / numRegionServers)/1000;
  println("ppmilli="+particlesPerMilli);

  regionServer = new HBaseRegionServer(regionsOnServer, numstacks, avgParticleSize, 50, maxMemStoreAll, flushQueue);
  regionIngressViz = new RegionIngressViz(regionServer, widgetX, 0, widgetWidth, height, regionWidth, gapWidth, speed);
  regionIngressViz.setup();
  
  thread("storeFlusher");
  thread("ingress");
}

void storeFlusher() throws Exception{
  while(true){
    if(regionServer.isAboveGlobalMemThreshold()){
      int largest = -1;
      int largestIndex = -1;
      for(int i=0;i<regionServer.regions.length;i++){
        if(regionServer.allRegions[i].memStorePutsCount > largest){
          largest = regionServer.allRegions[i].memStorePutsCount;
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
    if(flushQueue.size() > 0){
      regionServer.flushRegion((Integer)flushQueue.get(0));
      synchronized(flushQueue){
        flushQueue.remove(0);
      }
    }else{
      Thread.sleep(10);
    }
  }
}

void draw() {
  regionIngressViz.draw();
}

void ingress() throws Exception{
  while(true){
    long nowMillis = millis();
    long millisSinceLast = nowMillis - lastMilli;
    lastMilli = nowMillis;

    int numP = ceil(particlesPerMilli * millisSinceLast);
    regionServer.addPuts(numP);
    Thread.sleep(30);
  }
}


