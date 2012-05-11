HBaseRegion[] regions;

int particlesPerSecond = 4000;
int totalRegions = 8000;
int avgParticleSize = 2048;//2 kbytes
int maxRenderedParticlesize = 64 * 1024 * 1024;//64 mb
int numRegionServers = 8;
long maxMemStoreAll = 8 * 1024 * 1024 * 1024L;
float particlesPerMilli = 0;
long lastMilli = millis();

void setup() {
  size(1324, 768);
  background(51);

  int regionWidth = 3;
  int gapWidth = 3;

  int speed = 10;
  int particleBatchSize = 1;
  int fullRegionWidth = regionWidth+gapWidth;
  int numstacks = width / fullRegionWidth;
  int memStoreY = 0;
  int maxRenderedParticles = 200;
  int particleHeight = 1;
  
  println("num regions displayed: "+numstacks);

  float pctRegions = (float)numstacks/totalRegions;
  particlesPerMilli = (particlesPerSecond * pctRegions) / 1000;
  println("ppmilli="+particlesPerMilli);

  regions = new HBaseRegion[numstacks];
  for(int i=0;i<numstacks;i++){
    regions[i] = new HBaseRegion((i*fullRegionWidth)+gapWidth, memStoreY, regionWidth, maxRenderedParticles, speed, particleBatchSize, particleHeight); 
  }

}

void draw() {
  long nowMillis = millis();
  long millisSinceLast = nowMillis - lastMilli;
  lastMilli = nowMillis;

  int numP = ceil(particlesPerMilli * millisSinceLast);
  for(int i=0;i<numP;i++){
    int which = (int)random(regions.length);
    regions[which].addArticles(1);
  }
  
  for(int i=0;i<regions.length;i++){
    regions[i].display();
  }
  int numDashes = width/4;
  stroke(100);
  for(int i=0;i<numDashes;i++){
    line(i*4,100,(i*4)+1,100);
  }
}


