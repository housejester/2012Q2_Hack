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
