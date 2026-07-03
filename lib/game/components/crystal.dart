import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import '../meteor_harvest_game.dart';
import 'player_ship.dart';
import 'floating_score_text.dart';

class Crystal extends SpriteComponent with HasGameReference<MeteorHarvestGame>, CollisionCallbacks {
  final double speed;
  final double baseX;
  
  double _wobbleTime = 0;
  double _pulseTime = 0;

  bool _shaderLoaded = false;
  late FragmentShader _shader;

  Crystal({
    required Vector2 position,
    required this.speed,
  })  : baseX = position.x,
        super(position: position, size: Vector2(32, 32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load blue crystal sprite
    sprite = await game.loadSprite('crystal_blue.png');
    
    // Add circular hitbox (forgiving: radius 12, visual is 32x32)
    add(CircleHitbox(
      radius: 12,
      anchor: Anchor.center,
      position: Vector2(16, 16),
    ));

    // Attempt to load shader
    try {
      final program = await FragmentProgram.fromAsset('assets/shaders/crystal_shimmer.frag');
      _shader = program.fragmentShader();
      _shaderLoaded = true;
    } catch (e) {
      // Fallback silently if shaders are not supported
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Drift downward
    position.y += speed * dt;
    
    // Wobble horizontally (sinusoidal)
    _wobbleTime += dt;
    position.x = baseX + sin(_wobbleTime * 3.5) * 15;
    
    // Rotate slowly
    angle += 0.8 * dt;
    
    // Pulse scale (glow/breathing effect)
    _pulseTime += dt;
    scale = Vector2.all(1.0 + 0.12 * sin(_pulseTime * 5.0));

    // Remove if offscreen
    if (position.y > game.size.y + 40) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_shaderLoaded && sprite != null) {
      final recorder = PictureRecorder();
      final localCanvas = Canvas(recorder);

      _shader.setFloat(0, size.x);
      _shader.setFloat(1, size.y);
      _shader.setFloat(2, _pulseTime);
      _shader.setImageSampler(0, sprite!.image);

      final paint = Paint()..shader = _shader;
      localCanvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

      final picture = recorder.endRecording();
      canvas.save();
      canvas.translate(-size.x / 2, -size.y / 2);
      canvas.drawPicture(picture);
      canvas.restore();
      picture.dispose();
    } else {
      super.render(canvas);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is PlayerShip) {
      _collect();
    }
  }

  void _collect() {
    // 1. Add score
    game.score += 10;
    
    // Trigger player ship collection flash
    game.playerShip?.flash();
    
    // 2. Play chimes sound effect
    FlameAudio.play('sfx_crystal_collect.mp3');
    
    // 3. Spawn floating +10 text
    game.add(FloatingScoreText(
      text: '+10',
      position: position.clone(),
    )..priority = 6);
    
    // 4. Spawn sparkle burst particles
    final random = Random();
    for (int i = 0; i < 8; i++) {
      final angle = (i * (2 * pi / 8)) + (random.nextDouble() * 0.4 - 0.2);
      final velocity = Vector2(cos(angle), sin(angle)) * (80 + random.nextDouble() * 70);
      game.add(CrystalSparkle(
        position: position.clone(),
        velocity: velocity,
      )..priority = 6);
    }
    
    // 5. Remove itself
    removeFromParent();
  }
}

class CrystalSparkle extends SpriteComponent with HasGameReference<MeteorHarvestGame> {
  final Vector2 velocity;
  final double maxLife = 0.5;
  double life = 0.5;

  CrystalSparkle({
    required Vector2 position,
    required this.velocity,
  }) : super(
          position: position,
          size: Vector2(16, 16),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('particle_sparkle_blue.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    } else {
      // Move in random direction
      position += velocity * dt;
      // Fade and shrink
      final progress = life / maxLife;
      opacity = progress;
      scale = Vector2.all(progress);
    }
  }
}
