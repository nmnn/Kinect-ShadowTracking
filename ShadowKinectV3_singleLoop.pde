/*----  Kinect | Shadows In Time ----
* -----------------------------------
* -----------------------------------
* Edward van Dongen | Dennis Neumann
* ------- www.telesync.nl -----------
* --- Special thanks to Evolutie ----
* -----------------------------------
*/


// import libraries
import processing.opengl.*;
import SimpleOpenNI.*;

// set variables
SimpleOpenNI  kinect;

PImage  userImage;
boolean tracking = false;
int userID;
int[] userMap;

PImage src;
PImage dst;

PImage srcB;
PImage dstB;

// Record and Play
PImage[] sequenceA;
int seqACounter = 0;
int seqAPlayFrame = 0;

// clock for refresh
int frameCounter = 0;


void setup() {
  size(640, 480, OPENGL);
  
  frameRate(16);
  
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
  kinect.setMirror(true);
  
  kinect.alternativeViewPointDepthToImage();

  userImage = createImage(640, 480, ARGB);
  
  // create recorded sequence with duration of 60 frames
  sequenceA = new PImage[60];
}


void draw() {
  background(255,255,255);
  
  //After 60 frames recorded, play
  if(seqACounter == 60) {
    image(sequenceA[seqAPlayFrame],0,0);
    seqAPlayFrame ++;
    if(seqAPlayFrame == 60) seqAPlayFrame = 0;
    println("seqAPlayFrame " + seqAPlayFrame);
    }
    
  kinect.update();
  
  if (tracking) {
    userMap = kinect.getUsersPixels(SimpleOpenNI.USERS_ALL);
    for (int y=0;y < kinect.depthHeight();y+=1) {
      for (int x=0;x < kinect.depthWidth();x+=1) {
        int i = x + y * 640;
        if(userMap[i] != 0){
          userImage.pixels[i] = color(0,0,0);
        } else {
          userImage.pixels[i] = color(255,255,255, 0);
        }
      }
    }

  userImage.updatePixels();
    
    
  userImage.filter(BLUR,1.5);
    
  image(userImage,0,0);
  
  //if(frameCounter == 80) {
  //    userImage.tint(255,128);
  //}
 
  //Record until 60 frames      
  if(seqACounter < 60) {
     PImage img = createImage(640, 480, ARGB);
     img.copy(userImage, 0, 0, 640,  480, 0, 0, 640, 480);
     sequenceA[seqACounter] = img;
     seqACounter ++;
     println("seqACounter " + seqACounter);
  }
  frameCounter++;
  println("frameCounter " + frameCounter); 
  
  if (frameCounter == 240) {
    seqACounter = 0;
    seqAPlayFrame = 0;
    frameCounter = 0;
    
  }
  } 
}

void onNewUser(int uID) {
  userID = uID;
  tracking = true;
  println("tracking");
    
}
  
void createAlpha() {
  dst = createImage(src.width, src.height, ARGB);
  dst.loadPixels();

  for(int i = 0; i < dst.pixels.length; i++) {
    float a = red(src.pixels[i]);
    dst.pixels[i] = color(0,0,0,a);
   }
}  
