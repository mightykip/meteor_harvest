import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../meteor_harvest_game.dart';

class NebulaShaderComponent extends PositionComponent
    with HasGameReference<MeteorHarvestGame> {
  FragmentShader? _shader;
  double _time = 0.0;

  NebulaShaderComponent({super.priority = -9}) {
    // Place right above ScrollingStarfield (-10)
    // Make it cover the full game size
    size = Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size.setFrom(game.size);

    // Load fragment shader program
    try {
      final program = await FragmentProgram.fromAsset(
        'assets/shaders/nebula.frag',
      );
      _shader = program.fragmentShader();
    } catch (e) {
      debugPrint('Fragment shader compilation/load failed: $e');
      // Graceful fallback: _shader stays null, and we render nothing (showing the fallback image starfield)
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size.setFrom(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (_shader == null) return;

    // Pass uSize (vec2) uniform
    _shader!.setFloat(0, size.x);
    _shader!.setFloat(1, size.y);

    // Pass uTime (float) uniform
    _shader!.setFloat(2, _time);

    final Paint paint = Paint()..shader = _shader;

    // Fill the screen
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }
}
