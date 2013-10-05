/**
  * This sketch demonstrates how to play a file with Minim using an AudioPlayer. <br />
  * It's also a good example of how to draw the waveform of the audio.
  */
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer player;
FFT fftLin;

void setup()
{
  size(1300, 200, P3D);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  player = minim.loadFile("tumblr_mty5r3lokV1qhkj08o1.mp3");
  
  // play the file
  player.play();
//  player.loop();
  SongSorter ss = new SongSorter(player);
  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
//  fftLin = new FFT( player.bufferSize(), player.sampleRate() );
//  println("fftLin.tmSz: " + fftLin.timeSize());
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
//  fftLin.linAverages( 6 );
}


void draw()
{
//  fftLin.forward( player.mix );
  background(0);
  
  noFill();
//    for(int i = 0; i < fftLin.specSize(); i++)
//    {
//      // if the mouse is over the spectrum value we're about to draw
//      // set the stroke color to red
//      if ( i == mouseX )
//      {
////        centerFrequency = fftLin.indexToFreq(i);
//        stroke(255, 0, 0);
//      }
//      else
//      {
//          stroke(255);
//      }
//      line(i, height, i, height - fftLin.getBand(i)*4);
//    }
//  
  stroke(255);
  
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  // note that if the file is MONO, left.get() and right.get() will return the same value
  for(int i = 0; i < player.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, player.bufferSize(), 0, width );
    float x2 = map( i+1, 0, player.bufferSize(), 0, width );
    line( x1, 50 + player.left.get(i)*50, x2, 50 + player.left.get(i+1)*50 );
    line( x1, 150 + player.right.get(i)*50, x2, 150 + player.right.get(i+1)*50 );
  }
}
