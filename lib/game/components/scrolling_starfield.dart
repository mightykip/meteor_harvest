import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import '../meteor_harvest_game.dart';

class ScrollingStarfield extends PositionComponent with HasGameReference<MeteorHarvestGame> {
  bool _useProcedural = false;
  
  // Procedural stars data
  final List<ProceduralStar> _stars = [];
  final Random _random = Random();
  static const int _starCount = 120;

  bool _warpShaderLoaded = false;
  late FragmentShader _warpShader;
  double _warpTime = 0;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Set initial size to match game
    size = game.size;

    try {
      final parallax = await game.loadParallaxComponent(
        [
          ParallaxImageData('background_nebula.png'),
          ParallaxImageData('stars_far.png'),
          ParallaxImageData('stars_mid.png'),
        ],
        baseVelocity: Vector2(0, 15),
        velocityMultiplierDelta: Vector2(0, 1.6),
        repeat: ImageRepeat.repeat,
      );
      add(parallax);
    } catch (e) {
      debugPrint('ScrollingStarfield: Failed to load parallax assets, using procedural fallback. Error: $e');
      _useProcedural = true;
      _initProceduralStars();
    }

    // Attempt to load the warp speed shader
    try {
      final program = await FragmentProgram.fromAsset('assets/shaders/warp_stars.frag');
      _warpShader = program.fragmentShader();
      _warpShaderLoaded = true;
    } catch (e) {
      // Fallback silently if shaders are unsupported
    }
  }

  void _initProceduralStars() {
    _stars.clear();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(
        ProceduralStar(
          position: Vector2(_random.nextDouble() * size.x, _random.nextDouble() * size.y),
          speed: 15 + _random.nextDouble() * 95, // varying speeds for parallax effect
          size: 0.8 + _random.nextDouble() * 2.2,
          opacity: 0.3 + _random.nextDouble() * 0.7,
        ),
      );
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    if (_useProcedural) {
      _initProceduralStars();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_useProcedural) {
      for (final star in _stars) {
        star.position.y += star.speed * dt;
        if (star.position.y > size.y) {
          star.position.y = 0;
          star.position.x = _random.nextDouble() * size.x;
        }
      }
    }

    if (_warpShaderLoaded && game.gameState == MeteorHarvestState.playing) {
      _warpTime += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_useProcedural) {
      // Paint dark space background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFF070B19),
      );
      
      // Draw procedural stars
      final starPaint = Paint();
      for (final star in _stars) {
        starPaint.color = Colors.white.withValues(alpha: star.opacity);
        canvas.drawCircle(
          Offset(star.position.x, star.position.y),
          star.size,
          starPaint,
        );
      }
    }

    // Render warp stars shader overlay if active and difficulty is above level 0
    if (_warpShaderLoaded && game.gameState == MeteorHarvestState.playing && game.difficultySystem != null) {
      final level = game.difficultySystem!.level;
      if (level > 0) {
        final speed = level * 0.35; // speed scales with difficulty tier
        final recorder = PictureRecorder();
        final localCanvas = Canvas(recorder);

        _warpShader.setFloat(0, size.x);
        _warpShader.setFloat(1, size.y);
        _warpShader.setFloat(2, _warpTime);
        _warpShader.setFloat(3, speed);

        final paint = Paint()..shader = _warpShader;
        localCanvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

        final picture = recorder.endRecording();
        canvas.drawPicture(picture);
        picture.dispose();
      }
    }
  }
}

class ProceduralStar {
  Vector2 position;
  double speed;
  double size;
  double opacity;

  ProceduralStar({
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}
