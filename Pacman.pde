/**
 *
 *  Pacman class contains all Pac-Man status and movement methods.
 *  Contains checkDirection() method, which determines the direciton of Pac-Man's next step, based on which movement AI is active; and setPath(), which determines the path to use if an A* movement AI is active.
 *
 */

class Pacman {
  PVector pos;
  PVector vel = new PVector(1, 0);
  PVector turnTo = new PVector(1, 0);
  
  int upToIndex = 0;
  int humanVel;
  int chaseTimer = 0; // how long the chase has been going on (used for bonus score)
  int ttl = 100;

  boolean replay = false;
  boolean gameOver = false;
  boolean isWall = false;
  boolean humanPress = false; // if direction has been chosen by human player

  Tile[][] tiles = new Tile[31][28];
  
  Player chase;
  
  Path bestPath; // the variable stores the path pac will be following (if A* AI)
  
  PathNode start; // the ghosts position as a node
  PathNode end; // the ghosts target position as a node
  PathNode nextFood; // next food to A* a path to

  ArrayList<Integer> turns = new ArrayList<Integer>(); // turns list used for replay (e.g. replaying the best ever player)
  ArrayList<PathNode> pathNodes = new ArrayList<PathNode>(); // the nodes making up the path including pac's position and the target position
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Pacman() constructor method initialises Pac-Man's tiles and starting position.
  */
  
