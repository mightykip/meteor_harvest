import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FloatingText extends TextComponent {
  final double initialLifespan = 0.8; // 800ms
  late double lifespan;
  final double speed = 60.0; // speed moving upwards

  FloatingText({
    required String text,
    required Vector2 position,
    Color color = AppTheme.cyanGlow,
  }) : super(
         text: text,
         position: position,
         anchor: Anchor.center,
         priority: 8, // Draw above normal components
       ) {
    lifespan = initialLifespan;

    // Style the text paint
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: color,
        shadows: const [
          Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(1, 1)),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifespan -= dt;

    if (lifespan <= 0) {
      removeFromParent();
      return;
    }

    // Move upwards
    position.y -= speed * dt;

    // Fade out
    final progress = lifespan / initialLifespan;
    // Note: TextPaint opacity can be adjusted by changing color opacity
    if (textRenderer is TextPaint) {
      final currentStyle = (textRenderer as TextPaint).style;
      textRenderer = TextPaint(
        style: currentStyle.copyWith(
          color: currentStyle.color?.withValues(
            alpha: progress.clamp(0.0, 1.0),
          ),
        ),
      );
    }
  }
}
