class SongSorter
{
  AudioPlayer player;
  FFT fftLin;
  SongChunk[] songChunks;
  long chunkLength = 100;
  
  public SongSorter(AudioPlayer audioPlayer)
  {
    player = audioPlayer;
    fftLin = new FFT( player.bufferSize(), player.sampleRate() );
    
    processSample();
  }
  
  void processSample()
  {
    long count = player.length()/ chunkLength;
    songChunks = new SongChunk[(int)count];
    
    long len = player.length()-fftLin.timeSize();
    int songPos = 0;
    for(int i =0; i< songChunks.length; i++)
    {
      songPos = (int)(chunkLength*i);
      player.cue(songPos);
//      fftLin.forward(player.mix.toArray());
      fftLin.forward(player.mix);
      float[] ffts = new float[fftLin.specSize()];
      for(int j = 0; j < fftLin.specSize(); j++)
      {
        ffts[j] = fftLin.getBand(j);
      }      
      songChunks[i] = new SongChunk((float)chunkLength,
                                    (long)songPos,
                                     ffts,
                                     player.mix.toArray());
    }
    println("songChunks.length(): " + songChunks.length);
  }
}
