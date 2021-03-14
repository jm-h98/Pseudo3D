import peasy.*;
import java.util.Map;

PeasyCam cam;
PFont font;
PImage image;
ArrayList<PVector> spheres, colors;
int pixSize = 5; //größe der pixel, höherer wert reduziert auflösung
int start;
float incr = 0.008, thr = 0f, angle = thr;
boolean rev = true, recording = false, play = false;
int mode = 1; //0: rect, 1: box, 2:sphere
boolean outline = true;

void setup(){
  size(1920, 1080, P3D);
  colorMode(HSB);
  image = loadImage("pic.jpg");
  cam = new PeasyCam(this, 1100);
  background(255);
  spheres = new ArrayList<PVector>();
  colors = new ArrayList<PVector>();
  calcPicture();
  frameRate(30);
  sphereDetail(10);
}

void calcPicture(){
  image.loadPixels();
  
  for(int y = 0; y < image.height - 1; y++){
    for(int x = 1; x < image.width - 1; x++){
      color pix = image.pixels[x + y * image.width];
      
      float h = hue(pix);
      float s = saturation(pix);
      float b = brightness(pix);
      
      if((pixSize == 1 || (y % pixSize - 1 == 0 && x % pixSize - 1 == 0)) && b > 5){
        spheres.add(new PVector(x,y,h));
        colors.add(new PVector(h, s, b));
      }
    }
  }
  image.updatePixels();
}

void outline(int start, int end){
  stroke(255,255,255);
  beginShape();
  noFill();
  vertex(0,            0,             start);
  vertex(image.width,  0,             start);
  vertex(image.width,  image.height,  start);
  vertex(0,            image.height,  start);
  vertex(0,            0,             start);
  vertex(0,            0,             end);
  vertex(image.width,  0,             end);
  vertex(image.width,  0,             start);
  vertex(image.width,  0,             end);
  vertex(image.width,  image.height,  end);
  vertex(image.width,  image.height,  start);
  vertex(image.width,  image.height,  end);
  vertex(0,            image.height,  end);
  vertex(0,            image.height,  start);
  vertex(0,            image.height,  end);
  vertex(0,            0,             end);
  endShape();
}

void draw(){
  background(0);
  translate(-image.width/2, -image.height/2, -(255/2));
  for(int i = 0; i < spheres.size(); i++){
    PVector pix = spheres.get(i);
    translate(pix.x, pix.y, pix.z);
    PVector col = colors.get(i);
    stroke(col.x, col.y, col.z);
    fill(col.x, col.y, col.z);
    if(mode == 0){
      rectMode(CENTER);
      rect(0,0,pixSize + 1,pixSize + 1);
    } else if(mode == 1){
      box(pixSize);
    }else if (mode == 2){
      sphere(pixSize);
    }
    translate(-pix.x, -pix.y, -pix.z);
  }
  if(outline)
    outline(0, 255);
  translate(image.width/2, image.height/2, (765/2));
}
