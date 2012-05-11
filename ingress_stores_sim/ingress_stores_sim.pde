HBaseRegionServer regionServer;
RegionIngressViz regionIngressViz;

int particlesPerSecond = 14000;
int totalRegions = 8000;
int numRegionServers = 8;
int regionWidth = 3;
int gapWidth = 3;
int speed = 10;
int particleBatchSize = 1;

int avgParticleSize = 2048;//2 kbytes
int maxRenderedParticlesize = 64 * 1024 * 1024;//64 mb
long maxMemStoreAll = 8 * 1024 * 1024 * 1024L;

float particlesPerMilli = 0;
long lastMilli = millis();

void setup() {
  size(1324, 768);
  background(51);

  int widgetWidth = width - 88;
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

  regionServer = new HBaseRegionServer(totalRegions, numstacks);
  regionIngressViz = new RegionIngressViz(regionServer, widgetX, 0, widgetWidth, height, regionWidth, gapWidth, speed, particleBatchSize, particleHeight);
  regionIngressViz.setup();
}

void draw() {
  long nowMillis = millis();
  long millisSinceLast = nowMillis - lastMilli;
  lastMilli = nowMillis;

  int numP = ceil(particlesPerMilli * millisSinceLast);
  regionServer.addPuts(numP);
  regionIngressViz.draw();
}


