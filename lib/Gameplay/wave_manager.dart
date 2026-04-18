import 'dart:math';
import 'package:flame/components.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:codeshield/Gameplay/EnemyConfig/enemy_database.dart';
import 'package:codeshield/Gameplay/EnemyConfig/boss.dart'; 

class WaveManager extends Component with HasGameReference<SpaceShooterGame> {
  int currentWaveNumber = 1; 
  double waveTimer = 45.0; 
  double spawnTimer = 0;
  double spawnInterval = 1.0; 
  
  OSILayer? currentLayer;
  final Random random = Random();

  bool bossSpawned = false;
  bool isVictoryTransition = false;
  double timeInWave = 0; 
  OSILayer? lastLayer;

  @override
  void onMount() {
    super.onMount();
    _startNewWave();
  }

  void _startNewWave() {
waveTimer = 45.0; 
  spawnTimer = 0;
  timeInWave = 0; 
  bossSpawned = false;
  isVictoryTransition = false; 

  if (currentWaveNumber > 1) {
    game.upgradePoints += 2;
  }

  // --- IMPROVED RANDOM LOGIC ---
  if (currentWaveNumber % 10 == 0) {
    currentLayer = OSILayer.boss;
    _spawnDoubleBosses();
    bossSpawned = true; 
  } else if (currentWaveNumber % 5 == 0) {
    currentLayer = OSILayer.boss;
    _spawnBoss();
    bossSpawned = true;
  } else if (currentWaveNumber % 4 == 0){
    currentLayer = null;
  } else {
    List<OSILayer> layers = [
      OSILayer.layer3, OSILayer.layer4, OSILayer.layer5, OSILayer.layer6, OSILayer.layer7, 
    ]; 
    
    // --- THE ANTI-REPEAT LOOP ---
    OSILayer nextLayer;
    do {
      nextLayer = layers[random.nextInt(layers.length)];
    } while (nextLayer == lastLayer); // Keep rolling if it matches the previous wave
    
    currentLayer = nextLayer;
    lastLayer = currentLayer; // Save this for the next wave's check
  }
    
    // --- UI TEXT LOGIC ---
    String layerName = "";
    if (currentWaveNumber % 10 == 0) {
      layerName = "!!! FINAL APT: DUAL BOSS !!!";
    } else if (currentWaveNumber % 5 == 0) {
      layerName = "!!! BOSS: SYSTEM BREACH !!!";
    } else if (currentWaveNumber % 4 == 0) {
      layerName = "CRITICAL: MULTI-LAYER ATTACK";
    } else {
      switch(currentLayer) {
        case OSILayer.layer3: layerName = "Layer 3: Network"; break;
        case OSILayer.layer4: layerName = "Layer 4: Transport"; break;
        case OSILayer.layer5: layerName = "Layer 5: Session"; break;
        case OSILayer.layer6: layerName = "Layer 6: Presentation"; break;
        case OSILayer.layer7: layerName = "Layer 7: Application"; break;
        default: layerName = "Scanning Threats...";
      }
    }

    String fullMessage = "WAVE $currentWaveNumber - $layerName";
    game.showWaveAnnouncement(fullMessage);
  }

  @override
  void update(double dt) {
    waveTimer -= dt;
    spawnTimer += dt;
    timeInWave += dt; 
  
    if (currentLayer == OSILayer.boss && timeInWave > 3.0 && !isVictoryTransition) {
      bool bossesAreDead = game.children.whereType<BossFight>().isEmpty;
      if (bossesAreDead) {
        isVictoryTransition = true;
        game.showWaveAnnouncement("THREAT NEUTRALIZED - SYSTEM RESTORED");
        waveTimer = 3.0; 
      }
    }

    if (waveTimer <= 0) {
      currentWaveNumber++;
      _startNewWave();
    }

    // Spawning logic (Don't spawn minions during boss fights)
    if (currentLayer != OSILayer.boss && spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      _spawnEnemy();
    }
  }

