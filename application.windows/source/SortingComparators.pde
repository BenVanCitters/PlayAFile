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

