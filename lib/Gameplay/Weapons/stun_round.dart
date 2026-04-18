import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:codeshield/Gameplay/EnemyConfig/enemy.dart';

class StunRound extends CircleComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  double travelDistance = 0;
  final double maxDistance = 300; // How far it goes before expanding
  bool isExpanded = false;
  Vector2 velocity = Vector2(600, 0); // Default speed
  StunRound({required Vector2 position,})
      : super(
          position: position,
          radius: 5,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.yellowAccent,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;
    
    if (!isExpanded) {
      double speed = 600;
      position.x += speed * dt;
      travelDistance += speed * dt;

      if (travelDistance >= maxDistance) {
        expand();
      }
    } else {
      // Fade out the expansion field
      double currentAlpha = paint.color.a;
      if (currentAlpha > 0) {
        paint.color = paint.color.withValues(alpha: (currentAlpha - 2 * dt).clamp(0, 1));
      } else {
        removeFromParent();
      }
    }
  }

  void expand() {
    isExpanded = true;
    radius = 80; // The "Blast" radius
    paint.color = Colors.yellowAccent.withValues(alpha: 0.5);
    // Move anchor to keep expansion centered on the break point
    anchor = Anchor.center;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      other.applyStun();
    }
  }
}