  Pacman(Player parentChase) {
    for (int i = 0; i < 28; i++) { // for each tile
      for (int j = 0; j < 31; j++) {
        tiles[j][i] = originalTiles[j][i].createCopy();
      }
    }
    chase = parentChase;
    pos = tileToPixel(new PVector(13, 23));
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  show() method displays Pac-Man and (if applicable) his A* path on screen.
  */
  
  void show() {
    if (pacActive) {
      pushMatrix();
      translate(pos.x, pos.y);
      if (vel.x == 1) {
      } else if (vel.x == -1) {
        rotate(PI);
      } else if (vel.y == 1) {
        rotate(PI/2);
      } else if (vel.y == -1) {
        rotate(3 * PI / 2);
      }

      image(pacSprite, -15, -15, 30, 30);

      popMatrix();
      
      // show Pac-Man's path on screen (where applicable) - unique to GhostNEAT
      if (showBestPath && bestPath != null) {
        bestPath.show(4);
      }
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  move() method moves Pac-Man in the direction chosen in CheckDirection().
  */
  
  void move() {   
    checkDirection(); // movement AI

    if (vel.mag() != 0 && !isWall) { // if isWall true, don't move
      pos.add(vel);
      pos.add(vel);
    }
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  findNearestFood() method gets the closest food to Pac-Man for use by the A* algorithm.
  *  Code unique to GhostNEAT.
  */
  
  PVector findNearestFood(ArrayList<PVector> food) {
    PVector nearest = pixelToTile(tiles[0][0].pos);

    for (int k = 0; k < food.size(); k++) {
      if (abs((pixelToTile(pos).x - food.get(k).x)) + abs(pixelToTile(pos).y - food.get(k).y) < abs(pixelToTile(pos).x - nearest.x) + abs(pixelToTile(pos).y - nearest.y)) {
        nearest = food.get(k);
      }
    }

    return nearest;
  }
  
  //-----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  setPath() method determines Pac-Man's movement path, if an A* AI is active.
  */
  
  void setPath() {
    if (pacActive) {      
      pathNodes.clear();
      setPathNodes();
      start = pathNodes.get(0);
      end = pathNodes.get(pathNodes.size() - 1);
      
      Path temp = AStar(start, end, vel, chase);
      
      if (temp != null) { // if no path is found, do not assign to bestPath
        bestPath = temp.createCopy();
      } 
      else {
        setPathNodes();
        pathNodes.remove(pathNodes.size()-1);
        pathNodes.add(new PathNode(6, 20));
        temp = AStar(start, end, vel, chase);
        if (temp != null) {
          bestPath = temp.createCopy();
        }
      }
    }
  }
  
  //-----------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  setPathNodes() sets all the nodes in the movement path and connects them with adjacent nodes. It also sets the target node.
  */
  
  void setPathNodes() {
    pathNodes.clear(); // clyde, inky and pinky all do not have this line
    pathNodes.add(new PathNode(pixelToTile(pos))); // add the current position as a node
    for (int i = 1; i< 27; i++) { // check every position
      for (int j = 1; j< 30; j++) {
        // if there is a space up or below and a space left or right then this space is a node
        if (!originalTiles[j][i].wall) {
          if (!originalTiles[j-1][i].wall || !originalTiles[j+1][i].wall) { // check up for space
            if (!originalTiles[j][i-1].wall || !originalTiles[j][i+1].wall) { // check left and right for space

              pathNodes.add(new PathNode(i, j)); // add the nodes
            }
          }
        }
      }
    }
    
    // unique to GhostNEAT
    ArrayList<Ghost> ghosts = new ArrayList<Ghost>();
        
    if (blinkyActive) {
      ghosts.add(chase.blinky);
    }
    if (clydeActive) {
      ghosts.add(chase.clyde);
    }
    if (inkyActive) {
      ghosts.add(chase.inky);
    }
    if (pinkyActive) {
      ghosts.add(chase.pinky);
    }
    
    // unique to GhostNEAT
    ArrayList<PVector> food = new ArrayList<PVector>(); // list of food for A* AI
    
    food.clear();
    for (int i = 0; i < 31; i++ ) {
      for (int j = 0; j < 28; j++) {
        if (tiles[i][j].dot && !tiles[i][j].eaten) {
          food.add(pixelToTile(tiles[i][j].pos));
        }
      }
    }

    if (food.isEmpty()) {
      chase.dead = true;
    }
    
    // unique to GhostNEAT
    if (ghostAvoid && nextFood != null) {
      for (Ghost g : ghosts) {
        if (abs(dist(pixelToTile(pos).x, pixelToTile(pos).y, pixelToTile(g.pos).x, pixelToTile(g.pos).y)) <= 5) {
          int index = food.indexOf(findNearestFood(food));
          if (index >= 0) {
            food.remove(index);
          }
          pathNodes.add(new PathNode(new PVector(6, 20)));
          return;
        }
      }
    }
    
    // unique to GhostNEAT
    if (closestFood) {
      nextFood = new PathNode(findNearestFood(food)); // closest food
    } else if (linearFood){
      nextFood = new PathNode(food.get(0)); // linear food
    } else if (randomFood) {
      Random rand = new Random(food.size());
      
      if (nextFood == null || !food.contains(new PVector(nextFood.x, nextFood.y))) {
        int randFood = rand.nextInt(food.size());
        
        nextFood = new PathNode(food.get(randFood)); // random food
      }
    }
    
    pathNodes.add(nextFood);

    for (int i = 0; i< pathNodes.size(); i++) { // connect all the nodes together
      pathNodes.get(i).addEdges(pathNodes);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  checkDirection() method decides the direction of Pac-Man's next move, depending on which AI is active.
  *  All Pac-Man AI and humanPlaying elements of this method are unique to GhostNEAT, including Pac-Man's turns list, and chaseTimer code.
  */
  
  void checkDirection() {
    PVector matrixPosition = pixelToTile(pos); // current tile position (pos is pixel position)
    PVector nextVel;
    
    ArrayList<Integer> directionList = new ArrayList<Integer>();
    
    directionList.clear();
    directionList.add(0);
    directionList.add(1);
    directionList.add(2);
    directionList.add(3);
    
    ArrayList<Ghost> ghosts = new ArrayList<Ghost>();
        
    if (blinkyActive) {
      ghosts.add(chase.blinky);
    }
    if (clydeActive) {
      ghosts.add(chase.clyde);
    }
    if (inkyActive) {
      ghosts.add(chase.inky);
    }
    if (pinkyActive) {
      ghosts.add(chase.pinky);
    }
    
    int turn = floor(random(4)); // random value from 0-3 for deciding a random move
    
    isWall = false;
    nextVel = vel; // begin facing the direction of the last move
    
    // check if the position has been eaten or not, note the blank spaces are initialised as already eaten
    if (!tiles[floor(matrixPosition.y)][floor(matrixPosition.x)].eaten) {
      tiles[floor(matrixPosition.y)][floor(matrixPosition.x)].eaten = true; // if uneaten, eat it!
      
      if (tiles[floor(matrixPosition.y)][floor(matrixPosition.x)].bigDot && bigDotsActive) { // if big dot eaten
        // set all ghosts to frightened
        if (!chase.blinky.returnHome && !chase.blinky.deadForABit) {
          chase.blinky.frightened = true;
          chase.blinky.flashCount = 0;
        }
        if (!chase.clyde.returnHome && !chase.clyde.deadForABit) {
          chase.clyde.frightened = true;
          chase.clyde.flashCount = 0;
        }
        if (!chase.pinky.returnHome && !chase.pinky.deadForABit) {
          chase.pinky.frightened = true;
          chase.pinky.flashCount = 0;
        }
        if (!chase.inky.returnHome && !chase.inky.deadForABit) {
          chase.inky.frightened = true;
          chase.inky.flashCount = 0;
        }
      }
    }
    
    // if not on a pathnode/at a wall (depending on which AI is active)
    if ((isNode && !originalTiles[floor(matrixPosition.y)][floor(matrixPosition.x)].isPathNode) || (!isNode && !originalTiles[floor(matrixPosition.y + nextVel.y)][floor(matrixPosition.x + nextVel.x)].wall)) {
      nextVel = vel; // continue in current direction
    } else { // if on a pathnode/at a wall
      if (!isCriticalPosition(pos)) { // if not at the centre of the tile
        nextVel = vel; // continue
      } else {
        if (closestFood || linearFood || randomFood) {
          setPath();
          
          if (bestPath != null) {          
            for (int i = 0; i < bestPath.path.size()-1; i++) { // if currently on a node turn towards the direction of the next node in the path 
              if (matrixPosition.x ==  bestPath.path.get(i).x && matrixPosition.y == bestPath.path.get(i).y) {
                PVector bestVel = new PVector(bestPath.path.get(i + 1).x - matrixPosition.x, bestPath.path.get(i + 1).y - matrixPosition.y);
                bestVel.normalize();
                
                // get turn value to add to turns list
                if (bestVel.x == 1 && bestVel.y == 0) {
                  turn = 0; // right
                } else if (bestVel.x == 0 && bestVel.y == 1) {
                  turn = 1; // down
                } else if (bestVel.x == -1 && bestVel.y == 0) {
                  turn = 2; // left
                } else if (bestVel.x == 0 && bestVel.y == -1) {
                  turn = 3; // up
                }
              }
            }
          }
        }
        
        if (isNode) {
          vel = new PVector(0, 0); // stop at the centre of pathnode
        }
  
        // if isMoving false, pac stands still
        if (!isMoving) {
          turn = -1; // stop
        }
  
        // is human playing as pac
        if (humanPlaying) {
          // always false when human playing
          replay = false;
          // ghost avoidance would be done by the user
          ghostAvoid = false;
  
          // if key has not been pressed
          if (!humanPress) {
            // if chosen direction is a wall, isWall = true
            if (tiles[floor(matrixPosition.y + nextVel.y)][floor(matrixPosition.x + nextVel.x)].wall) {
              isWall = true; // vel not added to pos in move() if isWall true
            }
            return;
          } else {
            turn = humanVel; // turn = value of direction pressed
            humanPress = false; // reset humanPress for next move
          }
        }
        
        if (ghostAvoid) {
          for (Ghost g : ghosts) {
            if (abs(dist(pixelToTile(pos).x, pixelToTile(pos).y, pixelToTile(g.pos).x, pixelToTile(g.pos).y)) <= 5) {
              PVector ghostDirVec = new PVector(pixelToTile(g.pos).x - pixelToTile(pos).x, pixelToTile(g.pos).y - pixelToTile(pos).y);
              ghostDirVec.normalize();
              
              if (ghostDirVec.x < 0) {
                ghostDirVec.x = -1;
              }
              if (ghostDirVec.x > 0) {
                ghostDirVec.x = 1;
              }
              if (ghostDirVec.y < 0) {
                ghostDirVec.y = -1;
              }
              if (ghostDirVec.y > 0) {
                ghostDirVec.y = 1;
              }
              
              int ghostDir = -1;
              
              // get turn value to add to turns list
              if (ghostDirVec.x == 1) {
                ghostDir = 0; // right
              }
              if (ghostDirVec.y == 1) {
                ghostDir = 1; // down
              }
              if (ghostDirVec.x == -1) {
                ghostDir = 2; // left
              }
              if (ghostDirVec.y == -1) {
                ghostDir = 3; // up
              }
              
              if (ghostDir != -1 && directionList.contains(ghostDir)) {
                directionList.remove(directionList.indexOf(ghostDir));
              }
              
              if (!g.frightened) {
                if (!directionList.isEmpty()) {
                  turn = directionList.get(floor(random(directionList.size())));
                }
              }
            }
          }
        }
          
        // if replay true (must be before switch statement)
        if (replay && upToIndex < turns.size()) {
          turn = turns.get(upToIndex);
          upToIndex++;
        }
  
        // direction to turn
        switch (turn) {
        case 0:
          nextVel = new PVector(1, 0); // right
          break;
        case 1:
          nextVel = new PVector(0, 1); // down
          break;
        case 2:
          nextVel = new PVector(-1, 0); // left
          break;
        case 3:
          nextVel = new PVector(0, -1); // up
          break;
        case -1:
          nextVel = new PVector(0, 0); // stop
        }
  
        // if chosen direction is a wall, isWall = true (must be after switch statement)
        if (tiles[floor(matrixPosition.y + nextVel.y)][floor(matrixPosition.x + nextVel.x)].wall) {
          isWall = true; // vel not added to pos in move() if isWall true
          return;
        }
  
        // if not replaying (must be after the wall check)
        if (!replay) {
          if (turn > -1) {
            turns.add(turn); // add chosen direction to turns list
          }
        }
      }
        
      vel = nextVel; // vel = direction chosen
    }
    
    chaseTimer++;
        
    if (chaseTimer >= 90) {
      chase.timeScore += 1;
      chaseTimer = 0;
    }
  }
}
