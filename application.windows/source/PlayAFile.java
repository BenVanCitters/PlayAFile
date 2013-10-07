import processing.core.*; 
import processing.xml.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class PlayAFile extends PApplet {

/**
  * This sketch demonstrates how to play a file with Minim using an AudioPlayer. <br />
  * It's also a good example of how to draw the waveform of the audio.
  */


Minim minim;
SongSorter songSorter;
AudioOutput out;
 AudioRecorder recorder;
public void setup()
{
  size(1200, 800, P3D);
  background(0);
  textSize(20);
  fill(0,255,0);
  String s = "Processing Audio...";
  text(s, 10, 10, 700, 100);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);

  String loadStr = "tumblr_mty5r3lokV1qhkj08o1.mp3";
  AudioSample sample = minim.loadSample(loadStr, 2048);
  
  songSorter = new SongSorter(sample,13);
  sortTheChunks();
  
  out = minim.getLineOut(Minim.MONO,2048*2,sample.sampleRate());
  GregorianCalendar gc = new GregorianCalendar();
  String fileName = "myrecording" + gc.getTimeInMillis() + ".wav";
  println(fileName);
  recorder = minim.createRecorder(out,fileName ,true);
  sample.close();
 
  out.addSignal(songSorter);
}

public void sortTheChunks()
{
  songSorter.sortSongChunks(new SongChunkFreqComparator());

//  songSorter.sortSongChunks(new SongChunkFrewDistanceComparator(songSorter.getAvgFreqVect()));
}

public void draw()
{
  background(0);
  //this function has troublie on win7 in processing 2.0+
//  songSorter.renderCurrentShape();
  songSorter.draw();
  showDebugText();
}

public void showDebugText()
{
  textSize(20);
  fill(0,255,0);
  String s = "FrameRate: " +  frameRate;
  text(s, 10, 10, 700, 30);
  
  String completion = songSorter.getCompletionString();
  text(completion, 10, 30, 900, 30);
}

public void stop()
{
  minim.stop();
  super.stop();
}

public void keyReleased()
{
  if ( key == 'r' ) 
  {
    songSorter.saveToDisk(recorder);
  }
}
class SongChunk
{
  float duration;
  long startTime;
  float maxAmp;
  int peakFreqIndex;
  float freqMoment;
  float totalMass;
  float[] freqs;
  float[] buffer;
  
  public SongChunk(  float dur,  long startTm,  float[] frqs,float[] buf)
  {
    duration = dur;
    startTime = startTm;
    freqs = java.util.Arrays.copyOf(frqs,frqs.length);
    buffer = java.util.Arrays.copyOf(buf,buf.length);
    findFreqMoment();
    findMaxAmp();
    findHighestFreqIndex();
  }
  
  public void findMaxAmp()
  {
    maxAmp =-10;
    for(int i = 0; i < buffer.length; i++)
    {
      maxAmp = max(maxAmp,buffer[i]);
    }
  }
  
  //finds and stores this sample's peak spectrogram index
  public void findHighestFreqIndex()
  {
    peakFreqIndex =0;
    for(int i = 0; i < freqs.length; i++)
    {
      if(freqs[peakFreqIndex] < freqs[i])
      peakFreqIndex = i;
    }
  }
  
  //get the 'centroid' of the spetrograph - using a poor-man's 
  //algorith
  public void findFreqMoment()
  {
    totalMass = 0;
    for(int j = 0; j < freqs.length; j++)
    {
      totalMass += freqs[j];
    }

    float halfMass = totalMass/2;
    int index = 0;
    float accumulator = 0;
    int i = 0;
    for(i = 0; (i < freqs.length) && (accumulator <  halfMass); i++)
    {
      accumulator += freqs[i];
    }
    freqMoment = i;
//    println("totalMass: " + totalMass + " freqMoment: " + freqMoment);
  }
  
  //as of 10-6-13 this function doesn't play nice with processing 2.0.3
  public void draw(int curIndex)
  {    
    noFill();
    stroke(255);
    
    //draw spectrum
    for(int i = 0; i < width; i++)
    {
      line(i, height, i, height - freqs[i*freqs.length/width]*4);
    }
    
    //draw waveform
    for(int i = 0; i < buffer.length - 1; i++)
    {
      //switching colors seems to be problematic in 2.0+
      if((i-curIndex) > 0 && (i-curIndex) < 4096)
        stroke(255,0,0);
      else
        stroke(255);
      float x1 = map( i, 0, buffer.length, 0, width );
      float x2 = map( i+1, 0, buffer.length, 0, width );
      line( x1, 150 + buffer[i]*50, x2, 150 + buffer[i+1]*100 );      
    }   
  }
}



