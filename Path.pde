/**
 *
 *  Path class contains methods for displaying and modifying A* paths.
 *
 */

class Path {
  LinkedList<PathNode> path = new LinkedList<PathNode>(); // a list of nodes 
  
  float distance = 0; // length of path
  float distToFinish = 0; // the distance between the final node and the path's goal
  
  // the direction the ghost is going at the last point on the path
  PVector velAtLast;
  
  // unique to GhostNEAT
  boolean badPath = false;

  //--------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Constructor method
  */
  
  Path() {
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  addToTail() method adds a node to the end of the path.
  */
  
  void addToTail(PathNode n, PathNode endPathNode)
  {
    if (!path.isEmpty()) // if path is empty then this is the first node and thus the distance is still 0
    {
      distance += dist(path.getLast().x, path.getLast().y, n.x, n.y); // add the distance from the current last element in the path to the new node to the overall distance
    }

    path.add(n); // add the node
    distToFinish = dist(path.getLast().x, path.getLast().y, endPathNode.x, endPathNode.y); // recalculate the distance to the finish
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  createCopy() returns a copy of this Path.
  *  This method was renamed to avoid confusion with clone and deep clone concepts in Java.
  */
  
  Path createCopy()
  {
    Path temp = new Path();
    temp.path = (LinkedList)path.clone();
    temp.distance = distance;
    temp.distToFinish = distToFinish;
    temp.velAtLast = new PVector(velAtLast.x, velAtLast.y);
    return temp;
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  clear() method removes all nodes in the path.
  */
  
  void clear()
  {
    distance = 0;
    distToFinish = 0;
    path.clear();
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  show() method displays the path on screen. 
  */
  
  void show(int ghost) {
    strokeWeight(2);
    
    if (ghost == 0) { // blinky
      fill(255, 0, 0); // red
      stroke(255, 0, 0);
    } else if (ghost == 1) { // clyde
      fill(255, 184, 82); // orange
      stroke(255, 184, 82);
    } else if (ghost == 2) { // inky
      fill(0, 255, 255); // cyan
      stroke(0, 255, 255);
    } else if (ghost == 3) { // pinky
      fill(255, 184, 255); // pink
      stroke(255, 184, 255);
    } else if (ghost == 4) { // pacman
      fill(255, 255, 0);
      stroke(255, 255, 0);
    }
    
    for (int i = 0; i< path.size()-1; i++) {
      PVector CoordOfNode = tileToPixel(new PVector(path.get(i).x, path.get(i).y));
      PVector CoordOfNextNode = tileToPixel(new PVector(path.get(i+1).x, path.get(i+1).y));
      
      line(CoordOfNode.x, CoordOfNode.y, CoordOfNextNode.x, CoordOfNextNode.y);
    }
    
    PVector CoordOfLastNode = tileToPixel(new PVector(path.get(path.size() -1).x, path.get(path.size() -1).y));
    ellipse(CoordOfLastNode.x, CoordOfLastNode.y, 5, 5); // ellipse of target
  }
}
