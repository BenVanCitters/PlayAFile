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
  background(0);
  textSize(20);
  fill(0,255,0);
  String s = "Processing Audio...";
  text(s, 10, 10, 700, 100);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);

  String loadStr = "tumblr_mu6wwqPqkT1sqdxp0o1.mp3";
  AudioSample sample = minim.loadSample(loadStr, 2048);
  
  songSorter = new SongSorter(sample);
  sortTheChunks();
 
  out = minim.getLineOut(Minim.MONO,2048*2,sample.sampleRate());
  sample.close();

  //sample.sampleRate()
//  out = minim.getLineOut(Minim.STEREO);
 
  out.addSignal(songSorter);
}


void sortTheChunks()
{
 songSorter.sortSongChunks(new SongChunkFreqComparator());
}

void draw()
{
//  fftLin.forward( player.mix );
  background(0);
  
  //this function has troublie on win7 in processing 2.0+
  songSorter.renderCurrentShape();
  showDebugText();
}

void showDebugText()
{
  textSize(20);
  fill(0,255,0);
  String s = "FrameRate: " +  frameRate;
  text(s, 10, 10, 700, 100);
}

void stop()
{
  minim.stop();
  super.stop();
}