class SongSorter implements AudioSignal
{
  AudioSample sample;
  FFT fftLin;
  SongChunk[] songChunks;
  long chunkLength = 128*16;
  long count=-1;
  int totalSampLength;
  PImage spectrograph;
  PImage spectrographScr; //screen-sized copy of spectrograph
  private boolean isRecording;
  
  public SongSorter(AudioSample audioSample, int chunkSize)
  {
    sample = audioSample;
    chunkLength = (long)1<<chunkSize;//(long)pow(chunkLength,chunkSize);
    processSample();
    renderSpectrograph();
  }
  
  private void processSample()
  {    
    long startTm = millis();
    int fftSize = (int)chunkLength;//512*64;
    float[] fftSamples = new float[fftSize];
    fftLin = new FFT( fftSize, sample.sampleRate() );
    
    float[] leftChannel = sample.getChannel(BufferedAudio.LEFT);
    totalSampLength = leftChannel.length;
    count = (leftChannel.length / chunkLength) + 1;
    songChunks = new SongChunk[(int)count];
    
    for(int i =0; i< songChunks.length; i++)
    {
      int songPos = (int)(chunkLength*i);
      int chunkSize = min( leftChannel.length - songPos, fftSize );
      
      // copy first chunk into our analysis array
      arraycopy( leftChannel, // source of the copy
                  songPos, // index to start in the source
                  fftSamples, // destination of the copy
                  0, // index to copy to
                  chunkSize); // how many samples to copy
      // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes        
      if ( chunkSize < fftSize )
      {
        // we use a system call for this
        java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0f );
      }

      fftLin.forward(fftSamples);
      
      float[] ffts = new float[fftLin.specSize()];
      for(int j = 0; j < fftLin.specSize(); j++)
      {
        ffts[j] = fftLin.getBand(j);
      }      
      songChunks[i] = new SongChunk((float)chunkLength,
                                    (long)songPos,
                                     ffts,
                                     fftSamples);
//       println("ffts: " + ffts.length);
    }
//    println("songChunks.length(): " + songChunks.length);
println("Processing took: " + (millis() -startTm) + " milliseconds");
  }
  
  public void sortSongChunks(java.util.Comparator c)
  {
    long startTm = millis();
    java.util.Arrays.sort( songChunks, c);
    println("sorting took " + (millis() - startTm) + " milliseconds");
    renderSpectrograph();
  }
  
  
  public void draw()
  {    
    image(spectrographScr,0,0);
    stroke(0,0,255);
    pushMatrix();    
    float xLinePos = curChunkIndex*width/songChunks.length;
    translate(xLinePos,0);
    rotateY(-PI/2);
    for(int i = 0; i < height; i++)
    {
      line(0, i, 
           songChunks[curChunkIndex].freqs[i*songChunks[curChunkIndex].freqs.length/height]*4,i);
    }
    
//    line( xLinePos,0,xLinePos,height );  
    popMatrix();
   //draw current waveform 
   int curSampIndx = (int)(curIndex%songChunks[curChunkIndex].buffer.length);
   //draw waveform
   int chunksToDraw = 3;
   int totalSamples = songChunks[0].buffer.length*chunksToDraw;
   int startIndex = max(min(curChunkIndex-chunksToDraw/2,songChunks.length-chunksToDraw),0);
   int endIndex = min(curChunkIndex+chunksToDraw/2,songChunks.length);
   
   float offset = map( curSampIndx, 0, songChunks[0].buffer.length, 0, width )/(chunksToDraw-1);
   pushMatrix();
   translate(-offset,0);
   for(int j = 0; j < chunksToDraw; j++)
   {
    int chunkIndex = startIndex + j;
     
    for(int i = 0; i < songChunks[chunkIndex].buffer.length-1; i++)
    {
      //switching colors seems to be problematic in 2.0+
      
      if(chunkIndex == curChunkIndex){
        if((i-curSampIndx) > 0 && (i-curSampIndx) < 4096)
        {  stroke(255,0,0);}
        else{
          stroke(255,255,0);}
      }else{
        stroke(255);}
      float x1 = (map( i, 0, songChunks[chunkIndex].buffer.length, 0, width )+ j*width)/(chunksToDraw-1);
      float x2 = (map( i+1, 0, songChunks[chunkIndex].buffer.length, 0, width )+ j*width)/(chunksToDraw-1);
      line( x1, 150 + songChunks[chunkIndex].buffer[i]*50, 
            x2, 150 + songChunks[chunkIndex].buffer[i+1]*100 );      
    }  
   }
   popMatrix();
   //draw
  }
  
  public void renderCurrentShape()
  {
//    int chunkIndex = (int)(curIndex/songChunks[0].buffer.length);
      int curSampIndx = (int)(curIndex%songChunks[curChunkIndex].buffer.length);
//      signal[i] = songChunks[chunkIndex].buffer[curSampIndx];
      
    songChunks[curChunkIndex].draw(curSampIndx);
  }
  
  public String getCompletionString()
  {
    return "chunkIndex: " + curChunkIndex + "/" + songChunks.length;
  }
  
  int curChunkIndex = 0;
  int curIndex = 0;
  //method for AudioSignal interface
  public void  generate(float[] signal) 
  {
    for(int i = 0; i < signal.length; i++)
    {
      curChunkIndex = (int)(curIndex/songChunks[0].buffer.length);
      int curSampIndx = (int)(curIndex%songChunks[curChunkIndex].buffer.length);
      signal[i] = songChunks[curChunkIndex].buffer[curSampIndx];
      if(!isRecording)
        curIndex = (curIndex+1)%totalSampLength;
        else
        curIndex++;
    }
  }
  //method for AudioSignal interface
  public void generate(float[] left, float[] right) 
  {
    generate(left);
    generate(right);
  }
  
  private void renderSpectrograph()
  {
    long startTm = millis();
    
    spectrograph = createImage(songChunks.length,(int)chunkLength/2,RGB);

    spectrograph.loadPixels();
    for(int i = 0; i < spectrograph.height-1; i++)
    {
      for(int j = 0; j < spectrograph.width; j++)
      {
        int pixelIndex = i*spectrograph.width +j;
        float amt = songChunks[j].freqs[i];
        spectrograph.pixels[pixelIndex] = color(amt,amt,amt);
      }
    }
    spectrograph.updatePixels();
    spectrographScr = createImage(width,height,RGB);
    spectrographScr.copy(spectrograph,
                          0,0,
                          spectrograph.width,spectrograph.height,
                          0,0,
                          width, height);
    println("rendering spectrograph(size:"+ spectrograph.width + ", " + spectrograph.height + " took " + (millis() - startTm) + " milliseconds");                          
  }
  
  // saves the song to disk - you have to wait for it...
  public void saveToDisk(AudioRecorder recorder)
  {    
    curIndex = 0;
    int startTm = millis();
    recorder.beginRecord();
    boolean showOnce = false;
    while(curIndex < totalSampLength)
    {
      isRecording = true;
      int curSecs = (millis()-startTm);
      if(curSecs % 1000 == 0 && !showOnce)
      {
        println("pct complete: " + curIndex *100.f/totalSampLength+ "%");  
        showOnce = true;
      }
      else if(curSecs % 10 != 0)
      {
        showOnce = false;
      }        
    }
    isRecording = false;
    recorder.endRecord();
    recorder.save();
  }
  
  public float[] getAvgFreqVect()
  {
    float[] avg = new float[songChunks[0].freqs.length];
        
    for(int i = 0; i < songChunks[0].freqs.length; i++)
    {
      for(int j =0; j< songChunks.length; j++)
      {
        avg[i] += songChunks[j].freqs[i];
      }
      avg[i] /= songChunks.length;
    }
    return avg;
  }
}
//compares the 'moment' of the spectrogram
public class SongChunkFreqMomentComparator implements java.util.Comparator
{
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    SongChunk s2 = (SongChunk)o2;
    
