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
  
}
