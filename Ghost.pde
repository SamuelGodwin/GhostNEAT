/**
 *
 *  Ghost class contains all ghost status and movement methods.
 *  Contains methods such as show() to display the ghost on screen; move() to update the ghost's position; checkPosition() to determine if the ghost can move in the desired direction.
 *  This class was repurposed for GhostNEAT from the Pacman class and individual ghost classes of PacNEAT.
 *
 */

class Ghost {
  Player chase;
  
  // when blinky reaches a node its velocity changes to the value stored in turnto
  PVector turnTo = new PVector(1, 0);
  PVector pos;
  PVector vel = new PVector(1, 0);

  boolean frightened = false; // true if the ghost is in frightened mode
  boolean replay = false;
  boolean returnHome = false;
  boolean deadForABit = false;
  
  int lives = 0;
  int ttl = 300; // time to live without eating another dot
  int stopTimer = 0; // how long the player has been stopped for
  int flashCount = 0;
  int deadCount = 0;
  int ghostID;
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Ghost() constructor method assigns the ghost's starting position.
  */
  
  // constructor
  Ghost(Player parentChase,int ghost) {
    if (ghost == 0) {
      pos = tileToPixel(new PVector(13, 11));
    } else if (ghost == 1) {
      pos = tileToPixel(new PVector(1, 29));
    } else if (ghost == 2) {
      pos = tileToPixel(new PVector(23, 26));
    } else if (ghost == 3) {
      pos = tileToPixel(new PVector(8, 1));
    }
    chase = parentChase;
    
    ghostID = ghost;
  }
  
  //--------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  update() method increments counts relating to ghost's frightened mode.
  */
  