    return (int)(s1.freqMoment - s2.freqMoment);
  }
}

//compares the loudest frequency bar of each spectrogram
public class SongChunkFreqComparator implements java.util.Comparator
{
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    SongChunk s2 = (SongChunk)o2;
    
    return (int)(s1.peakFreqIndex - s2.peakFreqIndex);
  }
}

public class SongChunkMaxAmpComparator implements java.util.Comparator
{
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    SongChunk s2 = (SongChunk)o2;
    
    return (int)(1000*(s1.maxAmp - s2.maxAmp));
  }
}

public class SongChunkTotalEnergyComparator implements java.util.Comparator
{
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    SongChunk s2 = (SongChunk)o2;
    
    return (int)(s1.totalMass - s2.totalMass);
  }
}

//treats the sprectrogram of each chunk as a vector and compares 'distance'
//from a given vector 'vect'
public class SongChunkFrewDistanceComparator implements java.util.Comparator
{
  public float[] vect;
  public SongChunkFrewDistanceComparator(float[] vct)
  {
    vect = vct;
  }
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    float d1 = 0;
    SongChunk s2 = (SongChunk)o2;
    float d2 = 0;
    for(int i = 0; i < s1.freqs.length; i++)
    {
      float vectSqrd = vect[i]*vect[i];
      d1 += vectSqrd - s1.freqs[i]*s1.freqs[i];
      d2 += vectSqrd - s2.freqs[i]*s2.freqs[i];
    }
//    d1 = sqrt(d1);//do i really need to take the square root?
    return (int)(d1 - d2);
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "PlayAFile" });
  }
}
