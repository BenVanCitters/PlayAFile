import ddf.minim.analysis.*;
import ddf.minim.*;

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
    
    float[] leftChannel = sample.getChannel(2);
    totalSampLength = leftChannel.length;
    count = (leftChannel.length / chunkLength) + 1;
    songChunks = new SongChunk[(int)count];
    println("SongChunk count: " + (int)count);
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
        java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0 );
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
  
  void sortSongChunks(java.util.Comparator c)
  {
    long startTm = millis();
    java.util.Arrays.sort( songChunks, c);

    
    println("sorting took " + (millis() - startTm) + " milliseconds");
    renderSpectrograph();
  }
  
  void graphSonChunks()
  {
    long startTm = millis();

    NearestNeighbor nn = new NearestNeighbor(0,songChunks);
    println("nn.chunkList.toArray().length: " + nn.chunkList.toArray().length);
    nn.chunkList.toArray(songChunks);
    println("graphing took " + (millis() - startTm) + " milliseconds");
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
  void  generate(float[] signal) 
  {
    for(int i = 0; i < signal.length; i++)
    {
      curChunkIndex = (int)(curIndex/songChunks[0].buffer.length);
      int curSampIndx = (int)(curIndex%songChunks[curChunkIndex].buffer.length);
      signal[i] = songChunks[curChunkIndex].buffer[curSampIndx];
      if(!isRecording)
        curIndex = (curIndex+1)%totalSampLength;
      else if(curIndex+1 <= totalSampLength) 
        curIndex++;
    }
  }
  //method for AudioSignal interface
  void generate(float[] left, float[] right) 
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
  
  float[] getAvgFreqVect()
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
