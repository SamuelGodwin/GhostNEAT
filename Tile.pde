/**
 *
 *  Tile class for showing food and big dots.
 *  Contains createCopy() method for returning a copy of a given tile.
 *
 */

class Tile {
  // what type of tile it is (wall, dot, bigDot or eaten)
  boolean wall = false;
  boolean dot = false;
  boolean bigDot = false;
  boolean eaten = false;
  boolean isPathNode = false;
  boolean isGhost = false;
  
  PVector pos;
  
  int id;
  
  //-------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Tile() constructor method sets the position of the tile as a vector.
  */
  
  Tile(float x, float y) {
    pos = new PVector(x, y);
  }
  
  //-----------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  show() method draws a dot (if there is one in this tile).
  */
  
  void show() {
    rectMode(CENTER);
    if (dot) {
      if (!eaten) { // draw dot
        fill(255, 255, 0);
        noStroke();
        // size of the food
        rect(pos.x, pos.y, 4, 4); 
      }
    } else if (bigDot) {
      if (!eaten) { // draw big dot
        fill(255, 255, 0);
        noStroke();
        if (bigDotsActive) {
          rect(pos.x, pos.y, 9, 9);
        } else {
          // size of the big food
          rect(pos.x, pos.y, 4, 4);
        }
      }
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  createCopy() method returns a copy of this tile.
  *  This method was renamed to avoid confusion with clone and deep clone concepts in Java.
  */
  
  Tile createCopy() {
    Tile copyOf = new Tile(pos.x, pos.y); // positioning of the tile
    copyOf.wall = wall;
    copyOf.dot = dot;
    copyOf.bigDot  = bigDot;
    copyOf.eaten = eaten;
    return copyOf;
  }
}
