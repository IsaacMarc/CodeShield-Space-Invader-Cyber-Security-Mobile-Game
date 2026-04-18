import 'package:codeshield/Gameplay/Weapons/honeypotdecoy.dart';
import 'package:codeshield/Gameplay/Weapons/powerup.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:codeshield/Gameplay/home_base.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:codeshield/Gameplay/Weapons/bullet.dart';
import 'package:codeshield/Gameplay/explosion.dart';
import 'package:codeshield/Gameplay/EnemyConfig/enemy_database.dart'; 
import 'package:codeshield/Gameplay/Weapons/scan_wave.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math';
import 'package:flutter/material.dart'; 

class EnemyConfig {
  final String spritePath;
  final double speed;
  final double health;
  final Vector2 textureSize;
  final int frames;
  final double stepTime;

  EnemyConfig({
    required this.spritePath,
    required this.textureSize,
    this.speed = 150,
    this.health = 1,
    this.frames = 1,
    this.stepTime = 0.5,
  });
}

class Enemy extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  
  final EnemyConfig config;
  final EnemyType type;
  late double health;
  bool isRevealed = false;
  bool isMalicious = true; 
  bool isStunned = false;
  double stunTimer = 0;
  bool hasShield = true; 
  bool isReplicant = false;
  late double actualSpeed; // Added to handle difficulty scaling

  Enemy({required this.config, required this.type, super.position})
    : super(size: Vector2.all(60.0), anchor: Anchor.center) { // Reduced to 60 for narrow screens
      health = config.health;


    }

  double get moveSpeed {
    if (game.difficulty == GameDifficulty.hard) {
      return config.speed * 1.2; // Set to 1.8x for a very noticeable difference
    }
    return config.speed;
  }

  // --- REVEAL LOGIC (Fixed to use addNewSprite) ---
  void reveal() async {
    if (isRevealed) return; 
    isRevealed = true;
    final random = Random();

    if (type == EnemyType.trojan) {
      await addNewSprite('Trojan.png', true);
      isMalicious = true; 
    } 
    else if (type == EnemyType.phishing) {
      bool isDanger = random.nextBool();
      isMalicious = isDanger;
      String path = isDanger ? 'email_danger.png' : 'email_safe.png';
      // 128x128 texture, 6 frames animation
      await addNewSprite(path, true, customFrames: 6, customSize: Vector2(128, 128));
    }
  }

  @override
  Future<void> onLoad() async {

    await super.onLoad();
    final random = Random();
    String spriteToLoad = config.spritePath;
    bool shouldLoop = true;

    if (type == EnemyType.trojan) {
      spriteToLoad = trojanSprites[random.nextInt(trojanSprites.length)];
    } else if (type == EnemyType.antivirus) {
      spriteToLoad = antivirusSprites[random.nextInt(antivirusSprites.length)];
    } else if (type == EnemyType.malware) {
      spriteToLoad = virusSprites[random.nextInt(virusSprites.length)];
    } else if (type == EnemyType.ransomware) {
      shouldLoop = false;
    }
    
    await addNewSprite(spriteToLoad, shouldLoop);
  }

  Future<void> addNewSprite(String spritepath, bool loop, {int? customFrames, Vector2? customSize}) async {
    double finalStepTime = (type == EnemyType.ransomware) ? double.infinity : config.stepTime;

    animation = await game.loadSpriteAnimation(
      spritepath,
      SpriteAnimationData.sequenced(
        amount: customFrames ?? config.frames,
        stepTime: finalStepTime,
        textureSize: customSize ?? config.textureSize,
        loop: loop, 
      ),
    );

    // Only add hitbox if not already present
    if (children.whereType<RectangleHitbox>().isEmpty) {
      add(RectangleHitbox());
    }
  }

  @override
  void update(double dt) {
    if (isStunned) {
      stunTimer -= dt;
      if (stunTimer <= 0) {
        isStunned = false;
        paint.colorFilter = null;
      }
      return; // Stunned enemies don't move
    }

    final decoy = game.children.whereType<HoneyPotDecoy>().firstOrNull;

    if (decoy != null) {
      Vector2 direction = (decoy.position - position).normalized();
      position += direction * moveSpeed * dt; 
      angle = direction.screenAngle();
    } else {
      // FIXED: Only one movement line per update!
      position.x -= moveSpeed * dt;
    }

    if (type == EnemyType.ransomware && hasShield) {
      animationTicker?.currentIndex = 1;
    }

    super.update(dt);

    if (position.x < -width) {
      removeFromParent();
    }
  }
