class NearestNeighbor
{
//  SongChunk[] songChunks;
  ArrayList<SongChunk> chunkList;
  public NearestNeighbor(int startIndex, SongChunk[] sc)
  {
    chunkList = new ArrayList<SongChunk>();
    boolean[] traveled = new boolean[sc.length];
    traveled[startIndex] = true;
    double[] chunkDists = new double[sc.length];
    
    boolean nodesLeft = true; //whether there are any unexplored nodes left 
//    for(int i = 0; i < sc.length; i++)
    while(nodesLeft)
    {
      chunkList.add(sc[startIndex]);
      chunkDists = new double[sc.length];
      traveled[startIndex] = true;
      
      for(int j = 0; j < chunkDists.length; j++) //get all lengths
      {
        if(!traveled[j])
        {
          chunkDists[j] = getNodeDistByFreqBuffer(sc[startIndex], sc[j]);
        }
        else
        {
          chunkDists[j] = Double.MAX_VALUE;
        }
      } 
      
      int smallestIndex = 0;
      for(int j = 0; j < chunkDists.length; j++)//find smallest length + next node
      {
        if(!traveled[j] && chunkDists[j] < chunkDists[smallestIndex] )
          smallestIndex = j;
      }
      startIndex = smallestIndex;
//      java.util.Arrays.sort( songChunks, c);
      
      //find if there are any untraversed nodes left
      nodesLeft =false;
      int countLeft = 0;
      for(int j = 0; j < traveled.length; j++)
      {
        
        nodesLeft = nodesLeft | !traveled[j];
        if(!traveled[j])
          countLeft++;
//        if(nodesLeft) break;
      }      
      println("remaining nodes: " + countLeft + " smallestIndex: " + smallestIndex + " nodesLeft: " + nodesLeft);
    }
    println("got to the end of the nn");
  }
  
  double getNodeDistBySampleBuffer(SongChunk a, SongChunk b)
  {
    double totalDist = 0.0;
    for(int i = 0; i < a.buffer.length; i++)
    {
      double sqr = a.buffer[i]-b.buffer[i];
      totalDist += sqr*sqr;
    }
    return java.lang.Math.sqrt(totalDist);
  }
  double getNodeDistByFreqBuffer(SongChunk a, SongChunk b)
  {
    double totalDist = 0.0;
    for(int i = 0; i < a.freqs.length; i++)
    {
      double sqr = a.freqs[i]-b.freqs[i];
      totalDist += sqr*sqr;
    }
    return java.lang.Math.sqrt(totalDist);
  }
}//end class
