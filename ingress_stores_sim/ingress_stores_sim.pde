HBaseRegionServer regionServer;
RegionIngressViz regionIngressViz;

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

  regionServer = new HBaseRegionServer(regionsOnServer, numstacks, avgParticleSize, 50, maxMemStoreAll);
  regionIngressViz = new RegionIngressViz(regionServer, widgetX, 0, widgetWidth, height, regionWidth, gapWidth, speed);
  regionIngressViz.setup();
  
  thread("ingress");
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


