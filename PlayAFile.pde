/**
  * This sketch demonstrates how to play a file with Minim using an AudioPlayer. <br />
  * It's also a good example of how to draw the waveform of the audio.
  */
import ddf.minim.*;

Minim minim;


void setup()
{
  size(1300, 200, P3D);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);

  String loadStr = "tumblr_mty5r3lokV1qhkj08o1.mp3";
  AudioSample sample = minim.loadSample(loadStr, 2048);

  SongSorter ss = new SongSorter(sample);
  sample.close();
}


void draw()
{
//  fftLin.forward( player.mix );
  background(0);
  

  stroke(255);
}

