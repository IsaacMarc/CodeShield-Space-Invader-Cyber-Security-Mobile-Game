import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/Gameplay/spaceshooter.dart';

class ScoreBoard extends TextComponent with HasGameReference<SpaceShooterGame> {
  double _timer = 0; 
  late TextComponent upgradeNotifier;

  ScoreBoard()
      : super(
          text: 'SCORE: 0',
          // 1. Positioned at the top right, but using game.size for responsiveness
          // Anchor is top-right so the text grows inward
          anchor: Anchor.topRight,
          priority: 100,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Responsive Positioning
    // x: Screen width minus margin
    // y: Lowered to 60 to avoid the hole-punch camera
    position = Vector2(game.size.x - 20, 20);

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24, // Smaller for mobile screens
        fontWeight: FontWeight.bold,
        fontFamily: 'PixelifySans',
      ),
    );

    upgradeNotifier = TextComponent(
      text: '',
      // Positioned below the Score
      position: Vector2(0, 30), 
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 12, // Compact for mobile
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black45,
          fontFamily: 'PixelifySans',
        ),
      ),
    );
    add(upgradeNotifier);
  }

  @override
  void update(double dt) {
    text = 'SCORE: ${game.score}';
    super.update(dt);
    _timer += dt; 

    if (game.upgradePoints > 0) {
      upgradeNotifier.text = '${game.upgradePoints}+ UPGRADE AVAILABLE';

      double alphaValue = (127 + 128 * sin(_timer * 10)).clamp(0, 255);
      
      upgradeNotifier.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.greenAccent.withAlpha(alphaValue.toInt()),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black45,
          fontFamily: 'PixelifySans',
        ),
      );
    } else {
      upgradeNotifier.text = '';
    }
  }
}

class HomeBaseHealth extends TextComponent with HasGameReference<SpaceShooterGame> {
  HomeBaseHealth()
      : super(
          text: 'HEALTH: 100',
          anchor: Anchor.centerLeft, // Changed to centerLeft for better vertical alignment
          priority: 100,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- RESPONSIVE POSITIONING ---
    // x: 70 (Base width is 60, so this gives a 10px gap)
    // y: size.y / 2 (Centers the text vertically on the screen)
    position = Vector2(70, game.size.y / 2);

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14, // Smaller size to fit the 'label' aesthetic
        fontWeight: FontWeight.bold,
        fontFamily: 'PixelifySans',
        // Optional: Add a slight dark background to make it readable over enemies
        backgroundColor: Colors.black38, 
      ),
    );
  }

  @override
  void update(double dt) {
    // Rotating the text 90 degrees (optional) can make it look like a side-bar label
    // angle = -1.5708; // Uncomment this if you want vertical text!
    
    text = 'SYS HP: ${game.basehealth}%';
    super.update(dt);
  }
}