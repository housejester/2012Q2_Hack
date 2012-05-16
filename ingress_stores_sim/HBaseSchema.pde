interface HBaseSchema {
  int nextPutRegion();
  void decorate(HBaseRegion region, ParticleStack stack); 
  void showReads(boolean show);
  void showDeletes(boolean deletes);
}

class OldSchoolSchema implements HBaseSchema {
  boolean showReads;
  boolean showDeletes;
  int numRegions;
  OldSchoolSchema(int numRegions){
    this.numRegions = numRegions;
  }
  void showReads(boolean show){
    showReads = show;
  }
  void showDeletes(boolean show){
    showDeletes = show;
  }
  int nextPutRegion(){
    return (int)random(numRegions);
  }
  void decorate(HBaseRegion region, ParticleStack stack){
    if(stack.hasReset && stack.landed.size() > 0 && winsLottery(2)){
      FallingParticle p = (FallingParticle)stack.landed.get(0);
      region.ttl(stack.particlesPerPixel);
      if(showDeletes){
        p.renderedDeletes = true;
        pushStyle();
        stroke(0);
        fill(0);
        int mark = (int)(random(p.filledHeight));
        line(p.x, p.y+mark, p.x+p.rwidth, p.y+mark);
        popStyle();
      }else if(p.renderedDeletes){
        p.draw();
        p.renderedDeletes = false;
      }
    }
  }
}
boolean winsLottery(int pctChance){
  return ((int)random(100))<pctChance;
}

class MobiusSchema implements HBaseSchema {
  boolean showReads;
  boolean showDeletes;
  int numRegions;
  long startTime = System.currentTimeMillis();
  MobiusSchema(int numRegions){
    this.numRegions = numRegions;
  }
  long oneDay = 2000;
  long thirtyDay = 30 * oneDay;

  void showReads(boolean show){
    showReads = show;
  }
  void showDeletes(boolean show){
    showDeletes = show;
  }
  int nextPutRegion(){
    int duration = (int)(System.currentTimeMillis() - startTime);
    int daysElapsed = (int)(duration / oneDay);
    int dayBucket = daysElapsed % 37;
    
    int modBucket = (int)random(8);
    int region = (modBucket * 37) + dayBucket;
    return region;
  }
  
  void decorate(HBaseRegion region, ParticleStack stack){
    long now = System.currentTimeMillis();
    for(int i=0;i<stack.landed.size();i++){
      FallingParticle p = (FallingParticle)stack.landed.get(i);
      if((now - p.created) >= thirtyDay){
        region.ttl(region.storeFilePutsCount);
        if(showDeletes){
          p.renderedDeletes = true;
          pushStyle();
          stroke(0);
          fill(0);
          rect(p.x, p.y+(p.height-p.filledHeight),p.rwidth-1,p.filledHeight-1);
          popStyle();
        }else if(p.renderedDeletes){
          p.draw();
          p.renderedDeletes = false;
        }
      }
    }
  }
}
