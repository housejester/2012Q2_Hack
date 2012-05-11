ParticleStack[] stacks;

int particlesPerSecond = 4000;
float particlesPerFrame;
int totalRegions=8000;
int avgParticleSize=2048;//2 kbytes
int maxRenderedParticlesize=64 * 1024 * 1024;//64 mb
int numRegionServers = 8;
long maxMemStoreAll=8*1024*1024*1024L;

void setup() {
  size(1324, 768);
  background(51);
  stroke(100);
  line(0, 200, width, 200);
  line(0, 400, width, 400);
  line(0, 600, width, 600);
  line(0, 800, width, 800);
  
  int regionWidth = 3;
  int gapWidth = 3;

  int speed = 3;
  int particleBatchSize = 1;
  int fullRegionWidth = regionWidth+gapWidth;
  int numstacks = width / fullRegionWidth;
  int memStoreY = 0;
  int numRenderedParticles = 200;
  int particleHeight = 1;
  
  println("num regions displayed: "+numstacks);

  particlesPerFrame = (particlesPerSecond/frameRate);
  println("frameRate:"+frameRate+",pps:"+particlesPerSecond+",ppf:"+particlesPerFrame);
  float pctRegions = (float)numstacks/totalRegions;
  particlesPerFrame = (pctRegions*particlesPerFrame);
  println("frameRate for "+(pctRegions*100)+"%:"+frameRate+",pps:"+particlesPerSecond+",ppf:"+particlesPerFrame);

  stacks = new ParticleStack[numstacks];
  for(int i=0;i<numstacks;i++){
    stacks[i] = new ParticleStack((i*fullRegionWidth)+gapWidth, regionWidth, speed, particleBatchSize, memStoreY, numRenderedParticles, particleHeight); 
  }
}

void draw() {
  smooth();
    for(int i=0;i<particlesPerFrame;i++){
      int which = (int)random(stacks.length);
      stacks[which].addParticles(1);
    }
  
  for(int i=0;i<stacks.length;i++){
    stacks[i].display();
  }
  int numDashes = width/4;
  stroke(100);
  for(int i=0;i<numDashes;i++){
    line(i*4,100,(i*4)+1,100);
  }
}

class HBaseRegion{
  int x;
  int y;
  int rheight;
  int rwidth;
  int speed;
  int inboundParticleCount;
  int numRenderedParticles = 0;
  int particleBatchSize;
  int maxRenderedParticles = 180;
  int particleHeight;

  ParticleStack memStore;
  ParticleStack storeFiles;
  ParticleStack compactedFiles;
  ParticleStack deletedFiles;
  
  HBaseRegion(int x, int rwidth, int speed, int particleBatchSize, int y, int rheight, int particleHeight){
    this.x = x;
    this.y = y;
    this.particleHeight = particleHeight;
    this.rheight = rheight;
    this.rwidth = rwidth;
    this.speed = speed;
    this.particleBatchSize = particleBatchSize;
    
  }

  void display(){
    memStore.display();
    storeFiles.display();
    compactedFiles.display();
    deletedFiles.display();
  }

  void addArticles(int count){
    memStore.addParticles(count);
  }
}
class ParticleStack {
  int x;
  int y;
  int rheight;
  int rwidth;
  int speed;
  int inboundParticleCount;
  int numRenderedParticles = 0;
  int particleBatchSize;
  int maxRenderedParticles = 180;
  int particleHeight;
  ArrayList falling;
  
  ParticleStack(int x, int rwidth, int speed, int particleBatchSize, int y, int rheight, int particleHeight){
    this.x = x;
    this.y = y;
    this.particleHeight = particleHeight;
    this.rheight = rheight;
    this.rwidth = rwidth;
    this.speed = speed;
    falling = new ArrayList();
    this.particleBatchSize = particleBatchSize;
  }
  
  void display(){
    for(int i=0;i<falling.size(); i++){
      FallingParticle fallingA = (FallingParticle) falling.get(i);
      fallingA.display();
    }

    for (int i = falling.size()-1; i >= 0; i--) { 
      FallingParticle fallingA = (FallingParticle) falling.get(i);
      if(fallingA.isDone()){
        falling.remove(i);
      }
    }
    
    int memHeight = numRenderedParticles - falling.size();
    if(memHeight > 0){
      stroke(255);
      if(rwidth == 1){
        line(x,y+(rheight-memHeight),x,y+rheight);
      }else{        
        rect(x,y+(rheight-memHeight),rwidth-1,memHeight);
      }
    }
  }

  void addParticles(int count){
    if(numRenderedParticles >= maxRenderedParticles){
      return;
    }

    inboundParticleCount += count;
    if(inboundParticleCount >= particleBatchSize){
      int numFalling = inboundParticleCount / particleBatchSize;
      for(int i=0;i<numFalling && numRenderedParticles < maxRenderedParticles;i++){
        int firstEmpty = findFirstEmpty();
        for(int j=0;j<firstEmpty;j++){
          FallingParticle f = (FallingParticle)falling.get(j);
          f.move();
        }

        falling.add(new FallingParticle(x, rwidth, speed, y+(rheight-numRenderedParticles), y, particleHeight));
        inboundParticleCount -= particleBatchSize;
        ++numRenderedParticles;
      }
    }
  }
  
  int findFirstEmpty(){
    int fallingSize = falling.size();
    for(int i=0;i<fallingSize;i++){
      FallingParticle f = (FallingParticle)falling.get(fallingSize-(i+1));
      if(f.y!=i){
        return i;
      }
    }
    return 0;
  }
}

class FallingParticle {
  int lastY;
  int y;
  int x;
  int rwidth;
  int speed;
  int maxY;
  int particleHeight;

  FallingParticle(int x, int rwidth, int speed, int maxY, int startY, int particleHeight){
    this.particleHeight = particleHeight;
    this.y=startY;
    this.lastY=y;
    this.x = x;
    this.rwidth = rwidth;
    this.speed = speed;
    this.maxY = maxY;
  }

  void display(){
    if(y<=maxY){
      stroke(51);
      line(x-1,lastY,x+rwidth,lastY);
      y+=speed;
      int actualY = y;
      if(y>maxY){
        y=maxY;
      }
      lastY=y;
      stroke(255);
      line(x,y,x+(rwidth-1),y);
    }
  }
  //allows for multiple particles per frame to go to the same stack, and render separately
  void move(){
    y+=1;
  }

  boolean isDone(){
    return y >= maxY;
  }
}
