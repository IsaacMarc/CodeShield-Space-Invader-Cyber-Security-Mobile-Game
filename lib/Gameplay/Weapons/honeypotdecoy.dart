
import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class HoneyPotDecoy extends SpriteComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  double health = 100; // Increased health to last longer
  double lifetime = 10.0;

  HoneyPotDecoy({required Vector2 position}) 
    : super(position: position, size: Vector2(100, 100), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('honeypot_active.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifetime -= dt;
    if (lifetime <= 0 || health <= 0) removeFromParent();
  }
}