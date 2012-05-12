int NEXT_ID=1;
class FallingParticle {
  int id;
  int lastY;
  int y;
  int x;
  int rwidth;
  int speed;
  int maxY;
  int height;
  int filledHeight;
  int numParticles;
  boolean overfilled;

  FallingParticle(int x, int rwidth, int speed, int maxY, int startY, int height, int filledHeight, int numParticles, boolean overfilled){
    this.id = NEXT_ID++;
    this.overfilled = overfilled;
    this.height = height;
    this.filledHeight = filledHeight;
    if(this.height < this.filledHeight){
      this.height = this.filledHeight;
    }
    this.y=startY;
    this.lastY=y;
    this.x = x;
    this.rwidth = rwidth;
    this.speed = speed;
    this.maxY = maxY;
    this.numParticles = numParticles;
  }
  void draw(){
    if(y<=maxY){
      pushStyle();
      stroke(51);
      fill(51);
      if(height == 1){
        line(x-1,lastY,x+rwidth,lastY);
      }else{
        rect(x,lastY,rwidth-1,height-1);
      }
      popStyle();
      int initialY = this.y;
      this.y+=speed;
      int beforeAdj = this.y;
      if(speed > 1){
        this.y-=random(speed-1);
      }
      if(this.y>maxY){
        this.y=maxY;
      }
      lastY=y;
      if(height == 1){
        line(x,y,x+(rwidth-1),y);
      }else{
        if(height != filledHeight){
          pushStyle();
          stroke(0);
          fill(0);
          rect(x,y,rwidth-1,(height-filledHeight)-1);
          popStyle();
        } 
        if(overfilled){
          pushStyle();
          stroke(#FF6600);
          fill(#FF6600);
          rect(x,y+(height-filledHeight),rwidth-1,filledHeight-1);
          popStyle();
        }else{
          rect(x,y+(height-filledHeight),rwidth-1,filledHeight-1);
        }
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
