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
