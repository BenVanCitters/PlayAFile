class SongChunk
{
  float duration;
  long startTime;
  float freqMoment;
  float[] freqs;
  
  public SongChunk(  float dur,  long startTm,  float[] frqs)
  {
    duration = dur;
    startTime = startTm;
    freqs = frqs;
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
//    println("totalMass: " + totalMass + " freqMoment: " + freqMoment);
  }
  
}
