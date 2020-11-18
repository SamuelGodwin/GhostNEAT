/**
 *
 *  Player class is the principal evolving agent. Contains a Pac-Man object and the 4 ghost objects, as well as their Genomes.
 *  Contains methods for obtaining ghost 'vision' and getting action decisions from the NN.
 *
 */

class Player {
  Ghost blinky;
  Ghost clyde;
  Ghost inky;
  Ghost pinky;
  
  Pacman pac;
  
  // unique to GhostNEAT
  Genome blinkyBrain;
  Genome clydeBrain;
  Genome inkyBrain;
  Genome pinkyBrain;
  Genome brain;
  
  Path bestPath;
  
  // unique to GhostNEAT
  Path bestVisionPath;
  
  float[] vision = new float[9]; // the input array fed into the neuralNet
  
  // unique to GhostNEAT
  float[] blinkyVision = new float[9]; // the input array fed into Blinky's neuralNet
  float[] clydeVision = new float[9]; // the input array fed into Clyde's neuralNet
  float[] inkyVision = new float[9]; // the input array fed into Inky's neuralNet
  float[] pinkyVision = new float[9]; // the input array fed into pinky's neuralNet
  float[] blinkyDecision = new float[4]; // the output of Blinky's NN
  float[] clydeDecision = new float[4]; // the output of Clyde's NN
  float[] inkyDecision = new float[4]; // the output of Inky's NN
  float[] pinkyDecision = new float[4]; // the output of Pinky's NN
  
  float fitness;
  
  // stores the score achieved used for replay
  int bestScore = 0;
  int score;
  // longer chase lowers score by more - unique to GhostNEAT
  int timeScore = 0;
  int gen = 0;
  int stage = 1; // used for gen
  int id;
  
  boolean dead;
  boolean isBest = false;
  
  // unique to GhostNEAT
  ArrayList<PathNode> ghostPathNodes = new ArrayList<PathNode>(); // the nodes making up the path including the ghost's position and the target position
  ArrayList<PathNode> visionPathNodes = new ArrayList<PathNode>();
  ArrayList<Path> visionPath = new ArrayList<Path>(); // 0 - ahead, 1 - right, 2 - behind, 3 - left
  ArrayList<Path> blinkyVisionPath = new ArrayList<Path>();
  ArrayList<Path> clydeVisionPath = new ArrayList<Path>();
  ArrayList<Path> inkyVisionPath = new ArrayList<Path>();
  ArrayList<Path> pinkyVisionPath = new ArrayList<Path>();
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Player() constructor method initialises Pac-Man, the ghosts and all brain Genomes.
  */
  
