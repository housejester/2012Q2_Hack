class HBaseRegion {
  int x;
  int y;
  int particleHeight;
  int height;
  int width;
  int speed;
  int particleBatchSize;

  ParticleStack memStore;
  ParticleStack storeFiles;
  ParticleStack compactedFiles;
  ParticleStack deletedFiles;
  
  HBaseRegion(int x, int y, int width, int height, int speed, int particleBatchSize, int particleHeight){
    this.x = x;
    this.y = y;
    this.particleHeight = particleHeight;
    this.height = height;
    this.width = width;
    this.speed = speed;
    this.particleBatchSize = particleBatchSize;
    
    memStore = new ParticleStack(x, width, speed, particleBatchSize, y, height, particleHeight);
    storeFiles = new ParticleStack(x, width, speed, particleBatchSize, y, height, particleHeight);
    compactedFiles = new ParticleStack(x, width, speed, particleBatchSize, y, height, particleHeight);
    deletedFiles = new ParticleStack(x, width, speed, particleBatchSize, y, height, particleHeight);
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
