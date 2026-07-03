import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../meteor_harvest_game.dart';

class ShockwaveComponent extends PositionComponent with HasGameReference<MeteorHarvestGame> {
  final Vector2 shockwaveCenter;
  double _time = 0;
  bool _shaderLoaded = false;
  late FragmentShader _shader;
  Sprite? _nebulaSprite;

  ShockwaveComponent({required this.shockwaveCenter}) : super(priority: -5); // render just above starfield background

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = game.size;
    try {
      final program = await FragmentProgram.fromAsset('assets/shaders/shockwave.frag');
      _shader = program.fragmentShader();
      _nebulaSprite = await game.loadSprite('background_nebula.png');
      _shaderLoaded = true;
    } catch (e) {
      debugPrint('ShockwaveShader: Failed to load: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shaderLoaded) {
      _time += dt;
      if (_time >= 0.75) {
        removeFromParent();
      }
    } else {
      removeFromParent(); // remove immediately if shader not loaded
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_shaderLoaded && _nebulaSprite != null) {
      // Draw using PictureRecorder to align Coordinates to local viewport space
      final recorder = PictureRecorder();
      final localCanvas = Canvas(recorder);

      _shader.setFloat(0, size.x);
      _shader.setFloat(1, size.y);
      _shader.setFloat(2, shockwaveCenter.x);
      _shader.setFloat(3, shockwaveCenter.y);
      _shader.setFloat(4, _time);
      _shader.setImageSampler(0, _nebulaSprite!.image);

      final paint = Paint()..shader = _shader;
      localCanvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

      final picture = recorder.endRecording();
      canvas.drawPicture(picture);
      picture.dispose();
    }
  }
}
