import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../meteor_harvest_game.dart';

class NebulaBackgroundComponent extends PositionComponent with HasGameReference<MeteorHarvestGame> {
  bool _shaderLoaded = false;
  late FragmentShader _shader;
  double _time = 0;

  NebulaBackgroundComponent() : super(priority: -15); // render furthest back

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = game.size;
    try {
      final program = await FragmentProgram.fromAsset('assets/shaders/nebula.frag');
      _shader = program.fragmentShader();
      _shaderLoaded = true;
    } catch (e) {
      debugPrint('NebulaShader: Failed to load: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shaderLoaded) {
      _time += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_shaderLoaded) {
      final recorder = PictureRecorder();
      final localCanvas = Canvas(recorder);

      _shader.setFloat(0, size.x);
      _shader.setFloat(1, size.y);
      _shader.setFloat(2, _time);

      final paint = Paint()..shader = _shader;
      localCanvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

      final picture = recorder.endRecording();
      canvas.drawPicture(picture);
      picture.dispose();
    }
  }
}