  void update() {
    // increments counts
    if (deadForABit) {
      deadCount ++;
      if (deadCount > 400) {
        deadForABit = false;
      }
    } else {
      if (frightened) {
        flashCount ++;
        if (flashCount > 1000) { // after 10 seconds the ghosts are no longer frightened
          frightened = false;
          flashCount = 0;
        }
      }
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  show() method displays the ghost on screen.
  */
  
  void show(int ghost) {
    PImage sprite = blinkySprite;
    if (!frightened) {
      if (returnHome || deadForABit) {
        sprite = deadSprite;
      } else {
        if (ghost == 0) { // blinky
          sprite = blinkySprite;
        } else if (ghost == 1) { // clyde
          sprite = clydeSprite;
        } else if (ghost == 2) { // inky
          sprite = inkySprite;
        } else if (ghost == 3) { // pinky
          sprite = pinkySprite;
        }
      }
    } else {
      if (floor(flashCount / 30) %2 == 0) { // make it flash white and blue every 30 frames
        sprite = frightenedSprite2;
      } else { // flash blue
        sprite = frightenedSprite;
      }
    }
    
    pushMatrix();
    translate(pos.x, pos.y);

    image(sprite, -15, -15, 30, 30);
    
    popMatrix();
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  move() method handles ghost movement.
  */
  
  void move() {
    if (!humanPlaying && !chase.isBest) {
      if ((blinkyActive && dist(pixelToTile(chase.blinky.pos).x, pixelToTile(chase.pac.pos).x, pixelToTile(chase.blinky.pos).y, pixelToTile(chase.pac.pos).y) > 2) || 
      (clydeActive && dist(pixelToTile(chase.clyde.pos).x, pixelToTile(chase.pac.pos).x, pixelToTile(chase.clyde.pos).y, pixelToTile(chase.pac.pos).y) > 2) ||
      (inkyActive && dist(pixelToTile(chase.inky.pos).x, pixelToTile(chase.pac.pos).x, pixelToTile(chase.inky.pos).y, pixelToTile(chase.pac.pos).y) > 2) ||
      (pinkyActive && dist(pixelToTile(chase.pinky.pos).x, pixelToTile(chase.pac.pos).x, pixelToTile(chase.pinky.pos).y, pixelToTile(chase.pac.pos).y) > 2)) {
        ttl --;
      }
      if (ttl <= -1500 ) {
        kill();
      }
    }
    if (!deadForABit) { // don't move if dead
      if (checkPosition()) {
        if (vel.mag() != 0) {
          stopTimer = 0;
          pos.add(vel);
          pos.add(vel);
        }
      } else {
        if (!humanPlaying && !chase.isBest) {
          if (g4) {
            stopTimer ++;
            if (stopTimer > 300) {
              kill();
            }
          }
        }
      }
    }
    
    update();
  }
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  hitPac() method returns whether the ghost has hit Pac-Man.
  */
  
  boolean hitPac(PVector pacPos) {
    if (dist(pacPos.x, pacPos.y, pos.x, pos.y) < 25) {
      return true;
    }
    return false;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  kill() method is called when a ghost hits Pac-Man. Ends this Player's run.
  */
  
  void kill() {
    lives -= 1;
    
    if (lives < 0) { // game over if no lives left
      chase.pac.gameOver = true;
    } else {
      if (ghostID == 0) {
        pos = tileToPixel(new PVector(13, 11));
      } else if (ghostID == 1) {
        pos = tileToPixel(new PVector(1, 29));
      } else if (ghostID == 2) {
        pos = tileToPixel(new PVector(23, 26));
      } else if (ghostID == 3) {
        pos = tileToPixel(new PVector(8, 1));
      }
      chase.pac.pos = tileToPixel(new PVector(13, 23));
  
      vel = new PVector(-1, 0);
      turnTo = new PVector(-1, 0);
    }    
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  checkPosition() method returns whether Pac-Man can move i.e. there is no wall in the direction it is facing.
  */
  
  boolean checkPosition() {
    if(pacActive) {
      if (hitPac(chase.pac.pos)) {
        if (frightened) { // eaten by Pac-Man
          returnHome = true;
          pos = tileToPixel(new PVector(13, 11));
          frightened = false;
        } else if (!returnHome) {
          chase.score += 75;
          kill();
        }
      } else if (runBest && hitPac(pop.bestPlayer.pac.pos)) {
        runBest = false;
      }
    }
    
    PVector matrixPosition = pixelToTile(pos); // convert position to an array position
    
    // check if reached home yet
    if (returnHome) {
      if (ghostID == 0) {
        if (dist(matrixPosition.x, matrixPosition.y, 13, 11) < 1) {
          // set the ghost as dead for a bit
          returnHome = false;
          deadForABit = true;
          deadCount = 0;
        }
      } else if (ghostID == 1) {
        if (dist(matrixPosition.x, matrixPosition.y, 13, 11) < 1) {
          // set the ghost as dead for a bit
          returnHome = false;
          deadForABit = true;
          deadCount = 0;
        }
      } else if (ghostID == 2) {
        if (dist(matrixPosition.x, matrixPosition.y, 13, 11) < 1) {
          // set the ghost as dead for a bit
          returnHome = false;
          deadForABit = true;
          deadCount = 0;
        }
      } else if (ghostID == 3) {
        if (dist(matrixPosition.x, matrixPosition.y, 13, 11) < 1) {
          // set the ghost as dead for a bit
          returnHome = false;
          deadForABit = true;
          deadCount = 0;
        }
      }
    }
    
    if (isCriticalPosition(pos)) { // if on a critical position
      PVector positionToCheck = new PVector(matrixPosition.x + turnTo.x, matrixPosition.y + turnTo.y); // the position in the tiles double array that the player is turning towards

      if (originalTiles[floor(positionToCheck.y)][floor(positionToCheck.x)].wall) { // check if there is a free space in the direction that it is going to turn
        if (originalTiles[floor(matrixPosition.y + vel.y)][floor(matrixPosition.x + vel.x)].wall) { // if not check if the path ahead is free
          vel = new PVector(turnTo.x, turnTo.y);
          return false; // if neither are free then don't move
        } else { // forward is free
          return true;
        }
      } else { // free to turn
        vel = new PVector(turnTo.x, turnTo.y);

        return true;
      }
    } else {     
      return true; // if not on a critical postion then continue forward
    }
  }
}