//----------------------------------------------------------------------------------//
  void applyStun() {
    isStunned = true;
    stunTimer = 2.0; // 1 second freeze
    paint.colorFilter = const ColorFilter.mode(Colors.yellow, BlendMode.srcATop);

    // SPECIAL INTERACTION: Ransomware Shield Break
    if (type == EnemyType.ransomware && hasShield) {
      hasShield = false;
      animationTicker?.currentIndex = 0;
    }
  }

   @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    onRemove();

    if (other is ScanWave) {
      reveal();
      return;
    }

    if (other is Bullet) {
      // Penalty for shooting a revealed SAFE email
      if (isRevealed && type == EnemyType.phishing && !isMalicious) {
        game.score -= 50; 
      } else if (type == EnemyType.ransomware && hasShield) {
        // The bullet hits the "Encryption Shield" and does nothing
        other.removeFromParent(); 
        // Optional: Add a 'ting' sound or a small spark effect here
        return; 
      }
      
      health--; 
      other.removeFromParent();

      if (health <= 0) {
        removeFromParent();
        // --- ADDED: Play explosion sound when enemy dies ---        
        game.add(Explosion(position: position));
        game.score += (isRevealed && isMalicious) ? 100 : 10;
      }
    } 
    
    else if (other is HomeBase) {
      removeFromParent();
      
      if (other.isShieldActive) {
        // MFA blocked the threat!
        removeFromParent();
        // --- ADDED: Play explosion sound for blocked threat ---
        FlameAudio.play('enemy die.wav', volume: 0.1);
        
        game.add(Explosion(position: position));
        return; // No damage to basehealth
      }
      
      // If it's revealed as SAFE, it heals the base.
      // If it's NOT revealed, it acts as a threat (player failed to scan).
      if (isRevealed && !isMalicious || type == EnemyType.antivirus) {
        game.basehealth = (game.basehealth + 10).clamp(0, 100);
        game.score += 50; // Bonus for letting safe data through
        // --- OPTIONAL: You could add a 'heal' or 'ding' sound here ---
      } else {
        game.basehealth -= 10;
        // --- ADDED: Play explosion sound when base takes damage ---
        FlameAudio.play('enemy die.wav', volume: 0.1); 
        
        game.add(Explosion(position: position));
      }
      
      game.healthBar.updateHealth(game.basehealth);
      other.triggerHitEffect();
    }
  }
@override
void onRemove() {
  super.onRemove();

// Only drop if health is 0 (prevents drops if they just fly off screen)
    if (health <= 0 && !isReplicant) {
      _dropPowerUp();
    }

  // If a Malware enemy dies, it "replicates" into 2 smaller/faster versions
  if (type == EnemyType.malware && health <= 0) {
    _replicate();
    
  }
}

void _dropPowerUp() {
  double dropChance = (game.difficulty == GameDifficulty.hard) ? 0.05 : 0.20;

    if (Random().nextDouble() < dropChance) {
      final type = PowerUpType.values[Random().nextInt(PowerUpType.values.length)];
      game.add(PowerUp(type: type, position: position.clone()));
    }
}

void _replicate() {
    // If this is already a child/replicant, STOP the chain here
    if (isReplicant) return;

    for (int i = 0; i < 2; i++) {
      double yOffset = (i == 0) ? -40 : 40;
      
      final newMalware = Enemy(
        config: config,
        type: type,
        position: position + Vector2(10, yOffset), 
      );

      // Mark the new ones so they DON'T split again
      newMalware.isReplicant = true; 
      newMalware.health = 1; // Make them easy to clear
      
      // Optional: Make replicants faster to simulate a "spreading" virus
      // newMalware.config.speed += 50; 

      game.add(newMalware);
    }
  }
}