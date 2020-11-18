/**
 *
 *  GhostNeat driver class. This class handles all visual elements and primary settings of the program.
 *  Contains a keyPressed() method for a variety of interactive features, as well as methods for dealing with A* Search pathfinding.
 *
 */
 
// imports for A* pathfinding, random numbers, various datasets, etc
import java.util.*;

PImage img; // background image 
PImage pacSprite; // Pac-Man image

// ghost images
PImage blinkySprite;
PImage pinkySprite;
PImage inkySprite;
PImage clydeSprite;
PImage frightenedSprite;
PImage frightenedSprite2;
PImage deadSprite;

int nextConnectionNo = 1000;
int speed = 60;
int chasesStillAlive; // number of players remaining
int writeCount = 0; // for keeping temporary text displays on screen longer
int upToSpecies = 0; // cycling through species in runThroughSpecies
int upToGen = 0; // cycling through gens in showBestEachGen
int usingInputsStart = 0; // nodes of NN to use
int usingInputsEnd = 8;
int idCount = 1; // for tile ids
int pacAI = 0; // which Pac-Man AI is active
int visionVersion = 2; // determines vision 1 (all four directions, precise), or vision 2 (reduced vision, approximate)

// true - independent brain framework, false - shared brain framework - unique to GhostNEAT
boolean separateBrains = false;
boolean showBest = true; // true if only show the best of the previous generation
boolean runBest = false; // true if replaying the best ever game
boolean showVision = false; // true if showing the route of ghost's vision to pac - unique to GhostNEAT
boolean showBestPath = false; // true if showing pac's A* path to food - unique to GhostNEAT
boolean runThroughSpecies = false; // show champ of each species (cycle through species)
boolean skippingGens = false; // when a gen has been skipped ('d' key press), skippingGens is true
boolean showBestEachGen = false; // show best of each gen (cycle through gens)
boolean pacActive = true; // active true when players are to be shown, false otherwise
boolean blinkyActive = true;
boolean pinkyActive = false;
boolean inkyActive = false;
boolean clydeActive = false;
boolean showNothing = false; // true for no graphics, faster running
boolean zxcv = false; // for acknowledging z, x, c or v being pressed - unique to GhostNEAT
boolean g4 = false; // 1 ghost or 4 ghosts - unique to GhostNEAT
boolean bigDotsActive = false;
boolean showGhostNames = true; // names of ghosts by their NNs - unique to GhostNEAT
boolean showHelp = false;
boolean humanPlaying = false; // unique to GhostNEAT
boolean randomPacAI = false; // randomise pacAI every gen - unique to GhostNEAT

// Pac-Man AI - unique to GhostNEAT
boolean isMoving = true; // pac moving AI (true), or standing still AI (false)
boolean isNode = true; // random turns until turning point/PathNode (true), or random turns until wall (false)
boolean closestFood = false; // A* to closest food
boolean linearFood = false; // A* to linear food
boolean randomFood = false; // A* to random food
boolean ghostAvoid = true; // ghost avoidance

Population pop;

Player speciesChamp; // best player of a species
Player genPlayerTemp; // best player of a gen

// for storing the brains of evolved ghosts (shown at gen 400 of independent/1G setup) - unique to GhostNEAT
Genome evolvedBlinkyBrain;
Genome evolvedClydeBrain;
Genome evolvedInkyBrain;
Genome evolvedPinkyBrain;

Tile[][] originalTiles = new Tile[31][28]; // note it goes y then x because of how data is inserted

