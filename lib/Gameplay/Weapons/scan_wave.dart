import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/Gameplay/EnemyConfig/enemy.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';

class ScanWave extends RectangleComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  
  ScanWave({required Vector2 position})
      : super(
          position: position,
          // Start thin, but make it as tall as the game screen
          size: Vector2(10, 2000), 
          anchor: Anchor.centerLeft,
          // paint: Paint()
          //   ..color = Colors.cyanAccent.withValues(alpha: 0.8)
          //   ..style = PaintingStyle.fill,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Use game.size instead of canvasSize
    size.y = game.size.y;
    position.y = game.size.y / 2;

    // 1. ADD A GLOW
    paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10); // Neon glow effect

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 2. MOVEMENT & TRAIL
    const double scanSpeed = 700;
    position.x += scanSpeed * dt;

    // Fade out
    double currentAlpha = paint.color.a;
    if (currentAlpha > 0) {
      paint.color = paint.color.withValues(alpha: (currentAlpha - 0.8 * dt).clamp(0, 1));
    }

    if (position.x > game.size.x || paint.color.a <= 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Enemy) {
      other.reveal();
      
      // 3. PARTICLE EFFECTS ON HIT
      _spawnScanParticles(intersectionPoints.first);
    }
  }

  void _spawnScanParticles(Vector2 position) {
    final nextPosition = position.clone();
    // nextPosition.x += 5;
    game.add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          lifespan: 1,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2((i - 2) * 50, -100),
            position: nextPosition,
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = Colors.cyanAccent,
            ),
          ),
        
        ),
      ),
    );
  }
}