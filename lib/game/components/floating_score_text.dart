import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FloatingScoreText extends PositionComponent {
  final String text;
  final double duration = 0.7; // 0.7 seconds duration
  double _life = 0.7;
  
  late TextComponent _textComponent;

  FloatingScoreText({
    required this.text,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.cyan,
              blurRadius: 10,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
    } else {
      // Float up slowly
      position.y -= 50 * dt;
      
      // Fade out opacity smoothly
      final progress = _life / duration;
      _textComponent.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.cyanAccent.withValues(alpha: progress),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.cyan.withValues(alpha: progress),
              blurRadius: 10,
            ),
          ],
        ),
      );
    }
  }
}