int[][] tilesRepresentation = { // 1 - wall, 0 - dot, 8 - big dot, 6 - empty space. This represents the 'map'
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, 
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1}, 
  {1, 8, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 8, 1}, 
  {1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1}, 
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1}, 
  {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1}, 
  {1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 6, 1, 1, 6, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 6, 1, 1, 6, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 6, 6, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 6, 6, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 1, 1, 1, 1, 1, 0, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 0, 1, 1, 1, 1, 1, 1}, 
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1}, 
  {1, 8, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 8, 1}, 
  {1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1}, 
  {1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1}, 
  {1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1}, 
  {1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, 
  {1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, 
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};

//--------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  The setup() method is run once at the start of the program.
*  It defines initial environment properties, loads images, identifies PathNodes, and initiates objects of the Tile and Population classes.
*/

void setup() {
  frameRate(100);
  fullScreen();
  
  // load images
  img = loadImage("map.jpg");
  blinkySprite = loadImage("blinky20000.png");
  pinkySprite = loadImage("pinky20000.png");
  inkySprite = loadImage("inky20000.png");
  clydeSprite = loadImage("clyde20000.png");
  frightenedSprite = loadImage("frightenedGhost0000.png");
  frightenedSprite2 = loadImage("frightenedGhost20000.png");
  deadSprite = loadImage("deadGhost0000.png");
  img = resizeBasic(img, 2);
  pacSprite = loadImage("pac.png");

  // initiate tiles (use of the Tile class)
  for (int i = 0; i< 28; i++) {
    for (int j = 0; j< 31; j++) {
      PVector tileCoords = tileToPixel(new PVector(i, j));
      originalTiles[j][i] = new Tile(tileCoords.x, tileCoords.y);
      switch(tilesRepresentation[j][i]) {
      // assigning the number values for the numerical 'map'
      case 1: // 1 is a wall
        originalTiles[j][i].wall = true;
        break;
      case 0: // 0 is a dot
        originalTiles[j][i].dot = true;
        originalTiles[j][i].id = idCount; // give an id to all food tiles
        idCount++;
        break;
      case 8: // 8 is a big dot
        originalTiles[j][i].bigDot = true;
        break;
      case 6: // 6 is a blank space
        originalTiles[j][i].eaten = true;
        break;
      }
    }
  }

  // identifying pathnodes
  for (int i = 0; i < 28; i++) {
    for (int j = 0; j < 31; j++) {
      // if there is a space up or below and a space left or right then this space is a node
      if (!originalTiles[j][i].wall) {
        if (!originalTiles[j-1][i].wall || !originalTiles[j+1][i].wall) { // check up for space
          if (!originalTiles[j][i-1].wall || !originalTiles[j][i+1].wall) { // check left and right for space

            originalTiles[j][i].isPathNode = true;
          }
        }
      }
    }
  }

  pop = new Population(200); // using a population of 200 (subject to change as needed)
}

//--------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  resizeBasic() method resizes the map image to fit to the screen size.
*/

PImage resizeBasic(PImage in, int factor) {
  PImage out = createImage(in.width * factor, in.height * factor, RGB);
  
  in.loadPixels();
  out.loadPixels();
  
  for (int y = 0; y < in.height; y++) {
    for (int x= 0; x < in.width; x++) {
      int index = x + y * in.width;
      for (int h = 0; h < factor; h++) {
        for (int w = 0; w < factor; w++) {
          int outdex = x * factor + w + (y * factor + h) * out.width;
          out.pixels[outdex] = in.pixels[index];
        }
      }
    }
  }
  
  out.updatePixels();
  return out;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  draw() method is continuously executed until the program is stopped. It handles the updating of all the necessary Players, and calls naturalSelection() at the end of each gen.
*/

void draw() {
  drawToScreen();
  if (showBestEachGen) { // show the best player of each gen
    if (genPlayerTemp != null) {
      if (!genPlayerTemp.dead) { // if current gen player is not dead then update it
  
        genPlayerTemp.look();
        genPlayerTemp.think();
  
        genPlayerTemp.update();
        genPlayerTemp.show();
      } else { // if dead move on to the next gen best
        upToGen ++;
        if (upToGen >= pop.genPlayers.size()) { // if at the end then return to the start and stop doing it
          upToGen = 0;
          showBestEachGen = false;
        } else { // if not at the end then get the next gen best
          genPlayerTemp = pop.genPlayers.get(upToGen).createPlayerForReplay(false); // create new player copy for replay
          
          // copy pac's turns to the new copy  
          if (genPlayerTemp != null) {
            genPlayerTemp.pac.replay = true;
  
            ArrayList<Integer> turnsCopy = new ArrayList<Integer>(pop.genPlayers.get(upToGen).pac.turns);
            genPlayerTemp.pac.turns = turnsCopy;
          }
        }
      }
    }
  } else
    if (runThroughSpecies ) { // skip through all the species champs
      if (speciesChamp != null) {
        if (!speciesChamp.dead) { // if champ of current species is not dead
          speciesChamp.look();
          speciesChamp.think();
          speciesChamp.update();
          speciesChamp.show();
        } else { // once dead
          upToSpecies++;
          if (upToSpecies >= pop.species.size()) {
            runThroughSpecies = false;
          } else {
            speciesChamp = pop.species.get(upToSpecies).champ.createPlayerForReplay(false);
  
            if (speciesChamp != null) {
              speciesChamp.pac.replay = true;
  
              ArrayList<Integer> turnsCopy = new ArrayList<Integer>(pop.species.get(upToSpecies).champ.pac.turns);
              speciesChamp.pac.turns = turnsCopy;
            }
          }
        }
      }
    } else {
      if (runBest) { // if replaying the best ever run
        if (pop.bestPlayer != null) {
          if (!pop.bestPlayer.dead) { // if best player is not dead
            pop.bestPlayer.look();
            pop.bestPlayer.think();
            pop.bestPlayer.update();
            pop.bestPlayer.show();
          } else { // once dead
            runBest = false; // stop replaying
            pop.bestPlayer = pop.bestPlayer.createPlayerForReplay(true); // reset the best player so it can play again
          }
        }
      } else { // if just evolving normally
        if (!pop.done()) { // if any players are alive then update them
          pop.updateAlive();
        } else { // all dead
          switch(pop.gen) {
            case 60:
              bigDotsActive = true;
              break;
            // code unique to GhostNEAT
            case 100:
              if (separateBrains && !(blinkyActive && inkyActive && clydeActive && pinkyActive)) {
                evolvedBlinkyBrain = pop.bestPlayer.blinkyBrain.createCopy();
                blinkyActive = false;
                clydeActive = true;
              }
              break;
            case 200:
              if (separateBrains && !(blinkyActive && inkyActive && clydeActive && pinkyActive)) {
                evolvedClydeBrain = pop.bestPlayer.clydeBrain.createCopy();
                clydeActive = false;
                inkyActive = true;
              }
              break;
            case 300:
              if (separateBrains && !(blinkyActive && inkyActive && clydeActive && pinkyActive)) {
                evolvedInkyBrain = pop.bestPlayer.inkyBrain.createCopy();
                inkyActive = false;
                pinkyActive = true;
              }
              break;
            case 400:
              if (separateBrains) {
                if (!(blinkyActive && inkyActive && clydeActive && pinkyActive)) {
                  evolvedPinkyBrain = pop.bestPlayer.pinkyBrain.createCopy();
                  blinkyActive = true;
                  clydeActive = true;
                  inkyActive = true;
                  pinkyActive = true;
                  
                  pop = new Population(200);
                }
              } else {
                blinkyActive = true;
                clydeActive = true;
                inkyActive = true;
                pinkyActive = true;
              }
              break;
          }
          pop.naturalSelection();
        }
      }
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  drawToScreen() draws the display screen, including the game grid and separating lines.
*/

void drawToScreen() {
  if (!showNothing) {
    noStroke();
    strokeWeight(10);
    background(0);
    fill(0);
    rectMode(CORNERS);
    rect(0, height/2 + 40, width, height);
    rect(498, 0, 502 + 448*2, height - 496 *2);
    strokeWeight(10);
    stroke(29, 48, 137);
    if (!showHelp) {
      line(0, height/2 + 40, width, height/2 + 40);
    } else {
      line(width/2, height/2 + 40, width, height/2 + 40);
    }
    stroke(32, 56, 178);
    strokeWeight(5); // horizontal line
  
    // width is width of computer's screen and height is height of computer's screen
    if (!showHelp) {
      line(0, height/2 + 40, width, height/2 + 40);
    } else {
      line(width/2, height/2 + 40, width, height/2 + 40);
    }
  
    image(img, 500, height - 496 *2);
    strokeWeight(10);
    stroke(29, 48, 137);
    line(498, 0, 498, height);
    line(502 + 448 *2, 0, 502 + 448 *2, height);
    stroke(32, 56, 178);
    strokeWeight(5); // vertical line
  
    line(498, 0, 498, height);
    line(502 + 448 *2, 0, 502 + 448 *2, height);
  
    drawBrain();
    writeInfo();
  } else {
    fill(200);
    textAlign(LEFT);
    textSize(30);
    noStroke();
    text("*N to enable", width/2 - 106, height/2 + 119);
    
    text("Graphics", width/2 - 77, height/2 + 1);
    text("OFF*", width/2 - 40, height/2 + 42);
  }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  drawBrain() method shows the brain of whichever Player is currently showing.
*/

void drawBrain() {
  if (separateBrains) {
      if (runThroughSpecies) {
        if (blinkyActive && !showHelp) {
          speciesChamp.blinkyBrain.drawGenome(502 + 448 *2 - 1400, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top left //*
        }
        if (inkyActive) {
          speciesChamp.inkyBrain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // inky top right //*
        }
        if (pinkyActive && !showHelp) {
          speciesChamp.pinkyBrain.drawGenome(502 + 448 *2 - 1400, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // pinky bottom left //*
        }
        if (clydeActive) {
          speciesChamp.clydeBrain.drawGenome(502 + 448 *2 + 10, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // clyde bottom right //*
        }
      } else
        if (runBest) {
          if (blinkyActive && !showHelp) {
            pop.bestPlayer.blinkyBrain.drawGenome(502 + 448 *2 - 1400, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top left //*
          }
          if (inkyActive) {
            pop.bestPlayer.inkyBrain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // inky top right //*
          }
          if (pinkyActive && !showHelp) {
            pop.bestPlayer.pinkyBrain.drawGenome(502 + 448 *2 - 1400, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // pinky bottom left //*
          }
          if (clydeActive) {
            pop.bestPlayer.clydeBrain.drawGenome(502 + 448 *2 + 10, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // clyde bottom right //*
          }
        } else
          if (showBestEachGen) {
            if (blinkyActive && !showHelp) {
              genPlayerTemp.blinkyBrain.drawGenome(502 + 448 *2 - 1400, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top left //*
            }
            if (inkyActive) {
              genPlayerTemp.inkyBrain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // inky top right //*
            }
            if (pinkyActive && !showHelp) {
              genPlayerTemp.pinkyBrain.drawGenome(502 + 448 *2 - 1400, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // pinky bottom left //*
            }
            if (clydeActive) {
              genPlayerTemp.clydeBrain.drawGenome(502 + 448 *2 + 10, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // clyde bottom right //*
            }
          } else if (showBest) {
            // for displaying 4 NNs
            if (blinkyActive && !showHelp) {
              pop.popPlayers.get(pop.ghostNo).blinkyBrain.drawGenome(502 + 448 *2 - 1400, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top left //*
            }
            if (inkyActive) {
              pop.popPlayers.get(pop.ghostNo).inkyBrain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // inky top right //*
            }
            if (pinkyActive && !showHelp) {
              pop.popPlayers.get(pop.ghostNo).pinkyBrain.drawGenome(502 + 448 *2 - 1400, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // pinky bottom left //*
            }
            if (clydeActive) {
              pop.popPlayers.get(pop.ghostNo).clydeBrain.drawGenome(502 + 448 *2 + 10, height/2 + 90, width -( 502 + 448 *2), height - (height/2 + 100)); // clyde bottom right //*
            }
          }
  } else {
    if (runThroughSpecies) {
      if (blinkyActive) {
        speciesChamp.brain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top right //*
      }
    } else
        if (runBest) {
          if (blinkyActive) {
            pop.bestPlayer.brain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top right //*
          }
        } else
          if (showBestEachGen) {
            if (blinkyActive) {
              genPlayerTemp.brain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top right //*
            }
          } else if (showBest) {
            if (blinkyActive) {
              pop.popPlayers.get(pop.ghostNo).brain.drawGenome(502 + 448 *2 + 10, 90, width -( 502 + 448 *2), height - (height/2 + 100)); // blinky top right //*
            }
          }
  }
}
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  writeInfo() displays info about the current player and various states of the program
*/

void writeInfo() {
  fill(200);
  textAlign(LEFT);
  textSize(30);

  chasesStillAlive = 0; // number of players still alive 
  for (Player player : pop.popPlayers) {
    if (!player.dead) {
      chasesStillAlive += 1;
    }
  }

  if (separateBrains) {
    if (showGhostNames) {
      // for displaying name titles for 4 distinct NNs drawn
      if (blinkyActive && !showHelp) {
        text("Blinky", 375, height/2 + 20); // blinky top left
      }
      if (inkyActive) {
        text("Inky", 1445, height/2 + 20); // inky top right
      }
      if (pinkyActive && !showHelp) {
        text("Pinky", 375, height/2 + 85); // pinky bottom left
      }
      if (clydeActive) {
        text("Clyde", 1445, height/2 + 85); // bottom right
      }
    }
  } else {
    if (showGhostNames) {
      text("Ghosts", 1445, height/2 + 20); // ghost top right
    }
  }
  
  // help menu, unique to GhostNEAT
  if (showHelp) {
    text("SPACE: Toggle show all players", 10, 110);
    text("-/+: Adjust framerate", 10, 140);
    text("1/2: Full/reduced vision", 10, 170);
    text("0: Pac-Man's path (if available)", 10, 200);
    text("F: Ghost vision (if available)", 10, 230);
    text("B: Replay best run", 10, 260);
    text("G: Show generation best", 10, 290);
    text("S: Show species champions", 10, 320);
    text("V: Apply random NN mutation", 10, 350);
    text("Z: Reset NN", 10, 380);
    text("X: Apply demonstration network", 10, 410);
    text("C: Splice demonstration network", 10, 440);
    text("D: Kill all players (end gen)", 10, 470);
    text("4: Toggle one or four ghosts", 10, 500);
    text("N: No graphics", 10, 530);
    text("P: Human control of Pac-Man", 10, 560);
    text("ARROWS: Human controls", 10, 590);
    text("CTRL/SHIFT: Last/next chase", 10, 620);
    text("3: Shared/separate brains", 10, 650);
    text("I: Pac-Man turns at node/wall", 10, 680);
    text("5: Toggle Pac-Man avoids ghost", 10, 710);
    text("R: Randomise Pac-Man AI", 10, 740);
    text("A: Change Pac-Man AI", 10, 770);
  }
  
  if (!showHelp) {
    text("H - Toggle HELP", 10, 80);
  } else {
    text("HELP:", 10, 80);
  }
  text("Remaining: " + chasesStillAlive, 770, 40);
  
  if (humanPlaying) {
    text("Human Playing", 770, 70);
  }
  
  if (skippingGens) {
    text("Skip", width/2 - 43, height/2 + 20);
    skippingGens = false;
  }
  
  // unique to GhostNEAT
  if (zxcv) {
    text("NN change", width/2 - 90, height/2 + 20);
    writeCount++;
    if (writeCount >= 8) {
      zxcv = false;
      writeCount = 0;
    }
  }
    
  if (!showBestEachGen) {
    text("Gen: " + pop.gen, 1025, 40);
  }
  
  // settings displays, unique to GhostNEAT
  if (separateBrains) {
    if (!pinkyActive) {
      text("Ghosts have separate brains", 10, 1010);
      
      if (ghostAvoid) {
        text("Pac-Man avoids ghosts: ON", 10, 1040);
      } else {
        text("Pac-Man avoids ghosts: OFF", 10, 1040);
      }
      
      if (visionVersion == 1) {
        text("Full vision", 10, 950);
      } else if (visionVersion == 2) {
        text("Reduced Vision", 10, 950);
      }
      
      text("SETTINGS:", 10, 890);
      
      if (g4) {
        text("4 ghosts simultaneously", 10, 980);
      } else {
        text("1 ghost at a time", 10, 980);
      }
      
      if (pacAI == 0) { // random to node/wall
        if (randomPacAI) {
          text("Random Pac AI: Random turns", 10, 1070);
        } else {
          text("Pac-Man AI: Random turns", 10, 1070);
        }
      } else if ( pacAI == 1) { // closest food A*
        if (randomPacAI) {
          text("Random Pac AI: Closest food A*", 10, 1070);
        } else {
          text("Pac-Man AI: Closest food A*", 10, 1070);
        } 
      } else if ( pacAI == 2) { // linear food A*
        if (randomPacAI) {
          text("Random Pac AI: Linear food A*", 10, 1070);
        } else {
          text("Pac-Man AI: Linear food A*", 10, 1070);
        }
      } else if ( pacAI == 3) { // random food A*
        if (randomPacAI) {
          text("Random Pac AI: Random food A*", 10, 1070);
        } else {
          text("Pac-Man AI: Random food A*", 10, 1070);
        } 
      } else if ( pacAI == 4) { // not moving
        if (randomPacAI) {
          text("Random Pac AI: Standing still", 10, 1070);
        } else {
          text("Pac-Man AI: Standing still", 10, 1070);
        }
      }
      if (isNode) {
        text("Pac-Man turning at nodes", 10, 920);
      } else {
        text("Pac-Man turning at walls", 10, 920);
      }
    }
  } else {
    text("Ghosts share 1 brain", 10, 1010);
    if (ghostAvoid) {
      text("Pac-Man avoids ghosts: ON", 10, 1040);
    } else {
      text("Pac-Man avoids ghosts: OFF", 10, 1040);
    }
    
    if (visionVersion == 1) {
      text("Full vision", 10, 950);
    } else if (visionVersion == 2) {
      text("Reduced Vision", 10, 950);
    }
    
    text("SETTINGS:", 10, 890);
    
    if (g4) {
      text("4 ghosts simultaneously", 10, 980);
    } else {
      text("1 ghost at a time", 10, 980);
    }
    
    if (pacAI == 0) { // random to node/wall
      if (randomPacAI) {
        text("Random Pac AI: Random turns", 10, 1070);
      } else {
        text("Pac-Man AI: Random turns", 10, 1070);
      }
    } else if ( pacAI == 1) { // closest food A*
      if (randomPacAI) {
        text("Random Pac AI: Closest food A*", 10, 1070);
      } else {
        text("Pac-Man AI: Closest food A*", 10, 1070);
      } 
    } else if ( pacAI == 2) { // linear food A*
      if (randomPacAI) {
        text("Random Pac AI: Linear food A*", 10, 1070);
      } else {
        text("Pac-Man AI: Linear food A*", 10, 1070);
      }
    } else if ( pacAI == 3) { // random food A*
      if (randomPacAI) {
        text("Random Pac AI: Random food A*", 10, 1070);
      } else {
        text("Pac-Man AI: Random food A*", 10, 1070);
      } 
    } else if ( pacAI == 4) { // not moving
      if (randomPacAI) {
        text("Random Pac AI: Standing still", 10, 1070);
      } else {
        text("Pac-Man AI: Standing still", 10, 1070);
      }
    }
    if (isNode) {
      text("Pac-Man turning at nodes", 10, 920);
    } else {
      text("Pac-Man turning at walls", 10, 920);
    }
  }

  if (showBestEachGen) {
    text("Score: " + genPlayerTemp.score, 540, 40);
    text("Gen: " + (genPlayerTemp.gen + 1) + " (RIGHT to cycle)", 1025, 40);
  }
  if (runThroughSpecies) {
    text("Score: " + speciesChamp.score, 540, 40);
    text("Species: " + (upToSpecies +1) + " (RIGHT to cycle)", 1500, 70);
    text("Members of species: " + pop.species.get(upToSpecies).speciesPlayers.size(), 1500, 100);
  }

  if (runBest) {
    text("Score: " + pop.bestPlayer.score, 540, 40);
    text("Best replay", width/2 - 91, height/2 + 20);
  } else {
    if (showBest) {
      text("Score: " + pop.popPlayers.get(pop.ghostNo).score, 540, 40);

      text("Chase: " + pop.ghostNo, 540, 70);

      text("Number of species: " + pop.species.size(), 1500, 40);
      text("Global Best Score: " + pop.bestScore, 10, 40);
    }
  }
}

//--------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  keyPressed() method handles all features activated by pressing a key.
*/

void keyPressed() {
  switch(key) {
  case ' ': // (spacebar)
    humanPlaying = false;
    // toggle showBest
    showBest = !showBest;
    break;
  case '+': // speed up frame rate
    speed += 10;
    frameRate(speed);
    break;
  case '-': // slow down frame rate
    if (speed > 10) {
      speed -= 10;
      frameRate(speed);
    }
    break;
  case '1':
    // 4-directional vision - unique to GhostNEAT
    visionVersion = 1;
    break;
  case '2':
    // minimal vision - unique to GhostNEAT
    visionVersion = 2;
    break;
  case '3':
    // shared/separate brains - unique to GhostNEAT
    separateBrains = !separateBrains;
    break;
  case '0':
    // show Pac-Man's path - unique to GhostNEAT
    showBestPath = !showBestPath;
    break;
  case 'r':
    // randomise Pac-Man AI - unique to GhostNEAT
    randomPacAI = !randomPacAI; 
    break;
  case 'i':
    // Pac-Man turns either at walls or at nodes - unique to GhostNEAT
    isNode = !isNode;
    break;
  case 'a':
    // change Pac-Man AI - unique to GhostNEAT
    if (pacAI < 4) {
      pacAI++;
    } else {
      pacAI = 0;
      isMoving = true;
    }
    
    if (pacAI == 0) { // random to node/wall
      closestFood = false;
      linearFood = false;
      randomFood = false;
      break;
    } else if ( pacAI == 1) { // closest food A*
      closestFood = true;
      linearFood = false;
      randomFood = false;
      break;
    } else if ( pacAI == 2) { // linear food A*
      closestFood = false;
      linearFood = true;
      randomFood = false;
      break;
    } else if ( pacAI == 3) { // random food A*
      closestFood = false;
      linearFood = false;
      randomFood = true;
      break;
    } else if ( pacAI == 4) { // not moving
      closestFood = false;
      linearFood = false;
      randomFood = false;
      isMoving = false;
      break;
    }
    break;
  case '5':
    // unique to GhostNEAT
    ghostAvoid = !ghostAvoid;
    break;
  case 'b': // run the best
    if (pop.bestPlayer != null) {
      humanPlaying = false;
      runBest = !runBest;
      if (runBest == false) {
        pop.bestPlayer = pop.bestPlayer.createPlayerForReplay(true); // reset the best player so it can play again
      }
    }
    break;
  case 'v':
    // force neural network mutation - unique to GhostNEAT
    if (separateBrains) {
      if (blinkyActive) {
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.mutate(pop.innovationHistory);
      }
      if (clydeActive) {
        pop.popPlayers.get(pop.ghostNo).clydeBrain.mutate(pop.innovationHistory);
      }
      if (inkyActive) {
        pop.popPlayers.get(pop.ghostNo).inkyBrain.mutate(pop.innovationHistory);
      }
      if (pinkyActive) {
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.mutate(pop.innovationHistory);
      }
    } else { // shared brain
      pop.popPlayers.get(pop.ghostNo).brain.mutate(pop.innovationHistory);
    }
    zxcv = true;
    break;
  case 's': // show species
    if (pop.gen > 0) {
      if (showBestEachGen) {
        showBestEachGen = false;
      }
      runThroughSpecies = !runThroughSpecies;
      upToSpecies = 0;
      speciesChamp = pop.species.get(upToSpecies).champ.createPlayerForReplay(false);
  
      if (speciesChamp != null) {
        speciesChamp.pac.replay = true;
  
        ArrayList<Integer> turnsCopy = new ArrayList<Integer>(pop.species.get(upToSpecies).champ.pac.turns);
        speciesChamp.pac.turns = turnsCopy;
      }
    }
    break;
  case 'g': // show generations
    if (pop.gen > 0) {
      if (runThroughSpecies) {
        runThroughSpecies = false;
      }
      showBestEachGen = !showBestEachGen;
      upToGen = 0;
      genPlayerTemp = pop.genPlayers.get(upToGen).createCopy();
    }
    break;
  case 'n': // show absolutely nothing in order to speed up computation
    showNothing = !showNothing;
    break;
  case 'p':
    // human controlled Pac-Man - unique to GhostNEAT
    if (!runBest && showBest) {
      humanPlaying = !humanPlaying;
    }
    break;
  case 'd': // dead
    skippingGens = true;
    pop.killAll();
    break;
  case 'f':
    // show the path of vision - unique to GhostNEAT
    showVision = !showVision;
    break;
  case 'h':
    // unique to GhostNEAT
    showHelp = !showHelp;
    break;
  case 'z':
    // reset network - unique to GhostNEAT
    if (separateBrains) {
      if (blinkyActive) {
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.clear();
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).blinkyBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.mutate(pop.innovationHistory);
      }
      if (clydeActive) {
        pop.popPlayers.get(pop.ghostNo).clydeBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.clear();
        
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).clydeBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).clydeBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).clydeBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).clydeBrain.mutate(pop.innovationHistory);
      }
      if (inkyActive) {
        pop.popPlayers.get(pop.ghostNo).inkyBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.clear();
        
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).inkyBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).inkyBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).inkyBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).inkyBrain.mutate(pop.innovationHistory);
      }
      if (pinkyActive) {
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.clear();
        
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).pinkyBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.mutate(pop.innovationHistory);
      }
    } else {
      pop.popPlayers.get(pop.ghostNo).brain.genes.clear();
      pop.popPlayers.get(pop.ghostNo).brain.nodes.clear();
      
      // create input nodes
      for (int i = 0; i < 9; i++) {
        pop.popPlayers.get(pop.ghostNo).brain.nodes.add(new Node(i));
        pop.popPlayers.get(pop.ghostNo).brain.nodes.get(i).layer = 0;
      }
      // create output nodes
      for (int i = 0; i < 4; i++) {
        pop.popPlayers.get(pop.ghostNo).brain.nodes.add(new Node(i + 9));
        pop.popPlayers.get(pop.ghostNo).brain.nodes.get(i + 9).layer = 1;
      }
      // create bias node
      pop.popPlayers.get(pop.ghostNo).brain.nodes.add(new Node(13)); // bias node
      pop.popPlayers.get(pop.ghostNo).brain.biasNode = 13;
      pop.popPlayers.get(pop.ghostNo).brain.nodes.get(pop.popPlayers.get(pop.ghostNo).brain.biasNode).layer = 0;
      
      pop.popPlayers.get(pop.ghostNo).brain.generateNetwork();
      pop.popPlayers.get(pop.ghostNo).brain.mutate(pop.innovationHistory);
    }
    zxcv = true;
    break;
  case 'x':
    // demonstration brain - unique to GhostNEAT
    if (separateBrains) {
      if (blinkyActive) {
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.clear();
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).blinkyBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.addCXConnection(pop.innovationHistory);
      }
      if (clydeActive) {
        pop.popPlayers.get(pop.ghostNo).clydeBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.clear();
        
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).clydeBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).clydeBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).clydeBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).clydeBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).clydeBrain.addCXConnection(pop.innovationHistory);
      }
      if (inkyActive) {
        pop.popPlayers.get(pop.ghostNo).inkyBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.clear();
        
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).inkyBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).inkyBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).inkyBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).inkyBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).inkyBrain.addCXConnection(pop.innovationHistory);
      }
      if (pinkyActive) {
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.genes.clear();
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.clear();
        
        // create input nodes
        for (int i = 0; i < 9; i++) {
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.add(new Node(i));
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.get(i).layer = 0;
        }
        // create output nodes
        for (int i = 0; i < 4; i++) {
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.add(new Node(i + 9));
          pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.get(i + 9).layer = 1;
        }
        // create bias node
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.add(new Node(13)); // bias node
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.biasNode = 13;
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.nodes.get(pop.popPlayers.get(pop.ghostNo).pinkyBrain.biasNode).layer = 0;
        
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.generateNetwork();
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.addCXConnection(pop.innovationHistory);
      }
    } else {
      pop.popPlayers.get(pop.ghostNo).brain.genes.clear();
      pop.popPlayers.get(pop.ghostNo).brain.nodes.clear();
      
      // create input nodes
      for (int i = 0; i < 9; i++) {
        pop.popPlayers.get(pop.ghostNo).brain.nodes.add(new Node(i));
        pop.popPlayers.get(pop.ghostNo).brain.nodes.get(i).layer = 0;
      }
      // create output nodes
      for (int i = 0; i < 4; i++) {
        pop.popPlayers.get(pop.ghostNo).brain.nodes.add(new Node(i + 9));
        pop.popPlayers.get(pop.ghostNo).brain.nodes.get(i + 9).layer = 1;
      }
      // create bias node
      pop.popPlayers.get(pop.ghostNo).brain.nodes.add(new Node(13)); // bias node
      pop.popPlayers.get(pop.ghostNo).brain.biasNode = 13;
      pop.popPlayers.get(pop.ghostNo).brain.nodes.get(pop.popPlayers.get(pop.ghostNo).brain.biasNode).layer = 0;
      
      pop.popPlayers.get(pop.ghostNo).brain.generateNetwork();
      pop.popPlayers.get(pop.ghostNo).brain.addCXConnection(pop.innovationHistory);
    }
    zxcv = true;
    break;
  case 'c':
    // splice demonstration network into currently viewed network - unique to GhostNEAT
    if (separateBrains) {
      if (blinkyActive) {
        pop.popPlayers.get(pop.ghostNo).blinkyBrain.addCXConnection(pop.innovationHistory);
      }
      if (clydeActive) {
        pop.popPlayers.get(pop.ghostNo).clydeBrain.addCXConnection(pop.innovationHistory);
      }
      if (inkyActive) {
        pop.popPlayers.get(pop.ghostNo).inkyBrain.addCXConnection(pop.innovationHistory);
      }
      if (pinkyActive) {
        pop.popPlayers.get(pop.ghostNo).pinkyBrain.addCXConnection(pop.innovationHistory);
      }
    } else {
      pop.popPlayers.get(pop.ghostNo).brain.addCXConnection(pop.innovationHistory);
    }
    zxcv = true;
    break;
  case '4':
    // 4 ghosts on screen or 1 ghost on screen - unique to GhostNEAT
    if (separateBrains) {
      if (blinkyActive && clydeActive && inkyActive && pinkyActive) {
        if (pop.gen <= 100) {
          blinkyActive = true;
          clydeActive = false;
          inkyActive = false;
          pinkyActive = false;
        } else if (pop.gen <= 200) {
          blinkyActive = false;
          clydeActive = true;
          inkyActive = false;
          pinkyActive = false;
        } else if (pop.gen <= 300) {
          blinkyActive = false;
          clydeActive = false;
          inkyActive = true;
          pinkyActive = false;
        } else if (pop.gen <= 400) {
          blinkyActive = false;
          clydeActive = false;
          inkyActive = false;
          pinkyActive = true;
        }
        g4 = false;
      } else {
        blinkyActive = true;
        clydeActive = true;
        inkyActive = true;
        pinkyActive = true;
        g4 = true;
      }
    } else {
      clydeActive = !clydeActive;
      inkyActive = !inkyActive;
      pinkyActive = !pinkyActive;
      g4 = !g4;
    }
    break;
  case CODED:// any of the arrow keys
    switch(keyCode) {
    case SHIFT:
      // cycling through chases - unique to GhostNEAT
      if (pop.ghostNo < pop.popPlayers.size() - 1) {
        pop.ghostNo++;
      } else {
        pop.ghostNo = 0;
      }
      break;
    case CONTROL:
      // cycling through chases - unique to GhostNEAT
      if (pop.ghostNo > 0) {
        pop.ghostNo--;
      } else {
        pop.ghostNo = pop.popPlayers.size() - 1;
      }
      break;
    case UP:// the only time up/down/left is used is to control the player
      if (humanPlaying) {
        pop.popPlayers.get(pop.ghostNo).pac.replay = false;
        pop.popPlayers.get(pop.ghostNo).pac.humanPress = true;
        pop.popPlayers.get(pop.ghostNo).pac.humanVel = 3;
      }
      break;
    case DOWN:
      if (humanPlaying) {
        pop.popPlayers.get(pop.ghostNo).pac.replay = false;
        pop.popPlayers.get(pop.ghostNo).pac.humanPress = true;
        pop.popPlayers.get(pop.ghostNo).pac.humanVel = 1;
      }
      break;
    case LEFT:
      if (humanPlaying) {
        pop.popPlayers.get(pop.ghostNo).pac.replay = false;
        pop.popPlayers.get(pop.ghostNo).pac.humanPress = true;
        pop.popPlayers.get(pop.ghostNo).pac.humanVel = 2;
      }
      break;
    case RIGHT:// right is used to move through the generations
      if (runThroughSpecies) { // if showing the species in the current generation then move on to the next species
        upToSpecies++;
        if (upToSpecies >= pop.species.size()) {
          runThroughSpecies = false;
        } else {
          speciesChamp = pop.species.get(upToSpecies).champ.createPlayerForReplay(false);

          if (speciesChamp != null) {
            speciesChamp.pac.replay = true;

            ArrayList<Integer> turnsCopySpeciesChamp = new ArrayList<Integer>(pop.species.get(upToSpecies).champ.pac.turns);
            speciesChamp.pac.turns = turnsCopySpeciesChamp;
          }
        }
      } else 
      if (showBestEachGen) { // if showing the best player each generation then move on to the next generation
        upToGen++;
        if (upToGen >= pop.genPlayers.size()) { // if reached the current generation then exit out of the showing generations mode
          showBestEachGen = false;
        } else {
          genPlayerTemp = pop.genPlayers.get(upToGen).createPlayerForReplay(false);

          if (genPlayerTemp != null) {
            genPlayerTemp.pac.replay = true;

            ArrayList<Integer> turnsCopyGen = new ArrayList<Integer>(pop.genPlayers.get(upToGen).pac.turns);
            genPlayerTemp.pac.turns = turnsCopyGen;
          }
        }
      } else if (humanPlaying) {
        pop.popPlayers.get(pop.ghostNo).pac.replay = false;
        pop.popPlayers.get(pop.ghostNo).pac.humanPress = true;
        pop.popPlayers.get(pop.ghostNo).pac.humanVel = 0;
      }
      break;
    }
    break;
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------

