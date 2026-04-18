import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';

class HomeBase extends RectangleComponent with HasGameReference<SpaceShooterGame> {
  late SpriteComponent _visual;

  // We set size to zero initially and calculate it based on the actual screen height
  HomeBase() : super(
    size: Vector2(120, 0), // Width 60 is better for narrow mobile screens
    position: Vector2(0, 0),
    paint: Paint()..color = Colors.transparent, 
  );

  bool isShieldActive = false;
  RectangleComponent? shieldOverlay;

  Future<void> activateMFAShield() async {
    if (isShieldActive) return;
    isShieldActive = true;

    shieldOverlay = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0x6600FFFF) // Cyan Glow (Cyber Aesthetic)
        ..style = PaintingStyle.fill,
      children: [
        RectangleBorderComponent(
          size: size,
          paint: Paint()
            ..color = const Color(0xFF00FFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        ),
      ],
    );

    add(shieldOverlay!);

    // MFA Shield Duration: 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      isShieldActive = false;
      shieldOverlay?.removeFromParent();
    });
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Dynamically set height to the exact height of the Tecno Camon screen
    size.y = game.size.y;

    _visual = SpriteComponent(
      sprite: await game.loadSprite("homeserver.png"),
      // Using BoxFit.fill logic via the sprite component's size
      size: Vector2(size.x, size.y), 
    );
    
    add(_visual);

    add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));
  }

  void triggerHitEffect() {
    _visual.paint.colorFilter = const ColorFilter.mode(
      Colors.red, 
      BlendMode.srcATop,
    );
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_visual.isMounted) {
        _visual.paint.colorFilter = null;
      }
    });
  }
}

class RectangleBorderComponent extends RectangleComponent {
  RectangleBorderComponent({required super.size, required super.paint});
}