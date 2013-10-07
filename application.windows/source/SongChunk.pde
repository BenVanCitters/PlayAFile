class SongChunk
{
  float duration;
  long startTime;
  float maxAmp;
  float freqMoment;
  float totalMass;
  float[] freqs;
  float[] buffer;
  
  public SongChunk(  float dur,  long startTm,  float[] frqs,float[] buf)
  {
    duration = dur;
    startTime = startTm;
    freqs = java.util.Arrays.copyOf(frqs,frqs.length);
    buffer = java.util.Arrays.copyOf(buf,buf.length);
    findFreqMoment();
    findMaxAmp();
  }
  
  void findMaxAmp()
  {
    maxAmp =-10;
    for(int j = 0; j < buffer.length; j++)
    {
      maxAmp = max(maxAmp,buffer[j]);
    }
//    println(maxAmp);
  }
  
  //get the 'centroid' of the spetrograph - using a poor-man's 
  //algorith
  void findFreqMoment()
  {
    totalMass = 0;
    for(int j = 0; j < freqs.length; j++)
    {
      totalMass += freqs[j];
    }

    float halfMass = totalMass/2;
    int index = 0;
    float accumulator = 0;
    int i = 0;
    for(i = 0; (i < freqs.length) && (accumulator <  halfMass); i++)
    {
      accumulator += freqs[i];
    }
    freqMoment = i;
//    println("totalMass: " + totalMass + " freqMoment: " + freqMoment);
  }
  
  //as of 10-6-13 this function doesn't play nice with processing 2.0.3
  void draw(int curIndex)
  {    
    noFill();
    stroke(255);
    
    //draw spectrum
    for(int i = 0; i < width; i++)
    {
      line(i, height, i, height - freqs[i*freqs.length/width]*4);
    }
    
    //draw waveform
    for(int i = 0; i < buffer.length - 1; i++)
    {
      //switching colors seems to be problematic in 2.0+
      if((i-curIndex) > 0 && (i-curIndex) < 4096)
        stroke(255,0,0);
      else
        stroke(255);
      float x1 = map( i, 0, buffer.length, 0, width );
      float x2 = map( i+1, 0, buffer.length, 0, width );
      line( x1, 150 + buffer[i]*50, x2, 150 + buffer[i+1]*100 );      
    }   
  }
}
