/** //<>//
 *
 *  Population class features the population of Players, and handles this natural selection, including speciation and determining the fittest player each gen.
 *  Contains naturalSelection(), Speciate() and sortSpecies() methods, among others, for handling evolution and speciation.
 *
 */

class Population {
  // for cycling through chases - unique to GhostNEAT
  int ghostNo = 0;
  int bestScore = 0; // the score of the best ever player
  int gen = 0;
  
  ArrayList<Player> popPlayers = new ArrayList<Player>();  
  ArrayList<connectionHistory> innovationHistory = new ArrayList<connectionHistory>();
  ArrayList<Player> genPlayers = new ArrayList<Player>();
  ArrayList<Species> species = new ArrayList<Species>();

  boolean massExtinctionEvent = false;

  Player bestPlayer; // the best ever player

  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Population() constructor method generates and makes an initial mutation of all Players' brains.
  */

  Population(int size) {
    for (int i = 0; i < size; i++) {
      popPlayers.add(new Player());
      popPlayers.get(i).blinkyBrain.generateNetwork();
      popPlayers.get(i).blinkyBrain.mutate(innovationHistory);
      popPlayers.get(i).clydeBrain.generateNetwork();
      popPlayers.get(i).clydeBrain.mutate(innovationHistory);
      popPlayers.get(i).inkyBrain.generateNetwork();
      popPlayers.get(i).inkyBrain.mutate(innovationHistory);
      popPlayers.get(i).pinkyBrain.generateNetwork();
      popPlayers.get(i).pinkyBrain.mutate(innovationHistory);
      popPlayers.get(i).brain.generateNetwork();
      popPlayers.get(i).brain.mutate(innovationHistory);
      popPlayers.get(i).id = i;
    }    
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  killAll() method kills all Players in the population, ending the current gen.
  *  Code unique to GhostNEAT.
  */
  
  void killAll() {
    for (int i = 0; i < popPlayers.size(); i++) {
      popPlayers.get(i).pac.gameOver = true;
    }

    humanPlaying = false;
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  updateAlive() method updates all the Players in the population which are alive.
  */
  
  void updateAlive() {
    for (int i = 0; i < popPlayers.size(); i++) {
      if (!popPlayers.get(i).dead) {
        popPlayers.get(i).look(); // get inputs for brain 
        popPlayers.get(i).think(); // use outputs from neural network
        popPlayers.get(i).update(); // move the player according to the outputs from the neural network
        if (!showNothing && (!showBest || i == ghostNo)) {
          popPlayers.get(i).show();
        }
      }
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  done() method returns true if all the players are dead.
  */
  
  boolean done() {
    for (int i = 0; i < popPlayers.size(); i++) {
      if (!popPlayers.get(i).dead) {
        return false;
      }
    }
    return true;
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  setBestPlayer() method sets the best player globally and for this gen.
  */
  
  void setBestPlayer() {
    Player tempBest = species.get(0).speciesPlayers.get(0);
    tempBest.gen = gen;

    // if best this gen is better than the global best score then set the global best as the best this gen    
    if (tempBest.score >= bestScore) {
      genPlayers.add(tempBest.createPlayerForReplay(true));
      bestScore = tempBest.score;
      bestPlayer = tempBest.createPlayerForReplay(true);
      bestPlayer.isBest = true;
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  naturalSelection() method is called when all the players in the population are dead and a new generation needs to be made.
  */
  
  void naturalSelection() {
    speciate(); // seperate the population into species
    calculateFitness(); // calculate the fitness of each player
    sortSpecies(); // sort the species to be ranked in fitness order, best first
    if (massExtinctionEvent) {
      massExtinction();
      massExtinctionEvent = false;
    }
    cullSpecies(); // kill off the bottom half of each species
    setBestPlayer(); // save the best player of this gen
    killStaleSpecies(); // remove species which haven't improved in the last 15(ish) generations  //<>//
    killBadSpecies(); // kill species which are so bad that they can't reproduce
    
    // Pac-Man AI randomiser - unique to GhostNEAT
    if (randomPacAI) {
      pacAI = floor(random(4));
    }

    float averageSum = getAvgFitnessSum();
    ArrayList<Player> children = new ArrayList<Player>(); // the next generation
    for (int j = 0; j < species.size(); j++) { // for each species
      children.add(species.get(j).champ.createPlayerForReplay(false)); // add champion without any mutation

      int NoOfChildren = floor(species.get(j).averageFitness/averageSum * popPlayers.size()) -1; // the number of children this species is allowed, note -1 is because the champ is already added
      for (int i = 0; i< NoOfChildren; i++) { // get the calculated amount of children from this species
        children.add(species.get(j).giveMeBaby(innovationHistory));
      }
    }

    while (children.size() < popPlayers.size()) { // if not enough babies (due to flooring the number of children to get a whole int) 
      children.add(species.get(0).giveMeBaby(innovationHistory)); // get babies from the best species
    }
    popPlayers.clear();
    popPlayers = (ArrayList)children.clone(); // set the children as the current population
    gen += 1;
    
    for (int i = 0; i< popPlayers.size(); i++) { // generate networks for each of the children
      if (separateBrains) {
        if (blinkyActive) {
          popPlayers.get(i).blinkyBrain.generateNetwork();
        }
        if (clydeActive) {
          popPlayers.get(i).clydeBrain.generateNetwork();
        }
        if (inkyActive) {
          popPlayers.get(i).inkyBrain.generateNetwork();
        }
        if (pinkyActive) {
          popPlayers.get(i).pinkyBrain.generateNetwork();
        }
      } else {
        popPlayers.get(i).brain.generateNetwork();
      }
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  speciate() method seperates the population into species based on how similar they are to the leaders of each species in the previous gen.
  */
  
  void speciate() {
    for (Species s : species) { // empty species
      s.speciesPlayers.clear();
    }
    for (int i = 0; i < popPlayers.size(); i++) { // for each player
      boolean speciesFound = false;
      for (Species s : species) { // for each species
        // if the player is similar enough to be considered in the same species
        if (s.sameSpecies(popPlayers.get(i))) {
          s.addToSpecies(popPlayers.get(i)); // add it to the species
          speciesFound = true;
          break;
        }
      }
      if (!speciesFound) { // if no species was similar enough then add a new species with this as its champion
        species.add(new Species(popPlayers.get(i)));
      }
    }
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  calculateFitness() method calculates the fitness of all Players in the population.
  */
   
  void calculateFitness() {  
    for (int i = 0; i < popPlayers.size(); i++) {
      popPlayers.get(i).calculateFitness();
    }
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  sortspecies() method sorts the players within a species by their fitnesses, and then sorts the species themselves by the fitness of their best player.
  */
  
  void sortSpecies() {
    // sort the players within a species
    for (Species s : species) {
      s.sortSpecies();
    }

    /* sort the species by the fitness of its best player
       using selection sort */
    ArrayList<Species> temp = new ArrayList<Species>();
    
    for (int i = 0; i < species.size(); i ++) {
      float max = 0;
      int maxIndex = 0;
      for (int j = 0; j< species.size(); j++) {
        if (species.get(j).bestFitness > max) {
          max = species.get(j).bestFitness;
          maxIndex = j;
        }
      }
      temp.add(species.get(maxIndex));
      species.remove(maxIndex);
      i--;
    }
    
    species = (ArrayList)temp.clone();
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  killStaleSpecieS() method kills all species which haven't improved for 15 generations.
  */
  
  void killStaleSpecies() {
    for (int i = 2; i< species.size(); i++) {
      if (species.get(i).staleness >= 15) {
        species.remove(i);
        i--;
      }
    }
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  killBadSpecies() method. If a species sucks so much that it won't even be allocated 1 child for the next generation then kill it now.
  */
  
  void killBadSpecies() {
    float averageSum = getAvgFitnessSum();

    for (int i = 1; i< species.size(); i++) {
      if (species.get(i).averageFitness/averageSum * popPlayers.size() < 1) { // if won't be given a single child 
        species.remove(i);
        i--;
      }
    }
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  getAvgFitnessSum() method returns the sum of the average fitness of each species.
  */
  
  float getAvgFitnessSum() {
    float averageSum = 0;
    for (Species s : species) {
      averageSum += s.averageFitness;
    }
    return averageSum;
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  cullSpecies() method kills the bottom half of each species.
  */
  
  void cullSpecies() {
    for (Species s : species) {
      s.cull(); // kill bottom half
      s.fitnessSharing();
      s.setAverage(); // reset averages because they will have changed
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  massExtinction() method kills all but the first 5 species.
  */
  
  void massExtinction() {
    for (int i = 5; i < species.size(); i++) {
      species.remove(i);
      i--;
    }
  }
}
