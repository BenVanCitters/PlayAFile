class SongChunk
{
  float duration;
  long startTime;
  float freqMoment;
  float[] freqs;
  float[] buffer;
  
  public SongChunk(  float dur,  long startTm,  float[] frqs,float[] buf)
  {
    duration = dur;
    startTime = startTm;
    freqs = frqs;
    buffer = Arrays.copyOf(buf,buf.length);
    findFreqMoment();
  }
  
  void findFreqMoment()
  {
    float totalMass = 0;
    for(int j = 0; j < freqs.length; j++)
    {
      totalMass += freqs[j];
    }
    float halfMass = totalMass/2;
    int index = 0;
//     println("freqs.length: " + freqs.length + " totalMass: " + totalMass);
    for(float accumulator = 0; accumulator <= halfMass && halfMass > 0; accumulator+=freqs[index])
    {
      index++;
    }
    freqMoment = index;
    println("totalMass: " + totalMass + " freqMoment: " + freqMoment);
  }
  
  void draw()
  {
    //draw spectrum
    noFill();
    for(int i = 0; i < fftLin.specSize(); i++)
    {
      line(i, height, i, height - fftLin.getBand(i)*4);
    }
    
    //draw waveform
    for(int i = 0; i < buffer.length - 1; i++)
    {
      float x1 = map( i, 0, buffer.length, 0, width );
      float x2 = map( i+1, 0, buffer.length, 0, width );
      line( x1, 50 + buffer[i]*50, x2, 50 + buffer[i+1]*50 );
      line( x1, 150 + buffer[i]*50, x2, 150 + buffer[i+1]*50 );
    }
   
  }
}
