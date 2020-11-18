/**
 *
 *  connectionHistory class determines which connections are already present in the neural network.
 *  Contains matches() method, which returns whether a given connection already exists in the neural network.
 *
 */

class connectionHistory {
  int fromNode;
  int toNode;
  int innovationNumber;

  // the innovation Numbers from the connections of the genome which first had this mutation 
  ArrayList<Integer> innovationNumbers = new ArrayList<Integer>();

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  connectionHistory() constructor method gets the nodes a given connection is connected to, as well as its innovation number.
  */
  
  connectionHistory(int from, int to, int inno, ArrayList<Integer> innovationNos) {
    fromNode = from;
    toNode = to;
    innovationNumber = inno;
    innovationNumbers = (ArrayList)innovationNos.clone();
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  matches() method returns whether the genome matches the original genome and the connection is between the same nodes.
  */
  
  boolean matches(Genome genome, Node from, Node to) {
    if (genome.genes.size() == innovationNumbers.size()) { // if the number of connections are different then the genoemes aren't the same
      if (from.number == fromNode && to.number == toNode) {
        // next check if all the innovation numbers match from the genome
        for (int i = 0; i< genome.genes.size(); i++) {
          if (!innovationNumbers.contains(genome.genes.get(i).innovationNo)) {
            return false;
          }
        }

        /* if reached this far then the innovationNumbers match the gene's innovation numbers and the connection is between the same nodes
           so it does match */
        return true;
      }
    }
    return false;
  }
}
