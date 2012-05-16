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
  long created;
  boolean renderedDeletes;

  FallingParticle(int x, int rwidth, int speed, int maxY, int startY, int height, int filledHeight, int numParticles, boolean overfilled){
    this.id = NEXT_ID++;
    this.overfilled = overfilled;
    this.height = height;
    this.filledHeight = filledHeight;

    this.y=startY;
    this.lastY=y;
    this.x = x;
    this.rwidth = rwidth;
    this.speed = speed;
    this.maxY = maxY;
    this.numParticles = numParticles;
    this.created = System.currentTimeMillis();
  }
  void draw(){
    if(y<=maxY){
      pushStyle();
      stroke(51);
      fill(51);
      rect(x,lastY,rwidth-1,height-1);
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
      if(height != filledHeight){
//        pushStyle();
//        stroke(0);
//        fill(0);
//        rect(x,y,rwidth-1,(height-filledHeight)-1);
//        popStyle();
      } 
      if(overfilled){
        pushStyle();
        color darker = darken(g.strokeColor, 80);          
        stroke(darker);
        fill(darker);
        rect(x,y+(height-filledHeight),rwidth-1,filledHeight-1);
        popStyle();
      }else{
        rect(x,y+(height-filledHeight),rwidth-1,filledHeight-1);
      }
    }
  }
  color darken(color c, int amount){
    int red = (int)max(red(c)-amount, 0);
    int green = (int) max(green(c)-amount, 0);
    int blue = (int)max(blue(c)-amount, 0);

    return color(red, green, blue);
  }

  //allows for multiple particles per frame to go to the same stack, and render separately
  void move(){
    y+=1;
  }

  boolean isDone(){
    return y >= maxY;
  }
}
