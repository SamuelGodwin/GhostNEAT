/** //<>//
 *
 *  Species class handles comparing and adding players to species based on their fitness.
 *  Contains sameSpecies() method, for comparing a player's brain with that of a species rep, to determine if it they are similar enough to be in the same species; and giveMeBaby() method to get offspring for the players in a species.
 *
 */

class Species {
  ArrayList<Player> speciesPlayers = new ArrayList<Player>();
  
  int staleness = 0; // how many generations the species has gone without an improvement
  
  // code adapted from PacNEAT to account for multiple brains
  Genome rep;
  Genome blinkyRep;
  Genome clydeRep;
  Genome inkyRep;
  Genome pinkyRep;
  Genome pacRep;
  
  Player champ;
  
  float averageFitness = 0;
  float bestFitness = 0;

  // coefficients for testing compatibility 
  float excessCoeff = 1;
  float weightDiffCoeff = 0.5;
  float compatibilityThreshold = 41;
  // unique to GhostNEAT
  float sharedCompatibilityThreshold = 3;
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Empty constructor method.
  */
  
  Species() {
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  Constructor method which takes in a Player that belongs to this species.
  *  Code adapted from PacNEAT.
  */
  
  Species(Player p) {
    speciesPlayers.add(p); 
    // since it is the only one in the species it is by default the best
    bestFitness = p.fitness;
    
    blinkyRep = p.blinkyBrain.createCopy();
    clydeRep = p.clydeBrain.createCopy();
    inkyRep = p.inkyBrain.createCopy();
    pinkyRep = p.pinkyBrain.createCopy();
    rep = p.brain.createCopy();
    champ = p.createPlayerForReplay(false);
    
    if (champ != null) {
      champ.pac.replay = true;
    
      ArrayList<Integer> turnsCopy = new ArrayList<Integer>(p.pac.turns);
      champ.pac.turns = turnsCopy;
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  sameSpecies() method returns whether the parameter genome is in this species.
  *  Code highly adapted from PacNEAT.
  */
  
  boolean sameSpecies(Player p) {
    if (separateBrains) {
      float blinkyCompatibility;
      float clydeCompatibility;
      float inkyCompatibility;
      float pinkyCompatibility;
      
      float blinkyExcessAndDisjoint = getExcessDisjoint(p.blinkyBrain, blinkyRep); // get the number of excess and disjoint genes between this player and the current species rep
      float blinkyAverageWeightDiff = averageWeightDiff(p.blinkyBrain, blinkyRep); // get the average weight difference between matching genes
      float blinkyLargeGenomeNormaliser = p.blinkyBrain.genes.size() - 16;
      
      if (blinkyLargeGenomeNormaliser < 1) {
        blinkyLargeGenomeNormaliser = 1;
      }
      
      float clydeExcessAndDisjoint = getExcessDisjoint(p.clydeBrain, clydeRep);
      float clydeAverageWeightDiff = averageWeightDiff(p.clydeBrain, clydeRep);
      float clydeLargeGenomeNormaliser = p.clydeBrain.genes.size() - 16;
      
      if (clydeLargeGenomeNormaliser < 1) {
        clydeLargeGenomeNormaliser = 1;
      }
      
      float inkyExcessAndDisjoint = getExcessDisjoint(p.inkyBrain, inkyRep);
      float inkyAverageWeightDiff = averageWeightDiff(p.inkyBrain, inkyRep);
      float inkyLargeGenomeNormaliser = p.inkyBrain.genes.size() - 16;
      
      if (inkyLargeGenomeNormaliser < 1) {
        inkyLargeGenomeNormaliser = 1;
      }
  
      float pinkyExcessAndDisjoint = getExcessDisjoint(p.pinkyBrain, pinkyRep);
      float pinkyAverageWeightDiff = averageWeightDiff(p.pinkyBrain, pinkyRep);
      float pinkyLargeGenomeNormaliser = p.pinkyBrain.genes.size() - 16;
      
      if (pinkyLargeGenomeNormaliser < 1) {
        pinkyLargeGenomeNormaliser = 1;
      }
      
      // compatiblilty formula
      blinkyCompatibility =  (excessCoeff * blinkyExcessAndDisjoint / blinkyLargeGenomeNormaliser) + (weightDiffCoeff * blinkyAverageWeightDiff);
      clydeCompatibility =  (excessCoeff * clydeExcessAndDisjoint / clydeLargeGenomeNormaliser) + (weightDiffCoeff * clydeAverageWeightDiff);
      inkyCompatibility =  (excessCoeff * inkyExcessAndDisjoint / inkyLargeGenomeNormaliser) + (weightDiffCoeff * inkyAverageWeightDiff);
      pinkyCompatibility =  (excessCoeff * pinkyExcessAndDisjoint / pinkyLargeGenomeNormaliser) + (weightDiffCoeff * pinkyAverageWeightDiff);    
      
      float averageCompatibility = (blinkyCompatibility + clydeCompatibility + inkyCompatibility + pinkyCompatibility) / 4;
      
      return (compatibilityThreshold > averageCompatibility);
    } else { // shared brain
      float compatibility;
      
      float excessAndDisjoint = getExcessDisjoint(p.brain, rep); // get the number of excess and disjoint genes between this player and the current species rep
      float averageWeightDiff = averageWeightDiff(p.brain, rep); // get the average weight difference between matching genes
      float largeGenomeNormaliser = p.brain.genes.size() - 16;
      
      if (largeGenomeNormaliser < 1) {
        largeGenomeNormaliser = 1;
      }
      
      // compatiblilty formula
      compatibility =  (excessCoeff * excessAndDisjoint / largeGenomeNormaliser) + (weightDiffCoeff * averageWeightDiff);
          
      return (sharedCompatibilityThreshold > compatibility);
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  addToSpecies() method adds a player to the species.
  */
  
  void addToSpecies(Player p) {
    speciesPlayers.add(p);
  }

  //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  getExcessDisjoint() method returns the number of excess and disjoint genes between the 2 input Genomes i.e. it returns the number of genes which don't match.
  */
  
  float getExcessDisjoint(Genome brain1, Genome brain2) {
    float matching = 0.0;
    for (int i = 0; i < brain1.genes.size(); i++) {
      for (int j = 0; j < brain2.genes.size(); j++) {
        if (brain1.genes.get(i).innovationNo == brain2.genes.get(j).innovationNo) {
          matching ++;
          break;
        }
      }
    }
    return (brain1.genes.size() + brain2.genes.size() - 2*(matching)); // return no of excess and disjoint genes
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  averageWeightDiff() method returns the avereage weight difference between matching genes in the input Genomes.
  */
  
  float averageWeightDiff(Genome brain1, Genome brain2) {
    if (brain1.genes.size() == 0 || brain2.genes.size() ==0) {
      return 0;
    }

    float matching = 0;
    float totalDiff = 0;
    for (int i = 0; i < brain1.genes.size(); i++) {
      for (int j = 0; j < brain2.genes.size(); j++) {
        if (brain1.genes.get(i).innovationNo == brain2.genes.get(j).innovationNo) {
          matching ++;
          totalDiff += abs(brain1.genes.get(i).weight - brain2.genes.get(j).weight);
          break;
        }
      }
    }
    if (matching == 0) { // divide by 0 error
      return 100;
    }
    return totalDiff/matching;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  sortSpecies() method sorts the species by fitness.
  */
  
  void sortSpecies() {
    ArrayList<Player> temp = new ArrayList<Player>(); //<>//

    // selection sort
    for (int i = 0; i < speciesPlayers.size(); i ++) {
      float max = 0;
      int maxIndex = 0;
      for (int j = 0; j < speciesPlayers.size(); j++) {
        if (speciesPlayers.get(j).fitness > max) {
          max = speciesPlayers.get(j).fitness;
          maxIndex = j;
        }
      }
      temp.add(speciesPlayers.get(maxIndex));
      speciesPlayers.remove(maxIndex);
      i--;
    }

    speciesPlayers = (ArrayList)temp.clone();
    if (speciesPlayers.size() == 0) {
      staleness = 200;
      return;
    }
    
    // if new best player
    if (speciesPlayers.get(0).fitness > bestFitness) {
      staleness = 0;
      bestFitness = speciesPlayers.get(0).fitness;
      blinkyRep = speciesPlayers.get(0).blinkyBrain.createCopy();
      clydeRep = speciesPlayers.get(0).clydeBrain.createCopy();
      inkyRep = speciesPlayers.get(0).inkyBrain.createCopy();
      pinkyRep = speciesPlayers.get(0).pinkyBrain.createCopy();
      rep = speciesPlayers.get(0).brain.createCopy();
      champ = speciesPlayers.get(0).createPlayerForReplay(false);
          
      if (champ != null) {
        champ.pac.replay = true;
        
        ArrayList<Integer> turnsCopy = new ArrayList<Integer>(speciesPlayers.get(0).pac.turns);
        champ.pac.turns = turnsCopy;
      }
    } else { // if no new best player
      staleness ++;
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  setAverage() method sets the average fitness of the Players in this species.
  */
  
  void setAverage() {
    float sum = 0;
    for (int i = 0; i < speciesPlayers.size(); i ++) {
      sum += speciesPlayers.get(i).fitness;
    }
    averageFitness = sum/speciesPlayers.size();
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  giveMeBaby() method gets offspring for the players in this species.
  *  Code adapted from PacNEAT to account for multiple brains.
  */
  
  Player giveMeBaby(ArrayList<connectionHistory> innovationHistory) {
    Player baby;
    if (random(1) < 0.25) { // 25% of the time there is no crossover and the child is simply a clone of a random(ish) player
      baby =  selectPlayer().createCopy();
    } else { // 75% of the time do crossover

      // get 2 random(ish) parents 
      Player parent1 = selectPlayer();
      Player parent2 = selectPlayer();

      // the crossover function expects the highest fitness parent to be the object and the lowest as the argument
      if (parent1.fitness < parent2.fitness) {
        baby =  parent2.crossover(parent1);
      } else {
        baby =  parent1.crossover(parent2);
      }
    }
    
    if (separateBrains) {
      baby.blinkyBrain.mutate(innovationHistory);
      baby.clydeBrain.mutate(innovationHistory);
      baby.inkyBrain.mutate(innovationHistory);
      baby.pinkyBrain.mutate(innovationHistory);
    } else {
      baby.brain.mutate(innovationHistory);
    }
    
    return baby;
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  selectPlayer() method selects a player based on its fitness.
  */
  
  Player selectPlayer() {
    float fitnessSum = 0;
    for (int i = 0; i< speciesPlayers.size(); i++) {
      fitnessSum += speciesPlayers.get(i).fitness;
    }

    float rand = random(fitnessSum);
    float runningSum = 0;

    for (int i = 0; i < speciesPlayers.size(); i++) {
      runningSum += speciesPlayers.get(i).fitness; 
      if (runningSum > rand) {
        return speciesPlayers.get(i);
      }
    }
    
    // unreachable code to make the parser happy
    return speciesPlayers.get(0);
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  cull() method kills off the bottom half of the species.
  */
  
  void cull() {
    if (speciesPlayers.size() > 2) {
      for (int i = speciesPlayers.size()/2; i<speciesPlayers.size(); i++) {
        speciesPlayers.remove(i); 
        i--;
      }
    }
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------------
  
  /**
  *  fitnessSharing() method. In order to protect unique players, the fitness of each player is divided by the number of players in the species that that player belongs to.
  */
  
  void fitnessSharing() {
    for (int i = 0; i < speciesPlayers.size(); i++) {
      speciesPlayers.get(i).fitness /= speciesPlayers.size();
    }    
  }
}