  Player() {
    blinky = new Ghost(this, 0);
    clyde = new Ghost(this, 1);
    inky = new Ghost(this, 2);
    pinky = new Ghost(this, 3);
    pac = new Pacman(this);
    
    blinkyBrain = new Genome(9, 4);
    clydeBrain = new Genome(9, 4);
    inkyBrain = new Genome(9, 4);
    pinkyBrain = new Genome(9, 4);
    brain = new Genome(9, 4);
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  show() method displays Pac-Man and the ghosts on screen, as well as Pac-Man's food/big dot tiles, and the ghosts' vision paths.
  *  All code for showing paths in this method is unique to GhostNEAT.
  */
  
  void show() {
    for (int i = 0; i< 28; i++) {
      for (int j = 0; j< 31; j++) {
          pac.tiles[j][i].show();
      }
    }
    
    if (blinkyActive) {
      blinky.show(0);
    }
    if (clydeActive) {
      clyde.show(1);
    }
    if (inkyActive) {
      inky.show(2);
    }
    if (pinkyActive) {
      pinky.show(3);
    }
    pac.show();
    
    if (showVision) {
      ArrayList<ArrayList<Path>> allGhostPaths = new ArrayList<ArrayList<Path>>();
    
      if (blinkyActive) {
        allGhostPaths.add(blinkyVisionPath);
      }
      if (clydeActive) {
        allGhostPaths.add(clydeVisionPath);
      }
      if (inkyActive) {
        allGhostPaths.add(inkyVisionPath);
      }
      if (pinkyActive) {
        allGhostPaths.add(pinkyVisionPath);
      }
      
      for (int j = 0; j < allGhostPaths.size(); j++) {
        for (Path i : allGhostPaths.get(j)) {
          if (i != null) {
            i.show(j);
          }
        }
      }
    }
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  move() method calls the move methods of all ghosts and Pac-Man.
  */
  
  void move() {
    if (blinkyActive) {
      blinky.move();
    }
    if (clydeActive) {
      clyde.move();
    }
    if (inkyActive) {
      inky.move();
    }
    if (pinkyActive) {
      pinky.move();
    }
    pac.move();
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  update() method calls the move() and checkGameState() methods.
  */
  
  void update() {
    move();
    checkGameState();
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  checkGameState() method marks this Player dead if its run has ended.
  */
  
  void checkGameState() {
    if (pac.gameOver) {
      dead = true;
    }
  }
  
  //----------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  look() method obtains the ghosts' vision in the form of an array of float values.
  *  Adapted from PacNEAT.
  */
  
  void look() {
    if (isCriticalPosition(blinky.pos)) {
      blinkyVision = new float[9];
      clydeVision = new float[9];
      inkyVision = new float[9];
      pinkyVision = new float[9];
      
      if (visionVersion == 1) {
        if (blinkyActive) {
          vision1(blinky);
        }
        if (clydeActive) {
          vision1(clyde);
        }
        if (inkyActive) {
          vision1(inky);
        }
        if (pinkyActive) {
          vision1(pinky);
        }
      } else if (visionVersion == 2) {
        if (blinkyActive) {
          vision2(blinky);
        }
        if (clydeActive) {
          vision2(clyde);
        }
        if (inkyActive) {
          vision2(inky);
        }
        if (pinkyActive) {
          vision2(pinky);
        }
      }
      
      if (blinkyActive) {
        setDistanceToWalls(blinky);
      }
      if (clydeActive) {
        setDistanceToWalls(clyde);
      }
      if (inkyActive) {
        setDistanceToWalls(inky);
      }
      if (pinkyActive) {
        setDistanceToWalls(pinky);
      }
      
      if (blinkyActive) {
        blinkyVision[blinkyVision.length -1] = (blinky.frightened)? 0:1;
      }
      if (clydeActive) {
        clydeVision[clydeVision.length -1] = (clyde.frightened)? 0:1;
      }
      if (inkyActive) {
        inkyVision[inkyVision.length -1] = (inky.frightened)? 0:1;
      }
      if (pinkyActive) {
        pinkyVision[pinkyVision.length -1] = (pinky.frightened)? 0:1;
      }
    }
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  setVisionPath() method calculates the shortest path from the ghost to Pac-Man and sets it as best path.
  */
  
  Path setVisionPath(Ghost ghost) {
    if (visionPathNodes.size() == 0) {
      return null;
    }
    PVector tilePos = pixelToTile(ghost.pos);
    PathNode tilePosNode = new PathNode(tilePos);
    PathNode start  = visionPathNodes.get(0);
    PathNode end = visionPathNodes.get(visionPathNodes.size() - 1);
    
    Path temp = visionAStar(start, end, ghost.vel, tilePosNode);
    
    if (temp != null) { // if no path is found, do not assign to bestVisionPath
      bestVisionPath = temp.createCopy();
    } else {
      bestVisionPath = null;
    }
    
    return bestVisionPath;
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  setVisionPathNodes() sets all the nodes in the vision path and connects them with adjacent nodes. It also sets the target node (Pac-Man's position).
  *  Adapted from PacNEAT.
  */
  
  void setVisionPathNodes(PVector dir, Ghost ghost) {
    PVector tilePos = pixelToTile(ghost.pos);
    visionPathNodes.clear();
    if (!originalTiles[int(tilePos.y + dir.y)][int(tilePos.x + dir.x)].wall) {
      visionPathNodes.add(new PathNode(tilePos.x + dir.x, tilePos.y + dir.y)); // add the current position as a node
    } else {
      return;
    }
    
    for (int i = 1; i < 27; i++) { // check every position
      for (int j = 1; j < 30; j++) {
        // if there is a space up or below and a space left or right then this space is a node
        if (!originalTiles[j][i].wall) {
          if (!originalTiles[j-1][i].wall || !originalTiles[j+1][i].wall) { // check up for space
            if (!originalTiles[j][i-1].wall || !originalTiles[j][i+1].wall) { // check left and right for space
              visionPathNodes.add(new PathNode(i, j)); // add the nodes
            }
          }
        }
      }
    }
    
    visionPathNodes.add(new PathNode(pixelToTile(pac.pos))); // target Pac-Man

    for (int i = 0; i < visionPathNodes.size(); i++) { // connect all the nodes together
      visionPathNodes.get(i).addEdges(visionPathNodes);
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  vision1() method sets the neural network inputs for the ghosts' vision (full 4-directional vision) in each direction.
  *  Code unique to GhostNEAT.
  */
  
  void vision1(Ghost ghost) {   
    if(isCriticalPosition(ghost.pos)) {
      // now that the nodes are done lets look to the left
      PVector[] directions = new  PVector[4];
      visionPath.clear();
      for (int i = 0; i < 4; i++) {
        directions[i] = new PVector(ghost.vel.x, ghost.vel.y);
        directions[i].rotate(PI/2 * i); // at start, he faces east, so position [2] is west
        directions[i].x = round(directions[i].x);
        directions[i].y = round(directions[i].y);
        
        setVisionPathNodes(directions[i], ghost);
        Path temp = setVisionPath(ghost);
        
        visionPath.add(temp);
      }
      
      if (pixelToTile(ghost.pos).x == pixelToTile(blinky.pos).x && pixelToTile(ghost.pos).y == pixelToTile(blinky.pos).y) {
        blinkyVisionPath = (ArrayList)visionPath.clone();;
      } else if (pixelToTile(ghost.pos).x == pixelToTile(clyde.pos).x && pixelToTile(ghost.pos).y == pixelToTile(clyde.pos).y) {
        clydeVisionPath = (ArrayList)visionPath.clone();;
      } else if (pixelToTile(ghost.pos).x == pixelToTile(inky.pos).x && pixelToTile(ghost.pos).y == pixelToTile(inky.pos).y) {
        inkyVisionPath = (ArrayList)visionPath.clone();;
      } else if (pixelToTile(ghost.pos).x == pixelToTile(pinky.pos).x && pixelToTile(ghost.pos).y == pixelToTile(pinky.pos).y) {
        pinkyVisionPath = (ArrayList)visionPath.clone();;
      }
      
      int visionIndex = -1;
      PVector tilePos = pixelToTile(ghost.pos);
      
      float[] visionValues = new float[4];
      visionValues[0] = 1.0;
      visionValues[1] = 0.9;
      visionValues[2] = 0.8;
      visionValues[3] = 0.7;
  
      for (int i = 0; i < 4; i++) { // for each direction (each of the first 4 positions in vision)
        visionIndex++;
        
        if (originalTiles[int(tilePos.y + directions[i].y)][int(tilePos.x + directions[i].x)].wall == true) {
          vision[visionIndex] = -1;
          continue;
        }
        
        // sort visionPath using the sortVisionMap function
        Map<Integer, Float> sortedVisionPath = sortVisionMap(visionPath);
        // keySet of the sorted map
        Set<Integer> keys = sortedVisionPath.keySet();
        
        // convert keySet to an arraylist to be able to get indexes from it
        List<Integer> listKeys = new ArrayList<Integer>(keys);
                
        for (int k : keys) {
          if (k == i) { // key that matches current direction
            vision[visionIndex] = visionValues[listKeys.indexOf(k)]; // set the vision for this node to be the index of this key in visionValues (e.g. if 2nd shortest path, it's 0.9)
          }
        }
      }
    }
    
    if (ghost == blinky) {
      blinkyVision = vision;
    }
    if (ghost == clyde) {
      clydeVision = vision;
    }
    if (ghost == inky) {
      inkyVision = vision;
    }
    if (ghost == pinky) {
      pinkyVision = vision;
    }
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  vision2() method sets the neural network inputs for the ghosts' vision (minimal vision) in each direction.
  *  Code unique to GhostNEAT.
  */
  
  void vision2(Ghost ghost) {    
    boolean eastVision = false;
    boolean westVision = false;
    boolean northVision = false;
    boolean southVision = false;
    
    if(isCriticalPosition(ghost.pos)) {      
      PVector[] directions = new  PVector[4];
      
      for (int i = 0; i < 4; i++) {
        directions[i] = new PVector(ghost.vel.x, ghost.vel.y);
        directions[i].rotate(PI/2 * i); // at start, he faces east, so position [2] is west
        directions[i].x = round(directions[i].x);
        directions[i].y = round(directions[i].y);
      }
      
      int visionIndex = -1;
      PVector tilePos = pixelToTile(ghost.pos);
  
      for (int i = 0; i < 4; i++) { // for each direction (each of the first 4 positions in vision)
        visionIndex++;
        
        if (pixelToTile(pac.pos).x > tilePos.x) {
          eastVision = true; 
        } else {
          eastVision = false;
        }
        if (pixelToTile(pac.pos).x < tilePos.x) {
          westVision = true;
        } else {
          westVision = false;
        }
        if (pixelToTile(pac.pos).y < tilePos.y) {
          northVision = true;
        } else {
          northVision = false;
        }
        if (pixelToTile(pac.pos).y > tilePos.y) {
          southVision = true;
        } else {
          southVision = false;
        }
        
        if (tilePos.y + directions[i].y < tilePos.y) {
          if (northVision) {
            vision[visionIndex] = 1.0;
          } else {
            vision[visionIndex] = 0.5;
          }
        } else if (tilePos.y + directions[i].y > tilePos.y) {
          if (southVision) {
            vision[visionIndex] = 1.0;
          } else {
            vision[visionIndex] = 0.5;
          }
        }
        
        if (tilePos.x + directions[i].x > tilePos.x) {
          if (eastVision) {
            vision[visionIndex] = 1.0;
          } else {
            vision[visionIndex] = 0.5;
          }
        } else if (tilePos.x + directions[i].x < tilePos.x) {
          if (westVision) {
            vision[visionIndex] = 1.0;
          } else {
            vision[visionIndex] = 0.5;
          }
        }
        
        if (originalTiles[int(tilePos.y + directions[i].y)][int(tilePos.x + directions[i].x)].wall == true) {
          vision[visionIndex] = -1;
          continue;
        }
      }
    }
    
    if (ghost == blinky) {
      blinkyVision = vision;
    }
    if (ghost == clyde) {
      clydeVision = vision;
    }
    if (ghost == inky) {
      inkyVision = vision;
    }
    if (ghost == pinky) {
      pinkyVision = vision;
    }
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  sortvisionMap() method sorts a map of vision paths by their distance in order to set priority of the ghosts' options of direction.
  *  Code unique to GhostNEAT.
  */
  
  Map<Integer, Float> sortVisionMap(ArrayList<Path> visionPath) {
    Map<Integer, Float> sortVisionPath = new HashMap<Integer, Float>();
    Map<Integer, Float> sortedVisionPath = new LinkedHashMap<Integer, Float>();
    
    if (visionPath.get(0) == null) {
      sortVisionPath.put(0, 1000.0);
    } else {
      sortVisionPath.put(0, visionPath.get(0).distance);
    }
    if (visionPath.get(1) == null) {
      sortVisionPath.put(1, 1000.0);
    } else {
      sortVisionPath.put(1, visionPath.get(1).distance);
    }
    if (visionPath.get(2) == null) {
      sortVisionPath.put(0, 1000.0);
    } else {
      sortVisionPath.put(2, visionPath.get(2).distance);
    }
    if (visionPath.get(3) == null) {
      sortVisionPath.put(3, 1000.0);
    } else {
      sortVisionPath.put(3, visionPath.get(3).distance);
    }
    
    ArrayList<Float> sortingList = new ArrayList<Float>(sortVisionPath.values());
    
    Collections.sort(sortingList);
                            
    for (float val : sortingList) {
      for (Integer k : getKey(sortVisionPath, val))  {
        sortedVisionPath.put(k, val);
      }
    }
    
    return sortedVisionPath;
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------------------

  /**
  *  getKey() method returns the keys of all matching values in the given Map.
  *  Code unique to GhostNEAT, adapted from https://stackoverflow.com/a/2904266/3856722
  */
  
  Set<Integer> getKey(Map<Integer, Float> map, Float value) {
    Set<Integer> keys = new HashSet();
    for (Map.Entry<Integer, Float> entry : map.entrySet()) {
        if (entry.getValue().equals(value)) {
            keys.add(entry.getKey());
        }
    }
    return keys;
  }

  //------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  isIntersection() method returns whether or not the node is an intersection, i.e has more than 2 directions going out of it.
  */
  
  boolean isIntersection(PathNode n) {
    boolean left = false;
    boolean right = false;
    boolean up = false;
    boolean down= false;
    int countDirections = 0;
    for (int i = 0; i< n.edges.size(); i ++) {
      if ( n.x < n.edges.get(i).x && !left) {
        countDirections++;
        left = true;
      } else if (n.x > n.edges.get(i).x && !right) {
        countDirections++;
        right = true;
      } else if (n.y <n.edges.get(i).y && !up) {
        countDirections++;
        up = true;
      } else if (n.y > n.edges.get(i).y && !down) {
        countDirections++;
        down = true;
      }

      if (countDirections > 2) {
        return true;
      }
    }

    return false;
  }

  //----------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  * setDistanceToWalls() method sets some inputs for the NN for whether or not there is a wall directly adjacent in each direction.
  */
  
  void setDistanceToWalls(Ghost ghost) {
    
    PVector matrixPosition = pixelToTile(ghost.pos);
    PVector[] directions = new  PVector[4];
    
    for (int i = 0; i< 4; i++) { // add 4 directions to the array
      directions[i] = new PVector(ghost.vel.x, ghost.vel.y);
      directions[i].rotate(PI/2 *i);
      directions[i].x = round(directions[i].x);
      directions[i].y = round(directions[i].y);
    }

    int visionIndex = 4;
    for (PVector dir : directions) { // for each direction
      PVector lookingPosition = new PVector(matrixPosition.x + dir.x, matrixPosition.y+ dir.y); // look in that direction
      if (originalTiles[(int)lookingPosition.y][(int)lookingPosition.x].wall) { // if there is a wall in that direction
        vision[visionIndex] = 1;
      } else {
        vision[visionIndex] = 0;
      }

      visionIndex +=1;
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  think() method gets the output of the brains then converts them to movement actions.
  *  Code adapted from PacNEAT to account for multiple brains.
  */
  
  void think() {
    float blinkyMax = 0;
    float clydeMax = 0;
    float inkyMax = 0;
    float pinkyMax = 0;
    
    int blinkyMaxIndex = 0;
    int clydeMaxIndex = 0;
    int inkyMaxIndex = 0;
    int pinkyMaxIndex = 0;
     
    PVector blinkyVel = new PVector(blinky.vel.x, blinky.vel.y);
    PVector clydeVel = new PVector(clyde.vel.x, clyde.vel.y);
    PVector inkyVel = new PVector(inky.vel.x, inky.vel.y);
    PVector pinkyVel = new PVector(pinky.vel.x, pinky.vel.y);
    
    // get the outputs of the neural networks
    if (separateBrains) {
      if (blinkyActive) {
        blinkyDecision = blinkyBrain.feedForward(blinkyVision);
      }
      if (clydeActive) {
        clydeDecision = clydeBrain.feedForward(clydeVision);
      }
      if (inkyActive) {
        inkyDecision = inkyBrain.feedForward(inkyVision);
      }
      if (pinkyActive) {
        pinkyDecision = pinkyBrain.feedForward(pinkyVision);
      }
    } else {
      if (blinkyActive) {
        blinkyDecision = brain.feedForward(blinkyVision);
      }
      if (clydeActive) {
        clydeDecision = brain.feedForward(clydeVision);
      }
      if (inkyActive) {
        inkyDecision = brain.feedForward(inkyVision);
      }
      if (pinkyActive) {
        pinkyDecision = brain.feedForward(pinkyVision);
      }
    }
    
    if (blinkyActive) {
      for (int i = 0; i < blinkyDecision.length; i++) {
        if (blinkyDecision[i] > blinkyMax) {
          blinkyMax = blinkyDecision[i];
          blinkyMaxIndex = i;
        }
      }
      if (blinkyMax >= 0.8) { // if the max output was less than 0.8 then do nothing
        blinkyVel.rotate((PI/2) * blinkyMaxIndex);
        blinkyVel.x = round(blinkyVel.x);
        blinkyVel.y = round(blinkyVel.y);
        blinky.turnTo = new PVector(blinkyVel.x, blinkyVel.y);
      }
    }
    if (clydeActive) {
      for (int i = 0; i < clydeDecision.length; i++) {
        if (clydeDecision[i] > clydeMax) {
          clydeMax = clydeDecision[i];
          clydeMaxIndex = i;
        }
      }
      if (clydeMax >= 0.8) { // if the max output was less than 0.8 then do nothing
        clydeVel.rotate((PI/2) * clydeMaxIndex);
        clydeVel.x = round(clydeVel.x);
        clydeVel.y = round(clydeVel.y);
        clyde.turnTo = new PVector(clydeVel.x, clydeVel.y);
      }
    }
    if (inkyActive) {
      for (int i = 0; i < inkyDecision.length; i++) {
        if (inkyDecision[i] > inkyMax) {
          inkyMax = inkyDecision[i];
          inkyMaxIndex = i;
        }
      }
      if (inkyMax >= 0.8) { // if the max output was less than 0.8 then do nothing
        inkyVel.rotate((PI/2) * inkyMaxIndex);
        inkyVel.x = round(inkyVel.x);
        inkyVel.y = round(inkyVel.y);
        inky.turnTo = new PVector(inkyVel.x, inkyVel.y);
      }
    }
    if (pinkyActive) {
      for (int i = 0; i < pinkyDecision.length; i++) {
        if (pinkyDecision[i] > pinkyMax) {
          pinkyMax = pinkyDecision[i];
          pinkyMaxIndex = i;
        }
      }
      if (pinkyMax >= 0.8) { // if the max output was less than 0.8 then do nothing
        pinkyVel.rotate((PI/2) * pinkyMaxIndex);
        pinkyVel.x = round(pinkyVel.x);
        pinkyVel.y = round(pinkyVel.y);
        pinky.turnTo = new PVector(pinkyVel.x, pinkyVel.y);
      }
    }
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  createCopy() method returns a copy of this player with the same brain.
  *  This method was renamed to avoid confusion with clone and deep clone concepts in Java.
  *  Code adapted from PacNEAT to account for multiple brains.
  */
  
  Player createCopy() {
    Player copyPlayer = new Player();
    if (separateBrains) {
      if (blinkyActive) {
        copyPlayer.blinkyBrain = blinkyBrain.createCopy();
        copyPlayer.blinkyBrain.generateNetwork();
      }
      if (clydeActive) {
        copyPlayer.clydeBrain = clydeBrain.createCopy();
        copyPlayer.clydeBrain.generateNetwork();
      }
      if (inkyActive) {
        copyPlayer.inkyBrain = inkyBrain.createCopy();
        copyPlayer.inkyBrain.generateNetwork();
      }
      if (pinkyActive) {
        copyPlayer.pinkyBrain = pinkyBrain.createCopy();
        copyPlayer.pinkyBrain.generateNetwork();
      }
    } else {
      copyPlayer.brain = brain.createCopy();
      copyPlayer.brain.generateNetwork();
    }
    
    copyPlayer.fitness = fitness;    
    copyPlayer.gen = gen;
    copyPlayer.bestScore = score;
    copyPlayer.id = id;
    return copyPlayer;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  createPlayerForReplay() method creates a copy of this player to replay it as (best or gen best or species champ, etc.)
  *  This method was renamed to avoid confusion with clone and deep clone concepts in Java.
  *  Code adapted from PacNEAT to account for multiple brains. Pac-Man turns list copying adapted from PacNEAT ghosts' frightenedTurns list copying.
  */
  
  Player createPlayerForReplay(boolean isBest) {
    Player playerForReplay = new Player();
    if (separateBrains) {
      if (blinkyActive) {
        playerForReplay.blinkyBrain = blinkyBrain.createCopy();
        playerForReplay.blinkyBrain.generateNetwork();
      }
      if (clydeActive) {
        playerForReplay.clydeBrain = clydeBrain.createCopy();
        playerForReplay.clydeBrain.generateNetwork();
      }
      if (inkyActive) {
        playerForReplay.inkyBrain = inkyBrain.createCopy();
        playerForReplay.inkyBrain.generateNetwork();
      }
      if (pinkyActive) {
        playerForReplay.pinkyBrain = pinkyBrain.createCopy();
        playerForReplay.pinkyBrain.generateNetwork();
      }
    } else {
      playerForReplay.brain = brain.createCopy();
      playerForReplay.brain.generateNetwork();
    }
    
    playerForReplay.fitness = fitness;
    playerForReplay.gen = gen;
    playerForReplay.bestScore = score;
    playerForReplay.stage = stage;
    playerForReplay.id = id;
    
    if (isBest) {     
      playerForReplay.pac.replay = true;
      
      ArrayList<Integer> turnsCopy = new ArrayList<Integer>(pac.turns);
      playerForReplay.pac.turns = turnsCopy;
      
      playerForReplay.isBest = true;
    } else {
      playerForReplay.isBest = false;
    }
    
    return playerForReplay;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  calculateFitness() method calculates the fitness of this Player by squaring its score.
  */
  
  void calculateFitness() {
    // timeScore code unique to GhostNEAT
    score  = score - timeScore;
    if (score <= 0) {
      score = 0;
    }
    timeScore = 0;
    bestScore = score;
    fitness = score * score;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  crossover() method performs crossover of the relevant brain(s) of this Player.
  *  Code adapted from PacNEAT to account for multiple agents.
  */
  
  Player crossover(Player parent2) {
    Player child = new Player();
    if (separateBrains) {
      if (blinkyActive) {
        child.blinkyBrain = blinkyBrain.crossover(parent2.blinkyBrain);
        child.blinkyBrain.generateNetwork();
      }
      if (clydeActive) {
        child.clydeBrain = clydeBrain.crossover(parent2.clydeBrain);
        child.clydeBrain.generateNetwork();
      }
      if (inkyActive) {
        child.inkyBrain = inkyBrain.crossover(parent2.inkyBrain);
        child.inkyBrain.generateNetwork();
      }
      if (pinkyActive) {
        child.pinkyBrain = pinkyBrain.crossover(parent2.pinkyBrain);
        child.pinkyBrain.generateNetwork();
      }
    } else {
      child.brain = brain.crossover(parent2.brain);
      child.brain.generateNetwork();
    }
    
    return child;
  }
}