  Future<void> _spawnEnemy() async {
    // --- SMOOTH PROGRESSIVE SPAWN RATE ---
  // Instead of subtracting, we multiply by 0.92 (an 8% reduction in delay)
  // This creates a much smoother difficulty curve.
  double baseInterval = 2.0 * pow(0.92, currentWaveNumber - 1);

  // Apply the 'Floor' so it never spawns faster than 0.5s
  baseInterval = baseInterval.clamp(0.5, 2.0);

  // --- HARD MODE ADJUSTMENT ---
  if (game.difficulty == GameDifficulty.hard) {
    baseInterval *= 0.7; // 30% faster than Normal
  }

  spawnInterval = baseInterval;
    EnemyType typeToSpawn;
    OSILayer activeLayer;

    // --- MULTI-LAYER ATTACK LOGIC ---
    if (currentWaveNumber % 4 == 0) {
      // Pick a random layer for EACH individual spawn
      List<OSILayer> allLayers = [OSILayer.layer3, OSILayer.layer4, OSILayer.layer5, OSILayer.layer6, OSILayer.layer7];
      activeLayer = allLayers[random.nextInt(allLayers.length)];
    } else {
      activeLayer = currentLayer!;
    }

    List<EnemyType>? possibleEnemies = layerEnemies[activeLayer];
    if (possibleEnemies == null || possibleEnemies.isEmpty) return;
    typeToSpawn = possibleEnemies[random.nextInt(possibleEnemies.length)];

    // Increased pattern chance on Multi-Layer waves or Hard mode
    double patternChance = (currentWaveNumber % 4 == 0 || game.difficulty == GameDifficulty.hard) ? 0.15 : 0.05;

    if (random.nextDouble() < patternChance) {
      spawnPattern(activeLayer);
      spawnTimer = (game.difficulty == GameDifficulty.hard) ? -0.5 : -1.5; 
    } else {
      game.spawnEnemy(typeToSpawn);
    }
  }

  void _spawnBoss() {
    game.add(BossFight(
      spritePath: 'theisaac.png',
      position: Vector2(game.size.x + 100, game.size.y / 2),
    ));
  }

  void _spawnDoubleBosses() {
    game.add(BossFight(
      spritePath: 'emmanboss.png',
      position: Vector2(game.size.x + 100, game.size.y * 0.25),
    ));
    game.add(BossFight(
      spritePath: 'thecarl.png',
      position: Vector2(game.size.x + 100, game.size.y * 0.75),
    ));
  }

  void spawnPattern(OSILayer layer) {
    List<EnemyType>? possible = layerEnemies[layer];
    if (possible == null) return;
    final type = possible[random.nextInt(possible.length)];
    int patternType = random.nextInt(5);
    switch (patternType) {
      case 0: _spawnTriangle(type); break;
      case 1: _spawnVerticalLine(type); break;
      case 2: _spawnArrow(type); break;
      case 3: _spawnCircle(type); break;
      case 4: _spawnStaggeredV(type); break;
    }
  }

  // --- SPAWN PATTERNS ---
  void _spawnCircle(EnemyType type) {
    final startX = game.size.x + 150;
    final centerY = game.size.y / 2;
    const double radius = 100;
    for (int i = 0; i < 6; i++) {
      double angle = i * (pi / 3);
      game.spawnEnemyAt(type, Vector2(startX + cos(angle) * radius, centerY + sin(angle) * radius));
    }
  }

  void _spawnStaggeredV(EnemyType type) {
    final startX = game.size.x + 100;
    final midY = game.size.y / 2;
    for (int i = 0; i < 3; i++) {
      game.spawnEnemyAt(type, Vector2(startX + (i * 40), midY - (i * 80)));
      game.spawnEnemyAt(type, Vector2(startX + (i * 40), midY + (i * 80)));
    }
  }

  void _spawnTriangle(EnemyType type) {
    final startX = game.size.x + 100;
    final centerY = game.size.y / 2;
    game.spawnEnemyAt(type, Vector2(startX, centerY));
    game.spawnEnemyAt(type, Vector2(startX + 60, centerY - 60));
    game.spawnEnemyAt(type, Vector2(startX + 60, centerY + 60));
  }

  void _spawnVerticalLine(EnemyType type) {
    final startX = game.size.x + 100;
    for (int i = 1; i <= 4; i++) {
      game.spawnEnemyAt(type, Vector2(startX, (game.size.y / 5) * i));
    }
  }

  void _spawnArrow(EnemyType type) {
    final startX = game.size.x + 100;
    final midY = game.size.y / 2;
    game.spawnEnemyAt(type, Vector2(startX, midY));
    game.spawnEnemyAt(type, Vector2(startX + 40, midY - 40));
    game.spawnEnemyAt(type, Vector2(startX + 40, midY + 40));
    game.spawnEnemyAt(type, Vector2(startX + 80, midY - 80));
    game.spawnEnemyAt(type, Vector2(startX + 80, midY + 80));
  }
}