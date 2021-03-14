import peasy.*;
import java.util.Map;

PeasyCam cam;
PFont font;
PImage image;
ArrayList<PVector> spheres, colors;
int pixSize = 1; //größe der pixel, höherer wert reduziert auflösung
int start;
float incr = 0.008, thr = 0f, angle = thr;
boolean rev = true, recording = false, play = false;
int mode = 1; //0: rect, 1: box, 2:sphere

void setup(){
  size(1920, 1080, P3D);
  colorMode(HSB);
  image = loadImage("pic.jpg");
  font = createFont("Arial Bold",48);
  cam = new PeasyCam(this, 1100);
  background(255);
  spheres = new ArrayList<PVector>();
  colors = new ArrayList<PVector>();
  calcPicture();
  frameRate(30);
  sphereDetail(10);
  angle = thr;
  play = true;
  recording = true;
  start = millis();
}

void calcPicture(){
  image.loadPixels();
  int count = 0;
  
  for(int y = 0; y < image.height - 1; y++){
    for(int x = 1; x < image.width - 1; x++){
      color pix = image.pixels[x + y * image.width];
      
      float h = hue(pix);
      float s = saturation(pix);
      float b = brightness(pix);
      
      if((pixSize == 1 || (y % pixSize - 1 == 0 && x % pixSize - 1 == 0)) && b > 5){
        spheres.add(new PVector(x,y,h*3));
        colors.add(new PVector(h, s, b));
        count++;
      }
    }
  }
  System.out.println(count + " einträge");
  image.updatePixels();
}

void removeSkin(){
  spheres = new ArrayList<PVector>();
  colors = new ArrayList<PVector>();
  image.loadPixels();
  int count = 0;
  
  for(int y = 0; y < image.height - 1; y++){
    for(int x = 1; x < image.width - 1; x++){
      color pix = image.pixels[x + y * image.width];
      
      float h = hue(pix);
      float s = saturation(pix);
      float b = brightness(pix);
      
      if((pixSize == 1 || (y % pixSize - 1 == 0 && x % pixSize - 1 == 0)) && b > 5){
        if(h > 30 && h < 245){
          spheres.add(new PVector(x,y,h*3));
          colors.add(new PVector(h, s, b));
          count++;
        }
      }
    }
  }
  System.out.println(count + " einträge");
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
  background(255);
  
  if(!recording){
    textFont(font,60);
    fill(200);
    text(int(frameRate),(-image.width/2)-100,(-image.height/2)-100);
  }
  
  if(play){
    rotateX(angle);
    System.out.println(angle);
    if(angle < thr){
      if(recording){
        recording = false;
        System.out.println("Completed rendering, took " + (millis() - start) / 1000 + "s.");
        play = false;
        System.exit(0);
      }
      rev = true;
    }
    if(angle > 1.7f){
      rev = false;
      removeSkin();
    } if(!rev)
      angle -= incr;
    else
      angle += incr;
  }
  translate(-image.width/2, -image.height/2, -(765/2));
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
  outline(0, 90);
  outline(735, 765);
  translate(image.width/2, image.height/2, (765/2));
  
  if(recording)
    record();
}

void record(){
  System.out.println("rendered frame " + frameCount + ", " + (millis() - start) / 1000 + "s elapsed");
  saveFrame("frames/#####.png");
}

void keyPressed(){
  if(key == 'p'){
    play = !play;
  }
  if(key == 'r'){
    angle = thr;
    play = true;
    recording = true;
    start = millis();
  }
}
