/**
 *
 *  Node class contains methods for engaging and activating nodes in the neural network, including the sigmoid function, which takes input values and outputs values between 0-1.
 *
 */

class Node {
  int number;
  int layer = 0; // neural network layer
  
  float inputSum = 0; // current sum i.e. before activation
  float outputValue = 0; // after activation function is applied
  
  PVector drawPos = new PVector();
  
  ArrayList<connectionGene> outputConnections = new ArrayList<connectionGene>();
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Node() constructor method just sets the number field.
  */
  
  Node(int no) {
    number = no;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  engage() method. The node sends its output to the inputs of the nodes it is connected to.
  */
  
  void engage() {
    if (layer != 0) { // no sigmoid for the inputs and bias
      outputValue = sigmoid(inputSum);
    }

    for (int i = 0; i< outputConnections.size(); i++) { // for each connection
      if (outputConnections.get(i).enabled) {
        outputConnections.get(i).toNode.inputSum += outputConnections.get(i).weight * outputValue; // add the weighted output to the sum of the inputs of whatever node this node is connected to
      }
    }
 }
 
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  The sigmoid activation function. This function is used to squash inputs into outputs of the range 0-1.
  */
  
  float sigmoid(float x) {
    float y = 1 / (1 + pow((float)Math.E, -4.9*x));
    return y;
  }
  
  //----------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  isConnectedTo() method returns whether this node is connected to the parameter node. It is used when adding a new connection.
  */
  
  boolean isConnectedTo(Node node) {
    if (node.layer == layer) { // nodes in the same layer cannot be connected
      return false;
    }

    if (node.layer < layer) {
      for (int i = 0; i < node.outputConnections.size(); i++) {
        if (node.outputConnections.get(i).toNode == this) {
          return true;
        }
      }
    } else {
      for (int i = 0; i < outputConnections.size(); i++) {
        if (outputConnections.get(i).toNode == node) {
          return true;
        }
      }
    }

    return false;
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  createCopy() method returns a copy of this node.
  *  This method was renamed to avoid confusion with clone and deep clone concepts in Java.
  */
  
  Node createCopy() {
    Node copyOf = new Node(number);
    copyOf.layer = layer;
    return copyOf;
  }
}
