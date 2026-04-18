import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';

// Change from RectangleComponent to SpriteComponent
class Bullet extends SpriteComponent with HasGameReference<SpaceShooterGame> {
  final Vector2 velocity;

  Bullet({required Vector2 position, Vector2? velocity})
      : velocity = velocity ?? Vector2(600, 0),
        super(
          position: position,
          size: Vector2(100, 50), // Adjusted size for a sprite look
          anchor: Anchor.center,
          priority: 10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Load the sprite image
    sprite = await game.loadSprite('20.png'); 

    // 2. Add the Collision Hitbox
    // Since this is a bullet, we use 'passive' to save performance
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move using the specific velocity
    position.add(velocity * dt);
    
    // Cleanup if offscreen (including top/bottom for shotgun spread)
    if (position.x > game.size.x + width || 
        position.x < -width ||
        position.y < -height || 
        position.y > game.size.y + height) {
      removeFromParent();
    }
  }
}