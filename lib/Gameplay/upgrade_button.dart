import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';

class UpgradeButton extends SpriteGroupComponent<bool> 
    with HasGameReference<SpaceShooterGame>, TapCallbacks {
  
  UpgradeButton() : super(size: Vector2(160, 60), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    sprites = {
      false: await game.loadSprite('update_normal.png'),
      true: await game.loadSprite('update_alert.png'),
    };
    position = Vector2(20, game.size.y - 20);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Switch to the 'true' (Alert) sprite if there are points
    current = game.upgradePoints > 0;
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.overlays.add('UpgradeMenu');
  }
}