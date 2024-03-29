interface ParticleStackColor {
  color getColor();
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
  int particlesPerPixel;
  ArrayList falling;
  ArrayList landed;
  boolean highlightOverfills;
  boolean hasReset = false;
  
  ParticleStack(int x, int rwidth, int speed, int particleBatchSize, int y, int rheight, int particleHeight, int particlesPerPixel, boolean highlightOverfills){
    this.x = x;
    this.y = y;
    this.particleHeight = particleHeight;
    this.rheight = rheight;
    this.rwidth = rwidth;
    this.speed = speed;
    this.particlesPerPixel = particlesPerPixel;
    this.highlightOverfills = highlightOverfills;
    falling = new ArrayList();
    landed = new ArrayList();
    this.particleBatchSize = particleBatchSize;
    maxRenderedParticles = (int)(rheight / particleHeight);
  }
  
  void setup(){
  }
  void draw(){
    for(int i=0;i<falling.size(); i++){
      FallingParticle fallingA = (FallingParticle) falling.get(i);
      fallingA.draw();
    }

    int removedCount = 0;
    for (int i = falling.size()-1; i >= 0; i--) { 
      FallingParticle fallingA = (FallingParticle) falling.get(i);
      if(fallingA.isDone()){
        ++removedCount;
        falling.remove(i);
        landed.add(fallingA);
      }
    }
    
    if(!landed.isEmpty()){
      for(int i=0;i<landed.size();i++){
        FallingParticle landedA = (FallingParticle) landed.get(i);
        landedA.draw();
      }
    }
  }

  void renderNewParticles(){
    if(numRenderedParticles >= maxRenderedParticles){
      return;
    }

    if(inboundParticleCount > 0){
      int firstEmpty = findFirstEmpty();
      for(int j=0;j<firstEmpty;j++){
        FallingParticle f = (FallingParticle)falling.get(j);
        f.move();
      }

      int numParticles = inboundParticleCount;
      
      int pFillHeight = (int)((float)numParticles / particlesPerPixel);
      if(pFillHeight == 0){
        println("0 for numArticles:"+numParticles+",particlesPerPixel:"+particlesPerPixel);
      }
      int pHeight = particleHeight;
      if(pHeight <= pFillHeight){
        pHeight = pFillHeight;
        if(particleHeight > 1){
          pHeight += 1;
        }
      }
      
      stackHeight += pHeight;
      int maxY = y+(rheight - stackHeight);
      
      falling.add(new FallingParticle(x, rwidth, speed, maxY, y, pHeight, pFillHeight, numParticles, highlightOverfills && ((pFillHeight+1) >= particleHeight)));
      inboundParticleCount -= numParticles;
      ++numRenderedParticles;
    }
  }
  int stackHeight = 0;
  int lastCount = 0;
  void setParticleCount(int count){
    if(count < lastCount){
      reset();
      inboundParticleCount = count;
    }else if(count > lastCount){
      int adding = count - lastCount;
      inboundParticleCount += adding;
    }
    lastCount = count;
    renderNewParticles();
  }
  void compact(){
    reset();
  }
  
  void reset(){
    hasReset = true;
    falling.clear();
    landed.clear();
    inboundParticleCount=0;
    numRenderedParticles=0;
    stackHeight = 0;
    lastCount=0;
    
    stroke(51);
    fill(51);
    if(rwidth == 1){
      line(x,y,x,y+rheight);
    }else{        
      rect(x,y,rwidth-1,rheight);
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
