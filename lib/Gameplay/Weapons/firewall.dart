import 'package:codeshield/Gameplay/EnemyConfig/enemy.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class FirewallWall extends SpriteComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  final double speed = 400;

  FirewallWall({required Vector2 position}) 
    : super(position: position, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Use the viewport size to ensure it matches the actual visible screen
    // We add +200 just to be absolutely sure there is no gap at the bottom
    size = Vector2(80, game.size.y + 200); 
    
    sprite = await game.loadSprite('firewall.png'); 
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Safety check: Keep Y pinned at 0 in case a collision moves it
    position.y = 0;
    
    position.x += speed * dt;

    if (position.x > game.size.x + 100) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      other.position.x = position.x + size.x;
    }
  }
}