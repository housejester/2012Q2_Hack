HBaseRegionServer regionServer;
RegionIngressViz regionIngressViz;

int regionWidth = 10;
int gapWidth = 3;
int speed = 10;

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
  
  IngressSimulator sim = new IngressSimulator();
//  mobius(sim);
  oldSchool(sim);
  
  int numstacks = min(widgetWidth / fullRegionWidth, sim.regionsOnServer);
  
  int memStoreY = 0;
  
  println("num regions displayed: "+numstacks);

  particlesPerMilli = ((float)sim.particlesPerSecond / sim.numRegionServers)/1000;
  println("ppmilli="+particlesPerMilli);

  regionServer = new HBaseRegionServer(sim.regionsOnServer, numstacks, sim.avgParticleSize, 0, maxMemStoreAll, sim.schema);
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

void oldSchool(IngressSimulator sim){
  sim.particlesPerSecond = 40000;
  sim.totalRegions = 1024 * 8;
  sim.avgParticleSize = 2048 * 300;
  sim.regionsOnServer = (int)(sim.totalRegions/sim.numRegionServers);
  sim.schema = new OldSchoolSchema(sim.regionsOnServer);
}

void mobius(IngressSimulator sim){
  sim.particlesPerSecond = 4000;
  sim.totalRegions = 64*37;
  sim.avgParticleSize = 2048;
  sim.regionsOnServer = (int)(sim.totalRegions/sim.numRegionServers);
  sim.schema = new MobiusSchema(sim.regionsOnServer);
}

class IngressSimulator {
  int numRegionServers = 8;
  int particlesPerSecond = 4000;
  int totalRegions = 64 * 37;
  int avgParticleSize = 2048;
  int regionsOnServer = (int)(totalRegions/numRegionServers);
  HBaseSchema schema = new OldSchoolSchema(regionsOnServer);
}