/**
*  tileToPixel() method converts tile coordinates to pixel coordinates.
*  Since its access level is not defined it defaults to package, allowing the other classes in the package to call it freely at will.
*/

PVector tileToPixel(PVector tileCoord) {
  PVector pix = new PVector(tileCoord.x * 16 +8, tileCoord.y * 16 +8);
  pix.mult(2); // scaleUp
  pix.x += 500;
  pix.y +=  height - 496 *2.0;
  return pix;
}

//---------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  pixelToTile() method converts pixel coordinates to tile coordinates.
*/

PVector pixelToTile(PVector pix) {
  PVector tileCoord = new PVector(pix.x - 500, pix.y - (height - 496 *2));
  tileCoord.x /= 2.0;
  tileCoord.y /= 2.0;

  PVector finalTileCoord = new PVector((tileCoord.x-8)/16, (tileCoord.y - 8)/16);
  return finalTileCoord;
}

//---------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  isCriticalPosition() checks whether the parameter position is in the centre of a tile.
*/

boolean isCriticalPosition(PVector pos) {
  PVector tileCoord = new PVector(pos.x - 500, pos.y - height - 496 *2);
  tileCoord.x /= 2.0;
  tileCoord.y /= 2.0;
  return ((tileCoord.x-8)%16 == 0 && (tileCoord.y - 8)% 16 == 0);
}

