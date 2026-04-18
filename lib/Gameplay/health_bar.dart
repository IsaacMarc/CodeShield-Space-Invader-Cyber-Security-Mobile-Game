import 'package:flame/components.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';

class HealthBar extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame> {
 

  HealthBar() : super(
    size: Vector2(192,68), // How big you want it to look on screen
    position: Vector2(145, 0), // Top-left margin
    priority: 100, // Keep it on top of enemies
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'health_bar.png', 
      SpriteAnimationData.sequenced(
        amount: 11,
        stepTime: double.infinity, // Manual control only
        textureSize: Vector2(768, 272), // IMPORTANT: Change this to the pixel size of ONE frame in your Piskel
      ),
    );
    
    animationTicker?.currentIndex = 0; // Start at full health
  }

  void updateHealth(int currentHealth) {
    // Math: 100=0, 90=1 ... 0=10
    int frameIndex = ((100 - currentHealth) / 10).floor().clamp(0, 10);
    animationTicker?.currentIndex = frameIndex;
  }
}