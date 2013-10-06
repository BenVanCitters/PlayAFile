/**
  * This sketch demonstrates how to play a file with Minim using an AudioPlayer. <br />
  * It's also a good example of how to draw the waveform of the audio.
  */
import ddf.minim.*;

Minim minim;
SongSorter songSorter;
AudioOutput out;
void setup()
{
  size(500, 500, P3D);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);

  String loadStr = "tumblr_mty5r3lokV1qhkj08o1.mp3";
  AudioSample sample = minim.loadSample(loadStr, 2048);
  
  songSorter = new SongSorter(sample);
  sortTheChunks();
 
  out = minim.getLineOut(Minim.STEREO,2048*2,sample.sampleRate());
  sample.close();
  /*
   AudioOutput  getLineOut(int type, int bufferSize, float sampleRate) 
         
 AudioOutput  getLineOut(int type, int bufferSize, float sampleRate, int bitDepth) 

  */
  //sample.sampleRate()
//  out = minim.getLineOut(Minim.STEREO);
 
  out.addSignal(songSorter);
}


void sortTheChunks()
{
 songSorter.sortSongChunks(new SongChunkTotalEnergyComparator());
}

void draw()
{
//  fftLin.forward( player.mix );
  background(0);
  
  //songSorter.draw();
  stroke(255);
}

void stop()
{
  minim.stop();

  super.stop();
}
