import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WaveAnnouncement extends TextComponent with HasGameReference {
  // Store the alpha as a double so we don't have to "read" it from the style every frame
  double _opacity = 1.0;

  WaveAnnouncement({required String text})
      : super(
          text: text,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'PixelifySans'
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    position = game.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 1. Decrease our local opacity variable
    _opacity -= 0.5 * dt;

    if (_opacity > 0) {
      // 2. Cast textRenderer to TextPaint to access the style and apply new alpha
      if (textRenderer is TextPaint) {
        final currentStyle = (textRenderer as TextPaint).style;
        textRenderer = TextPaint(
          style: currentStyle.copyWith(
            color: Colors.cyanAccent.withValues(alpha: _opacity),
          ),
        );
      }
    } else {
      removeFromParent();
    }
  }
}