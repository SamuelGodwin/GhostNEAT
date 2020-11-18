/**
 *
 *  connectionGene class for connections between nodes in a neural network.
 *  Contains mutateWeight() method to randomly adjust the weight of the connection.
 *
 */

class connectionGene {
  Node fromNode;
  Node toNode;
  
  float weight;
  
  boolean enabled = true;
  
  // each connection is given a innovation number to compare genomes
  int innovationNo;
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  connectionGene() constructor method sets the nodes the connection is connected to, as well as its weight and innovation number.
  */
  
  connectionGene(Node from, Node to, float w, int inno) {
    fromNode = from;
    toNode = to;
    weight = w;
    innovationNo = inno;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  mutateWeight() method randomly adjusts the weight of the connection.
  */
  
  void mutateWeight() {
    float rand2 = random(1);
    if (rand2 < 0.1) { // 10% of the time completely change the weight
      weight = random(-1, 1);
    } else { // otherwise slightly change it
      weight += randomGaussian()/50;
      // keep weight between bounds
      if(weight > 1){
        weight = 1;
      }
      if(weight < -1){
        weight = -1;        
        
      }
    }
  }

  //----------------------------------------------------------------------------------------------------------
  
  /**
  *  createCopy() method returns a copy of this connection.
  *  This method was renamed to avoid confusion with clone and deep clone concepts in Java.
  */
  
  connectionGene createCopy(Node from, Node  to) {
    connectionGene copyOf = new connectionGene(from, to, weight, innovationNo);
    copyOf.enabled = enabled;

    return copyOf;
  }
}
