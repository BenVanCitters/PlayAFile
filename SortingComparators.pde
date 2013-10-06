public class SongChunkFreqComparator implements java.util.Comparator
{
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    SongChunk s2 = (SongChunk)o2;
    
    return (int)(s2.freqMoment - s1.freqMoment);
  }
}

