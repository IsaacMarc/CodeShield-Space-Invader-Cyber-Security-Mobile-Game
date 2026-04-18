import 'dart:async';
import 'package:codeshield/Gameplay/home_base.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:codeshield/Gameplay/EnemyConfig/enemy_database.dart';
import 'package:codeshield/Gameplay/Weapons/bullet.dart';
import 'package:codeshield/Gameplay/explosion.dart';

class BossHealthBar extends PositionComponent with HasGameReference<SpaceShooterGame> {
  @override
  void render(Canvas canvas) {
    // We cast the parent to BossFight to get its health values
    final parentBoss = parent as BossFight;
    final percent = (parentBoss.health / parentBoss.maxHealth).clamp(0.0, 1.0);
    
    // Position the bar above the boss sprite
    // Background (Red)
    canvas.drawRect(Rect.fromLTWH(-50, -280, 100, 12), Paint()..color = Colors.red.withOpacity(0.5));
    // Foreground (Green)
    canvas.drawRect(Rect.fromLTWH(-50, -280, 100 * percent, 12), Paint()..color = Colors.green);
  }
}

class BossFight extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  final String spritePath;
  double health;
  double maxHealth;
  
  double spawnTimer = 0;
  bool isMouthOpen = false;

  // Added constructor parameters for customizability
  BossFight({
    required this.spritePath,
    required Vector2 position,
    this.maxHealth = 1500,
  }) : health = maxHealth,
       super(
        position: position,
        size: Vector2(512, 512), 
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      spritePath, // Use the dynamic path passed from WaveManager
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: double.infinity, 
        textureSize: Vector2(512, 512), 
      ),
    );

    // Hitbox adjusted for the 512 size
    add(RectangleHitbox(
      size: size * 0.40, 
      position: size * 0.30, 
    ));
    
    add(BossHealthBar());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Slow Movement
    position.x -= 25 * dt;

    // 2. Spawning Logic
    spawnTimer += dt;

    // Open mouth logic (Cycle: 3s closed -> 2s open)
    if (!isMouthOpen && spawnTimer >= 3.0) {
      _openMouth();
    } else if (isMouthOpen && spawnTimer >= 5.0) {
      _closeMouth();
    }
  }

  Future<void> _openMouth() async {
    if (isMouthOpen) return;
    isMouthOpen = true;
    
    animationTicker?.currentIndex = 1; // Open mouth frame

    // Position minions to spawn slightly in front of the mouth
    final enemyPosition = position.clone()..x -= 100..y += 80;

    for (int i = 0; i < 2; i++) {
      // Logic to pick a random malware/virus type
      int nextIndex = game.waveManager.random.nextInt(EnemyType.values.length - 1);
      EnemyType typeToSpawn = EnemyType.values[nextIndex];

      game.spawnEnemyAt(typeToSpawn, enemyPosition);

      await Future.delayed(const Duration(milliseconds: 600));
      if (!isMounted) return; 
    }
  }

  void _closeMouth() {
    isMouthOpen = false;
    spawnTimer = 0;
    animationTicker?.currentIndex = 0; // Mouth Closed Frame
  }

  void triggerHitEffect() {
    paint.colorFilter = const ColorFilter.mode(Colors.red, BlendMode.srcATop);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted) paint.colorFilter = null;
    });
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Bullet) {
      health -= 10;
      triggerHitEffect();
      other.removeFromParent();

      if (health <= 0) {
        // 1. Give the score
        game.score += 1000;
        
        // 2. Add the big explosion
        game.add(Explosion(position: position)..scale = Vector2.all(3));
        
        // 3. Just remove the boss. 
        // The WaveManager's update() loop will see there are 0 bosses left 
        // and trigger the "HACKERS NEUTRALIZED" message and the 3s timer.
        removeFromParent();
      } 
    } else if (other is HomeBase) {
      // Critical damage if boss hits base
      game.basehealth -= 100;
      game.healthBar.updateHealth(game.basehealth);
      game.add(Explosion(position: position)..scale = Vector2.all(2));
      other.triggerHitEffect(); 
      
      // Even if the boss dies by hitting the base, the WaveManager will see it's gone.
      removeFromParent();
    }
  }
}