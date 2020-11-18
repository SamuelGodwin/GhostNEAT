/**
 *
 *  Genome class represents the neural network 'brains' of the ghosts.
 *  Includes methods for constructing and mutating the network.
 *
 */

class Genome {
  int inputs;
  int outputs;
  int layers = 2;
  int nextNode = 0;
  int biasNode;
    
  ArrayList<connectionGene> genes = new  ArrayList<connectionGene>(); // a list of connections between nodes which represent the NN
  ArrayList<Node> nodes = new ArrayList<Node>(); // list of nodes
  ArrayList<Node> network = new ArrayList<Node>(); // a list of the nodes in the order that they need to be considered in the NN
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Genome() is a constructor method which creates the initial nodes of the neural network.
  */
  
  Genome(int in, int out) {
    // set input number and output number
    inputs = in;
    outputs = out;

    // create input nodes
    for (int i = 0; i<inputs; i++) {
      nodes.add(new Node(i));
      nextNode ++;
      nodes.get(i).layer = 0;
    }

    // create output nodes
    for (int i = 0; i < outputs; i++) {
      nodes.add(new Node(i+inputs));
      nodes.get(i+inputs).layer = 1;
      nextNode++;
    }

    nodes.add(new Node(nextNode)); // bias node
    biasNode = nextNode;
    nextNode++;
    nodes.get(biasNode).layer = 0;
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  getNode() method returns the node with a matching number. Sometimes the nodes will not be in order.
  */
  
  Node getNode(int nodeNumber) {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).number == nodeNumber) {
        return nodes.get(i);
      }
    }
    return null;
  }


  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  connectnodes() adds the outgoing conenctions of a node to that node so that it can acess the next node during feeding forward.
  */
  
  void connectNodes() {
    for (int i = 0; i< nodes.size(); i++) { // clear the connections
      nodes.get(i).outputConnections.clear();
    }

    for (int i = 0; i < genes.size(); i++) { // for each connectionGene 
      genes.get(i).fromNode.outputConnections.add(genes.get(i)); // add it to node
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  feedForward() method feeds input values into the NN and returns an array of its outputs.
  */
  
  float[] feedForward(float[] inputValues) {
    // set the outputs of the input nodes
    for (int i = 0; i < inputs; i++) {
      nodes.get(i).outputValue = inputValues[i];
      if (i < 4) {
      }
    }
    nodes.get(biasNode).outputValue = 1; // output of bias is 1

    for (int i = 0; i< network.size(); i++) { // for each node in the network engage it(see node class for what this does)
      network.get(i).engage();
    }

    // the outputs are nodes[inputs] to nodes [inputs+outputs-1]
    float[] outs = new float[outputs];
    for (int i = 0; i < outputs; i++) {
      outs[i] = nodes.get(inputs + i).outputValue;
    }

    for (int i = 0; i < nodes.size(); i++) { // reset all the nodes for the next feed forward
      nodes.get(i).inputSum = 0;
    }

    return outs;
  }

  //----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  The generateNetwork() method sets up the NN as a list of nodes in order to be engaged.
  */
  
  void generateNetwork() {
    connectNodes();
    network = new ArrayList<Node>();
    
    // for each layer add the nodes in that layer, since layers cannot connect to themselves there is no need to order the nodes within a layer
    for (int l = 0; l< layers; l++) {
      for (int i = 0; i< nodes.size(); i++) {
        // if that node is in that layer
        if (nodes.get(i).layer == l) {
          network.add(nodes.get(i));
        }
      }
    }
  }
  
  //-----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  addNode() mutates the network by adding a new node. It does this by picking a random connection and disabling it before adding 2 new connections.
  *  1 conneciton is added between the input node of the disabled connection and the new node; and the other is added between the new node and the output of the disabled connection.
  */
  
  void addNode(ArrayList<connectionHistory> innovationHistory) {
    // pick a random connection to create a node between
    if (genes.size() ==0) {
      addConnection(innovationHistory); 
      return;
    }
    int randomConnection = floor(random(genes.size()));

    while (genes.get(randomConnection).fromNode == nodes.get(biasNode) && genes.size() !=1 ) { // don't disconnect bias
      randomConnection = floor(random(genes.size()));
    }

    genes.get(randomConnection).enabled = false; // disable it

    int newNodeNo = nextNode;
    nodes.add(new Node(newNodeNo));
    nextNode ++;
    // add a new connection to the new node with a weight of 1
    int connectionInnovationNumber = getInnovationNumber(innovationHistory, genes.get(randomConnection).fromNode, getNode(newNodeNo));
    genes.add(new connectionGene(genes.get(randomConnection).fromNode, getNode(newNodeNo), 1, connectionInnovationNumber));


    connectionInnovationNumber = getInnovationNumber(innovationHistory, getNode(newNodeNo), genes.get(randomConnection).toNode);
    // add a new connection from the new node with a weight the same as the disabled connection
    genes.add(new connectionGene(getNode(newNodeNo), genes.get(randomConnection).toNode, genes.get(randomConnection).weight, connectionInnovationNumber));
    getNode(newNodeNo).layer = genes.get(randomConnection).fromNode.layer +1;


    connectionInnovationNumber = getInnovationNumber(innovationHistory, nodes.get(biasNode), getNode(newNodeNo));
    // connect the bias to the new node with a weight of 0 
    genes.add(new connectionGene(nodes.get(biasNode), getNode(newNodeNo), 0, connectionInnovationNumber));

    /* if the layer of the new node is equal to the layer of the output node of the old connection then a new layer needs to be created
       more accurately the layer numbers of all layers equal to or greater than this new node need to be incrimented */
    if (getNode(newNodeNo).layer == genes.get(randomConnection).toNode.layer) {
      for (int i = 0; i< nodes.size() -1; i++) { // don't include this newest node
        if (nodes.get(i).layer >= getNode(newNodeNo).layer) {
          nodes.get(i).layer ++;
        }
      }
      layers ++;
    }
    connectNodes();
  }

  //------------------------------------------------------------------------------------------------------------------
  
  /**
  *  addConnection() adds a connection between 2 random nodes which aren't currently connected
  */
  
  void addConnection(ArrayList<connectionHistory> innovationHistory) {
    // cannot add a connection to a fully connected network
    if (fullyConnected()) {
      return; // connection failed
    }


    // get random nodes
    int randomNode1 = floor(random(nodes.size())); 
    int randomNode2 = floor(random(nodes.size()));
    while (randomConnectionNodesAreBad(randomNode1, randomNode2)) { // while the random nodes are no good
      // get new ones
      randomNode1 = floor(random(nodes.size())); 
      randomNode2 = floor(random(nodes.size()));
    }
    int temp;
    if (nodes.get(randomNode1).layer > nodes.get(randomNode2).layer) { // if the first random node is after the second then switch
      temp = randomNode2;
      randomNode2 = randomNode1;
      randomNode1 = temp;
    }

    /* get the innovation number of the connection
       this will be a new number if no identical genome has mutated in the same way */
    int connectionInnovationNumber = getInnovationNumber(innovationHistory, nodes.get(randomNode1), nodes.get(randomNode2));
    // add the connection with a random array

    genes.add(new connectionGene(nodes.get(randomNode1), nodes.get(randomNode2), random(-1, 1), connectionInnovationNumber)); // changed this so if error here
    connectNodes();
  }
  
  //------------------------------------------------------------------------------------------------------------------
  
  /**
  *  addCXConnection() adds the connections of the demonstration brain to the neural network.
  *  Code unique to GhostNEAT.
  */
  
  void addCXConnection(ArrayList<connectionHistory> innovationHistory) {
    // cannot add a connection to a fully connected network
    if (fullyConnected()) {
      return; // connection failed
    }
    
    /* get the innovation number of the connection
       this will be a new number if no identical genome has mutated in the same way */
    int connectionInnovationNumber1 = getInnovationNumber(innovationHistory, nodes.get(0), nodes.get(9));
    int connectionInnovationNumber2 = getInnovationNumber(innovationHistory, nodes.get(1), nodes.get(10));
    int connectionInnovationNumber3 = getInnovationNumber(innovationHistory, nodes.get(2), nodes.get(11));
    int connectionInnovationNumber4 = getInnovationNumber(innovationHistory, nodes.get(3), nodes.get(12));

    genes.add(new connectionGene(nodes.get(0), nodes.get(9), 1, connectionInnovationNumber1));
    genes.add(new connectionGene(nodes.get(1), nodes.get(10), 1, connectionInnovationNumber2));
    genes.add(new connectionGene(nodes.get(2), nodes.get(11), -1, connectionInnovationNumber3));
    genes.add(new connectionGene(nodes.get(3), nodes.get(12), 1, connectionInnovationNumber4));
    connectNodes();
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  randomConnectionNodesAreBad() method determines whether the random nodes chosen by addconnection() are useful or not.
  */
  boolean randomConnectionNodesAreBad(int r1, int r2) {
    if (nodes.get(r1).layer == nodes.get(r2).layer) return true; // if the nodes are in the same layer 
    if (nodes.get(r1).isConnectedTo(nodes.get(r2))) return true; // if the nodes are already connected
    if (r1 < inputs && (r1 > usingInputsEnd || r1 < usingInputsStart)) {
      return true; // if r1 is an input and is not between the nodes we are using
    }
    if (r2 < inputs && (r2 > usingInputsEnd || r2 < usingInputsStart)) {
      return true; // if r1 is an input and is not between the nodes we are using
    } // if r2 is an input and is not betweent he nods we are using  


    return false;
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  getInnovationNumber() returns the innovation number for new mutations. If the mutation has never been seen before then it will be given a new unique innovation number.
  *  If the mutation matches a previous mutation then it will be given the same innovation number as the previous one.
  */
  
  
  int getInnovationNumber(ArrayList<connectionHistory> innovationHistory, Node from, Node to) {
    boolean isNew = true;
    int connectionInnovationNumber = nextConnectionNo;
    for (int i = 0; i < innovationHistory.size(); i++) { // for each previous mutation
      if (innovationHistory.get(i).matches(this, from, to)) { // if match found
        isNew = false; // its not a new mutation
        connectionInnovationNumber = innovationHistory.get(i).innovationNumber; // set the innovation number as the innovation number of the match
        break;
      }
    }

    if (isNew) { // if the mutation is new then create an arrayList of integers representing the current state of the genome
      ArrayList<Integer> innoNumbers = new ArrayList<Integer>();
      for (int i = 0; i< genes.size(); i++) { // set the innovation numbers
        innoNumbers.add(genes.get(i).innovationNo);
      }

      // then add this mutation to the innovationHistory 
      innovationHistory.add(new connectionHistory(from.number, to.number, connectionInnovationNumber, innoNumbers));
      nextConnectionNo++;
    }
    return connectionInnovationNumber;
  }
  
  //----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  fullyConnected() method returns whether the network is fully connected (all nodes of each layer are connected to all nodes of the next layer) or not.
  */
  
  boolean fullyConnected() {
    int maxConnections = 0;
    int[] nodesInLayers = new int[layers]; // array which stored the amount of nodes in each layer

    nodesInLayers[0] = usingInputsEnd - usingInputsStart +1 +1;
    // populate array
    for (int i =1; i< nodes.size(); i++) {
      nodesInLayers[nodes.get(i).layer] +=1;
    }

    /* for each layer the maximum amount of connections is the number in this layer * the number of nodes infront of it
       so lets add the max for each layer together and then we will get the maximum amount of connections in the network */
    for (int i = 0; i < layers-1; i++) {
      int nodesInFront = 0;
      for (int j = i+1; j < layers; j++) { // for each layer in front of this layer
        nodesInFront += nodesInLayers[j]; // add up nodes
      }

      maxConnections += nodesInLayers[i] * nodesInFront;
    }

    if (maxConnections == genes.size()) { // if the number of connections is equal to the max number of connections possible then it is full
      return true;
    }
    return false;
  }

  //-------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  mutate() method mutates the method by mutating the connection weights (80% chance), adding a new connection (50% chance), or adding a new node (2% chance). 
  */
  
  void mutate(ArrayList<connectionHistory> innovationHistory) {
    if (genes.size() == 0) {
      addConnection(innovationHistory);
    }

    // 80% of the time mutate weights
    float rand1 = random(1);
    if (rand1 <= 0.8) { 
      for (int i = 0; i < genes.size(); i++) {
        genes.get(i).mutateWeight();
      }
    }
    
    // 50% of the time add a new connection
    float rand2 = random(1);
    if (rand2 < 0.5) {
      addConnection(innovationHistory);
    }

    // 2% of the time add a node
    float rand3 = random(1);
    if (rand3 <= 0.02) {
      addNode(innovationHistory);
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  crossover() method handles crossover of two genomes. It is called when this Genome is better than the other parent.
  */
  
  Genome crossover(Genome parent2) {
    Genome child = new Genome(inputs, outputs, true);
    child.genes.clear();
    child.nodes.clear();
    child.layers = layers;
    child.nextNode = nextNode;
    child.biasNode = biasNode;
    ArrayList<connectionGene> childGenes = new ArrayList<connectionGene>(); // list of genes to be inherrited from the parents
    ArrayList<Boolean> isEnabled = new ArrayList<Boolean>(); 
    // all inherrited genes
    for (int i = 0; i< genes.size(); i++) {
      boolean setEnabled = true; // is this node in the child going to be enabled

      int parent2gene = matchingGene(parent2, genes.get(i).innovationNo);
      if (parent2gene != -1) { // if the genes match
        if (!genes.get(i).enabled || !parent2.genes.get(parent2gene).enabled) { // if either of the matching genes are disabled

          if (random(1) < 0.75) { // 75% of the time disable the childs gene
            setEnabled = false;
          }
        }
        float rand = random(1);
        if (rand<0.5) {
          // get gene
          childGenes.add(genes.get(i));

        } else {
          // get gene from parent2
          childGenes.add(parent2.genes.get(parent2gene));
        }
      } else { // disjoint or excess gene
        childGenes.add(genes.get(i));
        setEnabled = genes.get(i).enabled;
      }
      isEnabled.add(setEnabled);
    }


    /* since all excess and disjoint genes are inherrited from the more fit parent (this Genome) the childs structure is no different from this parent | with exception of dormant connections being enabled but this won't effect nodes
       so all the nodes can be inherrited from this parent */
    for (int i = 0; i < nodes.size(); i++) {
      child.nodes.add(nodes.get(i).createCopy());
    }

    // clone all the connections so that they connect the childs new nodes

    for ( int i =0; i<childGenes.size(); i++) {
      child.genes.add(childGenes.get(i).createCopy(child.getNode(childGenes.get(i).fromNode.number), child.getNode(childGenes.get(i).toNode.number)));
      child.genes.get(i).enabled = isEnabled.get(i);
    }

    child.connectNodes();
    return child;
  }

  //----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Second constructor method for creating an empty Genome.
  */

  Genome(int in, int out, boolean crossover) {
    // set input number and output number
    inputs = in; 
    outputs = out;
  }
  
  //----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  matchingGene() method returns whether or not there is a connection matching the input innovation number in the input genome.
  */
  
  int matchingGene(Genome parent2, int innovationNumber) {
    for (int i = 0; i < parent2.genes.size(); i++) {
      if (parent2.genes.get(i).innovationNo == innovationNumber) {
        return i;
      }
    }
    return -1; // no matching gene found
  }

  //----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  createCopy() method returns a copy of this genome.
  *  This method was renamed to avoid confusion with clone and deep clone concepts in Java.
  */
  
  Genome createCopy() {
    Genome copyOf = new Genome(inputs, outputs, true);

    for (int i = 0; i < nodes.size(); i++) { // copy nodes
      copyOf.nodes.add(nodes.get(i).createCopy());
    }

    // copy all the connections so that they connect the copyOf new nodes

    for ( int i =0; i<genes.size(); i++) { // copy genes
      copyOf.genes.add(genes.get(i).createCopy(copyOf.getNode(genes.get(i).fromNode.number), copyOf.getNode(genes.get(i).toNode.number)));
    }

    copyOf.layers = layers;
    copyOf.nextNode = nextNode;
    copyOf.biasNode = biasNode;
    copyOf.connectNodes();

    return copyOf;
  }
  
  //----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  drawGenome() draws the Genome on the screen in the location given as parameters.
  */
  
  void drawGenome(int startX, int startY, int w, int h) {
    ArrayList<ArrayList<Node>> allNodes = new ArrayList<ArrayList<Node>>();
    ArrayList<PVector> nodePoses = new ArrayList<PVector>();
    ArrayList<Integer> nodeNumbers= new ArrayList<Integer>();

    // split the nodes into layers
    for (int i = 0; i< layers; i++) {
      ArrayList<Node> temp = new ArrayList<Node>();
      for (int j = 0; j< nodes.size(); j++) { // for each node 
        if (nodes.get(j).layer == i ) { // check if it is in this layer
          temp.add(nodes.get(j)); // add it to this layer
        }
      }
      allNodes.add(temp); // add this layer to all nodes
    }

    // for each layer add the position of the node on the screen to the node posses arraylist
    for (int i = 0; i < layers; i++) {
      fill(255, 0, 0);
      float x = startX + (float)((i+1)*w)/(float)(layers+1.0);
      for (int j = 0; j < allNodes.get(i).size(); j++) { // for the position in the layer
        float y = startY + ((float)(j + 1.0) * h)/(float)(allNodes.get(i).size() + 1.0);
        nodePoses.add(new PVector(x, y));
        nodeNumbers.add(allNodes.get(i).get(j).number);
      }
    }

    // draw connections 
    stroke(0);
    strokeWeight(2);
    for (int i = 0; i< genes.size(); i++) {
      if (genes.get(i).enabled) {
        stroke(0);
      } else {
        stroke(100);
      }
      PVector from;
      PVector to;
      from = nodePoses.get(nodeNumbers.indexOf(genes.get(i).fromNode.number));
      to = nodePoses.get(nodeNumbers.indexOf(genes.get(i).toNode.number));
      if (genes.get(i).weight > 0) {
        stroke(255, 0, 0);
      } else {
        stroke(0, 0, 255);
      }
      strokeWeight(map(abs(genes.get(i).weight), 0, 1, 0, 5));
      line(from.x, from.y, to.x, to.y);
    }

    // draw nodes last so they appear ontop of the connection lines
    for (int i = 0; i < nodePoses.size(); i++) {
      fill(255);
      stroke(0);
      strokeWeight(1);
      ellipse(nodePoses.get(i).x, nodePoses.get(i).y, 20, 20);
      textSize(10);
      fill(0);
      textAlign(CENTER, CENTER);
      text(nodeNumbers.get(i), nodePoses.get(i).x, nodePoses.get(i).y);
    }
  }
}