//--------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  AStar() method returns the shortest path from the start node to the finish node.
*/

Path AStar(PathNode start, PathNode finish, PVector vel, Player chase)
{
  LinkedList<Path> big = new LinkedList<Path>(); // stores all paths
  Path extend = new Path(); // a temp Path which is to be extended by adding another node
  Path winningPath = new Path(); // the final path
  Path extended = new Path(); // the extended path
  LinkedList<Path> sorting = new LinkedList<Path>(); // used for sorting paths by their distance to the target

  // starting off with big storing a path with only the starting node
  extend.addToTail(start, finish);
  extend.velAtLast = new PVector(vel.x, vel.y); // used to prevent ghosts from doing a U-turn
  big.add(extend);

  boolean winner = false; // has a path from start to finish been found  

  while (true) // repeat the process until ideal path is found or there is not path found 
  {
    extend = big.pop(); // grab the front path form the big to be extended
    if (ghostAvoid) {
      Ghost[] ghosts = new Ghost[4];
      ghosts[0] = chase.blinky;
      ghosts[1] = chase.clyde;
      ghosts[2] = chase.inky;
      ghosts[3] = chase.pinky;
      
      for (int i = 0; i < extend.path.size()-1; i++) {
        for (Ghost g : ghosts) {
          if (extend.path.get(i).x == extend.path.get(i+1).x && extend.path.get(i).x == pixelToTile(g.pos).x) {
            if ((extend.path.get(i).y <= pixelToTile(g.pos).y && pixelToTile(g.pos).y <= extend.path.get(i + 1).y) || (extend.path.get(i + 1).y <= pixelToTile(g.pos).y && pixelToTile(g.pos).y <= extend.path.get(i).y)) {
              extend.badPath = true;
            }
          }
          if (extend.path.get(i).y == extend.path.get(i+1).y && extend.path.get(i).y == pixelToTile(g.pos).y) {
            if ((extend.path.get(i).x <= pixelToTile(g.pos).x && pixelToTile(g.pos).x <= extend.path.get(i + 1).x) || (extend.path.get(i + 1).x <= pixelToTile(g.pos).x && pixelToTile(g.pos).x <= extend.path.get(i).x)) {
              extend.badPath = true;
            }
          }
        }
      }
    }
    if (extend.path.getLast().equals(finish)) // if goal found
    {
      if (!winner  && !extend.badPath) // if first goal found, set winning path
      {
        winner = true;
        winningPath = extend.createCopy();
      } else { // if current path found the goal in a shorter distance than the previous winner 
        if (winningPath.distance > extend.distance)
        {
          winningPath = extend.createCopy(); // set this path as the winning path
        }
      }
      if (big.isEmpty()) // if this extend is the last path then return the winning path
      {
        return winningPath.createCopy();
      } else { // if not the current extend is useless to us as it cannot be extended since its finished
        extend = big.pop(); // so get the next path
      }
    } 

    // if the final node in the path has already been checked and the distance to it was shorter than this path has taken to get there than this path is no good
    if (!extend.path.getLast().checked || extend.distance < extend.path.getLast().smallestDistToPoint)
    {
      if (!winner || extend.distance + dist(extend.path.getLast().x, extend.path.getLast().y, finish.x, finish.y)  < winningPath.distance) // don't look at paths that are longer than a path which has already reached the goal
      {
        // if this is the first path to reach this node or the shortest path to reach this node then set the smallest distance to this point to the distance of this path
        extend.path.getLast().smallestDistToPoint = extend.distance;

        // move all paths to sorting form big then add the new paths (in the for loop)and sort them back into big
        sorting = (LinkedList)big.clone();
        for (int i =0; i< extend.path.getLast().edges.size(); i++) // for each node incident (connected) to the final node of the path to be extended 
        {
          // if the direction to the new node is in the opposite to the way the path was heading then don't count this path
          PVector directionToPathNode = new PVector( extend.path.getLast().edges.get(i).x -extend.path.getLast().x, extend.path.getLast().edges.get(i).y - extend.path.getLast().y );
          directionToPathNode.limit(vel.mag());
          extended = extend.createCopy();
          extended.addToTail(extend.path.getLast().edges.get(i), finish);
          extended.velAtLast = new PVector(directionToPathNode.x, directionToPathNode.y);
          sorting.add(extended.createCopy()); // add this extended list to the list of paths to be sorted
        }


        /* sorting now contains all the paths form big plus the new paths which where extended
           adding the path which has the higest distance to big first so that its at the back of big
           using selection sort i.e. the easiest and worst sorting algorithm */
        big.clear();
        while (!sorting.isEmpty())
        {
          float max = -1;
          int iMax = 0;
          for (int i = 0; i < sorting.size(); i++)
          {
            if (max < sorting.get(i).distance + sorting.get(i).distToFinish) // A* uses the distance from the goal plus the paths length to determine the sorting order
            {
              iMax = i;
              max = sorting.get(i).distance + sorting.get(i).distToFinish;
            }
          }
          big.addFirst(sorting.remove(iMax).createCopy()); // add it to the front so that the ones with the greatest distance end up at the back
          // and the closest ones end up at the front
        }
      }
      extend.path.getLast().checked = true;
    }

    // if no more paths avaliable
    if (big.isEmpty()) {
      if (winner == false) // there is not path from start to finish
      {
        return null;
      } else { // if winner is found then the shortest winner is stored in winning path so return that
        return winningPath.createCopy();
      }
    }
  }
}

