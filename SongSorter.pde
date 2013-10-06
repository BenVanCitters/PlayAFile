import ddf.minim.analysis.*;
import ddf.minim.*;

class SongSorter
{
  AudioSample sample;
  FFT fftLin;
  SongChunk[] songChunks;
  long chunkLength = 100;
  
  public SongSorter(AudioSample audioSample)
  {
    println("starting...");
    sample = audioSample;
    
    processSample();
    
  }
  
  void processSample()
  {
    
    int fftSize = 256;
    float[] fftSamples = new float[fftSize];
    fftLin = new FFT( fftSize, sample.sampleRate() );
    
    float[] leftChannel = sample.getChannel(BufferedAudio.LEFT);
    long count = (leftChannel.length / fftSize) + 1;
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
}
