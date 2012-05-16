interface HBaseSchema {
  int nextPutRegion();
  void decorateMemStore(HBaseRegion region, ParticleStack memStoreStack); 
  void decorateStoreFiles(HBaseRegion region, ParticleStack storeFileStack); 
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
  
  void decorateMemStore(HBaseRegion region, ParticleStack memStoreStack){
    decorateReads(region, memStoreStack, g.fillColor, 7, 2);
  }
  
  void decorateStoreFiles(HBaseRegion region, ParticleStack storeFileStack){
    decorateReads(region, storeFileStack, g.fillColor, 40, 2);
    decorateDeletes(region, storeFileStack);
  }
  
  void decorateDeletes(HBaseRegion region, ParticleStack storeFileStack){
    if(storeFileStack.hasReset && storeFileStack.landed.size() > 0 && winsLottery(2)){
      FallingParticle p = (FallingParticle)storeFileStack.landed.get(0);
      region.ttl(storeFileStack.particlesPerPixel);
      if(showDeletes){
        p.renderedDeletes = true;
        pushStyle();
        stroke(0);
        fill(0);
        int mark = (int)(random(p.filledHeight));
        line(p.x, p.y+(p.height - p.filledHeight)+mark, p.x+p.rwidth-1, p.y+(p.height - p.filledHeight)+mark);
        popStyle();
      }else if(p.renderedDeletes){
        p.draw();
        p.renderedDeletes = false;
      }
    }
  }

  void decorateReads(HBaseRegion region, ParticleStack stack, color baseColor, int pctChance, int numPer){
    if(winsLottery(25)){
    for(int i=0;i<stack.landed.size();i++){
      FallingParticle p = (FallingParticle)stack.landed.get(i);
      if(showReads && winsLottery(pctChance)){
        p.renderedReads = true;
        pushStyle();
        stroke(baseColor);
        fill(baseColor);
        p.draw();
        for(int j=0;j<numPer;j++){
          stroke(#00FF00);
          fill(#00FF00);
  
          int mark = (int)(random(p.filledHeight));
          line(p.x, p.y+(p.height - p.filledHeight)+mark, p.x+p.rwidth-1, p.y+(p.height - p.filledHeight)+mark);
        }
        popStyle();
      }else if(p.renderedReads){
        p.draw();
        p.renderedReads = false;
      }
    }
    }
  }
}
boolean winsLottery(int pctChance){
  return pctChance >=100 || ((int)random(100))<pctChance;
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
  
  void decorateMemStore(HBaseRegion region, ParticleStack memStoreStack){
    decorateReads(region, memStoreStack, g.strokeColor, 1);
  }
  
  void decorateStoreFiles(HBaseRegion region, ParticleStack storeFileStack){
    decorateReads(region, storeFileStack, g.strokeColor, 3);
    decorateDeletes(region, storeFileStack);
  }
  
  void decorateDeletes(HBaseRegion region, ParticleStack storeFileStack){
    long now = System.currentTimeMillis();
    for(int i=0;i<storeFileStack.landed.size();i++){
      FallingParticle p = (FallingParticle)storeFileStack.landed.get(i);
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

  void decorateReads(HBaseRegion region, ParticleStack memStoreStack, color baseColor, int hits){
    long now = System.currentTimeMillis();
    for(int i=0;i<memStoreStack.landed.size();i++){
      FallingParticle p = (FallingParticle)memStoreStack.landed.get(i);
      if(showReads){
        p.renderedReads = true;
        pushStyle();
        stroke(baseColor);
        fill(baseColor);
        p.draw(true);
        stroke(#00FF00);
        fill(#00FF00);
        int ageDays = (int)((now - p.created)/oneDay);
        int readPixels = 4 - ageDays;
        if(readPixels < 2){
          readPixels = 2;
        }
        if(readPixels > p.filledHeight){
          readPixels = p.filledHeight;
        }
        int pctChance = 70;
        if(ageDays > 3){
          pctChance = (int)((27 - min(ageDays, 27))/1.5);
        }
        if(ageDays > 7){
          pctChance = (int)((float)pctChance/1.5);
          hits-=1;
        }
        if(ageDays > 14){
          pctChance = (int)((float)pctChance/2);
          hits-=1;
        }
        if(hits < 1){
          hits = 1;
        }
        for(int j=0;j<hits;j++){
          int mark = (int)(random(p.filledHeight - readPixels));
          if(winsLottery(pctChance)){
            rect(p.x, p.y+(p.height - p.filledHeight)+mark,p.rwidth-1,readPixels-1);
          }
        }
        popStyle();
      }else if(p.renderedReads){
        pushStyle();
        stroke(baseColor);
        fill(baseColor);
        p.draw();
        popStyle();
        p.renderedReads = false;
      }
    }
  }
}