//--------------------------------------------------------------------------------------------------------------------------------------------------

/**
*  visionAStar() method is slightly adapted from PacNEAT's AStar() method to account for GhostNEAT's vision from the tiles surrounding each ghost.
*/

Path visionAStar(PathNode start, PathNode finish, PVector vel, PathNode pos)
{
  LinkedList<Path> big = new LinkedList<Path>(); // stores all paths
  Path extend = new Path(); // a temp Path which is to be extended by adding another node
  Path winningPath = new Path(); // the final path
  Path extended = new Path(); // the extended path
  LinkedList<Path> sorting = new LinkedList<Path>(); // used for sorting paths by their distance to the target

  // starting off with big storing a path with only the starting node
  extend.addToTail(start, finish);
  extend.velAtLast = new PVector(vel.x, vel.y); // used to prevent ghosts from doing a U-turn
  big.add(extend);

  boolean winner = false; // has a path from start to finish been found  

  while (true) // repeat the process until ideal path is found or there is not path found 
  {
    extend = big.pop(); // grab the front path form the big to be extended
    for (int i = 0; i < extend.path.size()-1; i++) {
      if (extend.path.get(i).x == extend.path.get(i+1).x && extend.path.get(i).x == pos.x) {
        if ((extend.path.get(i).y <= pos.y && pos.y <= extend.path.get(i + 1).y) || (extend.path.get(i + 1).y <= pos.y && pos.y <= extend.path.get(i).y)) {
          extend.badPath = true;
        }
      }
      if (extend.path.get(i).y == extend.path.get(i+1).y && extend.path.get(i).y == pos.y) {
        if ((extend.path.get(i).x <= pos.x && pos.x <= extend.path.get(i + 1).x) || (extend.path.get(i + 1).x <= pos.x && pos.x <= extend.path.get(i).x)) {
          extend.badPath = true;
        }
      }
    }
    if (extend.path.getLast().equals(finish)) // if goal found
    {
      if (!winner && !extend.badPath) // if first goal found, set winning path
      {
        winner = true;
        winningPath = extend.createCopy();
      } else { // if current path found the goal in a shorter distance than the previous winner 
        if (winningPath.distance > extend.distance)
        {
          winningPath = extend.createCopy(); // set this path as the winning path
        }
      }
      if (big.isEmpty()) // if this extend is the last path then return the winning path
      {
        return winningPath.createCopy();
      } else { // if not the current extend is useless to us as it cannot be extended since its finished
        extend = big.pop(); // so get the next path
      }
    } 


    // if the final node in the path has already been checked and the distance to it was shorter than this path has taken to get there than this path is no good
    if (!extend.path.getLast().checked || extend.distance < extend.path.getLast().smallestDistToPoint)
    {     
      if (!winner || extend.distance + dist(extend.path.getLast().x, extend.path.getLast().y, finish.x, finish.y)  < winningPath.distance) // don't look at paths that are longer than a path which has already reached the goal
      {

        // if this is the first path to reach this node or the shortest path to reach this node then set the smallest distance to this point to the distance of this path
        extend.path.getLast().smallestDistToPoint = extend.distance;

        // move all paths to sorting form big then add the new paths (in the for loop)and sort them back into big
        sorting = (LinkedList)big.clone();

        for (int i =0; i< extend.path.getLast().edges.size(); i++) // for each node incident (connected) to the final node of the path to be extended 
        {
          // if the direction to the new node is in the opposite to the way the path was heading then don't count this path
          PVector directionToPathNode = new PVector( extend.path.getLast().edges.get(i).x -extend.path.getLast().x, extend.path.getLast().edges.get(i).y - extend.path.getLast().y );
          directionToPathNode.limit(vel.mag());
          extended = extend.createCopy();
          extended.addToTail(extend.path.getLast().edges.get(i), finish);
          extended.velAtLast = new PVector(directionToPathNode.x, directionToPathNode.y);
          sorting.add(extended.createCopy()); // add this extended list to the list of paths to be sorted
        }

        /* sorting now contains all the paths form big plus the new paths which where extended
           adding the path which has the higest distance to big first so that its at the back of big
           using selection sort i.e. the easiest and worst sorting algorithm */
        big.clear();
        while (!sorting.isEmpty())
        {

          float max = -1;
          int iMax = 0;
          for (int i = 0; i < sorting.size(); i++)
          {
            if (max < sorting.get(i).distance + sorting.get(i).distToFinish) // A* uses the distance from the goal plus the paths length to determine the sorting order
            {
              iMax = i;
              max = sorting.get(i).distance + sorting.get(i).distToFinish;
            }
          }
          big.addFirst(sorting.remove(iMax).createCopy()); // add it to the front so that the ones with the greatest distance end up at the back
          // and the closest ones end up at the front
        }
      }
      extend.path.getLast().checked = true;
    }
    // if no more paths avaliable
    if (big.isEmpty()) {
      if (winner == false) // there is not a path from start to finish
      {
        return null;
      } else { // if winner is found then the shortest winner is stored in winning path so return that
        return winningPath.createCopy();
      }
    }
  }
}
