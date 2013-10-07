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
  
  public SongSorter(AudioSample audioSample, int chunkSize)
  {
    sample = audioSample;
    chunkLength = (long)1<<chunkSize;//(long)pow(chunkLength,chunkSize);
    processSample();
    drawSpectrograph();
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
    drawSpectrograph();
  }
  
  
  public void draw()
  {
    image(spectrographScr,0,0);
   //draw current waveform 
   int curSampIndx = (int)(curIndex%songChunks[curChunkIndex].buffer.length);
   //draw waveform
   int chunksToDraw = 15;
   int totalSamples = songChunks[0].buffer.length*chunksToDraw;
   int startIndex = max(min(curChunkIndex-chunksToDraw/2,songChunks.length-chunksToDraw),0);
   int endIndex = min(curChunkIndex+chunksToDraw/2,songChunks.length);
   for(int j = 0; j < chunksToDraw; j++)
   {
     int chunkIndex = startIndex + j;
    for(int i = 0; i < songChunks[chunkIndex].buffer.length - 1; i++)
    {
      //switching colors seems to be problematic in 2.0+
      
      if(j == curChunkIndex){
        if((i-curSampIndx) > 0 && (i-curSampIndx) < 4096 && (j == curChunkIndex))
        {  stroke(255,0,0);}
        else{
          stroke(255,255,0);}
      }else{
        stroke(255);}
      float x1 = (map( i, 0, songChunks[chunkIndex].buffer.length, 0, width )+ j*width)/chunksToDraw;
      float x2 = (map( i+1, 0, songChunks[chunkIndex].buffer.length, 0, width )+ j*width)/chunksToDraw;
      line( x1, 150 + songChunks[chunkIndex].buffer[i]*50, 
            x2, 150 + songChunks[chunkIndex].buffer[i+1]*100 );      
    }  
   }
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
  long curIndex = 0;
  void  generate(float[] signal) 
  {
    for(int i = 0; i < signal.length; i++)
    {
      curChunkIndex = (int)(curIndex/songChunks[0].buffer.length);
      int curSampIndx = (int)(curIndex%songChunks[curChunkIndex].buffer.length);
      signal[i] = songChunks[curChunkIndex].buffer[curSampIndx];
      curIndex = (curIndex+1)%totalSampLength;
    }
  }
  void  generate(float[] left, float[] right) 
  {
    generate(left);
    generate(right);
  }
  
  private void drawSpectrograph()
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
}
