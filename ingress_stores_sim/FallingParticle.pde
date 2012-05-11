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
  
  void draw(){
    if(y<=maxY){
      pushStyle();
      stroke(51);
      fill(51);
      if(particleHeight == 1){
        line(x-1,lastY,x+rwidth,lastY);
      }else{
        rect(x,lastY,rwidth-1,particleHeight+1);
      }
      popStyle();
      y+=speed;
      int actualY = y;
      if(y>maxY){
        y=maxY;
      }
      lastY=y;
      if(particleHeight == 1){
        line(x,y,x+(rwidth-1),y);
      }else{
        rect(x,y,rwidth-1,particleHeight);
      }
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
