public class SongChunkFreqComparator implements java.util.Comparator
{
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    SongChunk s2 = (SongChunk)o2;
    
    return (int)(s1.freqMoment - s2.freqMoment);
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
