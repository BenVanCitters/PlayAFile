PlayAFile
=========

This <a href="http://processing.org/">Processing</a> sketch is a audio-file sorter.  The basic premise is take a audio file, break it into little chunks, analyze each of them, re-order the chunks (for example: from loudest to quietest chunk), then play them back in the new order.

The analysis and sorting of the audio file can take some time depending on the algorithm used.  So if you run the sketch prepare to wait a while as everything gets processed.

I have several approaches to this skeleton structure.  The first approach is simply, as above, use a characteristic such as overall chunk/sample volume to arrange samples from 'largest' to 'smallest' (the FFT of each 'chunk' is analyzed as well and can be used for comparisons).  Another approach that I have coded-up into this sketch uses a nearest-neighbor walk though the vector space of the FFT's of the samples/chunks.

Several audio files for experimentation can be found in the data folder.

Simply building your own comparator class such as:

<code>
public class SongChunkMaxAmpComparator implements <a href="http://docs.oracle.com/javase/8/docs/api/java/util/Comparator.html">java.util.Comparator</a>
{
  public int compare(Object o1, Object o2)
  {
    SongChunk s1 = (SongChunk)o1;
    SongChunk s2 = (SongChunk)o2;
    
    return (int)(1000*(s1.maxAmp - s2.maxAmp));
  }
}
</code>

is the easiest way to re-order the results.

If you push 'r' during playback the sketch can record the resulting audio output.


If you are interested in hearing the results of this algorithm check out my uploads at <a href="https://soundcloud.com/benvancitters/sets/sorted-like-teen-spirit">soundcloud</a>

Many thanks to <a href"https://github.com/ddf">Damien Di Fede<a> for his outstanding audio library, <a href="http://code.compartmental.net/tools/minim/">Minim</a>.