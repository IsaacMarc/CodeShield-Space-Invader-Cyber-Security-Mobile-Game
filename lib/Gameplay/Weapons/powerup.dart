import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:codeshield/Gameplay/player.dart';

import 'package:codeshield/Gameplay/spaceshooter.dart';

enum PowerUpType { fireRate, mfaShield, honeyPot, totalReset, firewall }

class PowerUp extends SpriteComponent with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  final PowerUpType type;

  PowerUp({required this.type, required Vector2 position}) 
    : super(position: position, size: Vector2(48, 48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

  String fileName;
    switch (type) {
      case PowerUpType.fireRate:
        fileName = 'speed_boost.png'; // Change to your actual filename
        break;
      case PowerUpType.totalReset:
        fileName = 'system_wipe.png';
        break;
      case PowerUpType.firewall:
        fileName = 'firewall_shield.png';
        break;
      case PowerUpType.mfaShield:
        fileName = 'mfa_shield_visual.png';
        break;
      case PowerUpType.honeyPot:
        fileName = 'honeypot_active.png';
        break;
    }
    
    sprite = await game.loadSprite(fileName);
    add(CircleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= 100 * dt; // Float left
    
    // If the powerup moves off the left side of the screen
    if (position.x < -50) {
      removeFromParent();
    }
    
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      game.applyPowerUp(type);
      removeFromParent();
    }
  }
}