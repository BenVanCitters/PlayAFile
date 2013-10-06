import ddf.minim.analysis.*;
import ddf.minim.*;

class SongSorter implements AudioSignal
{
  AudioSample sample;
  FFT fftLin;
  SongChunk[] songChunks;
  long chunkLength = 100;
  long count=-1;
  int totalSampLength;
  public SongSorter(AudioSample audioSample)
  {
    println("starting...");
    sample = audioSample;
    
    processSample();
  }
  
  private void processSample()
  {    
    int fftSize = 512;
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
     if(songChunks[i].totalMass > 0)
       println("totalMass: " + songChunks[i].totalMass + 
               " freqMoment: " + songChunks[i].freqMoment);
    }
    println("songChunks.length(): " + songChunks.length);
  }
  
  void sortSongChunks(java.util.Comparator c)
  {
    java.util.Arrays.sort( songChunks, c);
  }
  
  
  float cameraPos = 0;
  public void resetCameraPos()
  {
    cameraPos = 0;
  }
  
  public void draw()
  {
    // how many units to step per second
    float cameraStep = 5000;
    // our current z position for the camera
    
    // how far apart the spectra are so we can loop the camera back
    float spectraSpacing = 50;    
    
    float dt = 1.0 / frameRate;

  cameraPos += cameraStep * dt;

  // jump back to start position when we get to the end
  if ( cameraPos > songChunks.length * spectraSpacing )
  {
    cameraPos = 0;
  }
    for (int s = 0; s < songChunks.length; s++)
    {
      float z = s * spectraSpacing;
      // don't draw spectra that are behind the camera or too far away
      if ( z > cameraPos - 150 && z < cameraPos + 2000 )
      {
        for (int i = 0; i < songChunks[s].freqs.length-1; ++i )
        {
          line(-256 + i, songChunks[s].freqs[i]*25, z, -256 + i + 1, songChunks[s].freqs[i+1]*25, z);
        }
      }
    }
    camera( -200, 100, -200 + cameraPos, 
    75, 50, cameraPos+5000, 
    0, -1, 0 );
  }
  
  long curIndex = 0;
  void  generate(float[] signal) 
  {
    
    for(int i = 0; i < signal.length; i++)
    {
      int chunkIndex = (int)(curIndex/songChunks[0].buffer.length);
      int curSampIndx = (int)(curIndex%songChunks[chunkIndex].buffer.length);
      signal[i] = songChunks[chunkIndex].buffer[curSampIndx];
      curIndex = (curIndex+1)%totalSampLength;
    }
  }
  void  generate(float[] left, float[] right) 
  {
    generate(left);generate(right);
  }
}
