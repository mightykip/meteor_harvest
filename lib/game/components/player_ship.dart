import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../meteor_harvest_game.dart';

class PlayerShip extends SpriteComponent
    with
        HasGameReference<MeteorHarvestGame>,
        CollisionCallbacks,
        KeyboardHandler {
  PlayerShip()
    : super(size: Vector2.all(64), anchor: Anchor.center, priority: 5);

  // Movement physics
  final double maxSpeed = 400.0;
  final double tiltMaxAngle =
      0.20; // max banking angle in radians (approx 11 degrees)
  final double lerpSpeed = 12.0; // speed of touch follow easing

  Vector2 velocity = Vector2.zero();
  final Vector2 _lastPosition = Vector2.zero();

  // Particle trail timing
  double _trailTimer = 0.0;
  final double trailInterval = 0.04; // spawn trail every 40ms

  // Flame overlay sprite component
  late SpriteComponent _engineFlame;
  double _flashTimer = 0.0;

  void flash() {
    _flashTimer = 0.15; // 150ms flash duration
  }

  @override
  Future<void> onLoad() async {
    // 1. Load ship sprite
    sprite = Sprite(game.images.fromCache('ship_miner.png'));

    // 2. Add circular collision hitbox
    // Forgiving hitbox (radius 24 px on 64px sprite is approx 75% size)
    add(CircleHitbox(radius: 22, anchor: Anchor.center, position: size / 2));

    // 3. Add engine flame component
    _engineFlame = SpriteComponent(
      sprite: Sprite(game.images.fromCache('ship_engine_flame.png')),
      size: Vector2(24, 32),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, size.y - 4), // right behind the ship engine
      priority: -1, // draw behind ship
    );
    add(_engineFlame);

    _lastPosition.setFrom(position);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (game.gameState != MeteorHarvestState.playing) {
      return super.onKeyEvent(event, keysPressed);
    }

    // Clear drag target position if keyboard is used
    if (keysPressed.isNotEmpty) {
      game.targetPosition = null;
    }

    final isW =
        keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    final isS =
        keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);
    final isA =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isD =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    double dx = 0.0;
    double dy = 0.0;

    if (isA) dx = -1.0;
    if (isD) dx = 1.0;
    if (isW) dy = -1.0;
    if (isS) dy = 1.0;

    velocity.setValues(dx, dy);
    if (velocity.length > 0) {
      velocity.normalize();
      velocity.scale(maxSpeed);
    }

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
    if (game.gameState != MeteorHarvestState.playing) return;

    _lastPosition.setFrom(position);

    // 1. Process movement
    if (game.targetPosition != null) {
      // Easing touch follow movement
      final target = game.targetPosition!;

      // Interpolate position using exponential decay for fluid drag ease
      final t = (dt * lerpSpeed).clamp(0.0, 1.0);
      position.lerp(target, t);

      // Compute virtual velocity for tilt and engine particles
      velocity = (position - _lastPosition) / dt;
    } else {
      // Keyboard velocity movement
      position.add(velocity * dt);
    }

    // 2. Clamp ship inside screen bounds
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
    position.y = position.y.clamp(size.y / 2, game.size.y - size.y / 2);

    // 3. Bank / Tilt animation based on horizontal velocity
    final horizontalSpeedRatio = (velocity.x / maxSpeed).clamp(-1.0, 1.0);
    final targetAngle = horizontalSpeedRatio * tiltMaxAngle;

    // Smooth angle interpolation
    final angleDecay = (dt * 8.0).clamp(0.0, 1.0);
    angle = lerpDouble(angle, targetAngle, angleDecay) ?? angle;

    // 4. Engine Flame Flickering
    final scalePulse = 0.85 + (math.sin(game.playTime * 40.0) * 0.15);
    _engineFlame.scale = Vector2(1.0, scalePulse);

    // 5. Generate Engine Trail Particles
    _trailTimer += dt;
    if (_trailTimer >= trailInterval) {
      _trailTimer = 0.0;
      _spawnTrailParticle();
    }
  }

  void _spawnTrailParticle() {
    // Generate trail particle behind the ship
    final trailPart = EngineTrailParticle(
      position: position - (Vector2(0, size.y / 2 - 10)..rotate(angle)),
      angle: angle,
    );
    game.add(trailPart);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    // Gentle idle bobbing (visual translation only, keeps hitbox at physics center)
    final bobY = math.sin(game.playTime * 4.0) * 2.5;
    canvas.translate(0, bobY);

    if (_flashTimer > 0) {
      // Draw with white tint mask for collection flash
      final flashPaint = Paint()
        ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
      final originalPaint = paint;
      paint = flashPaint;
      super.render(canvas);
      paint = originalPaint;
    } else {
      super.render(canvas);
    }

    canvas.restore();
  }
}

// Separate helper component for the engine trail particle
class EngineTrailParticle extends SpriteComponent
    with HasGameReference<MeteorHarvestGame> {
  final double initialLifespan = 0.4; // 400ms lifespan
  late double lifespan;

  EngineTrailParticle({required Vector2 position, required double angle})
    : super(
        size: Vector2.all(16),
        anchor: Anchor.center,
        position: position,
        angle: angle,
        priority: 1, // behind players but in front of background
      ) {
    lifespan = initialLifespan;
  }

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('particle_engine_cyan.png'));
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifespan -= dt;

    if (lifespan <= 0) {
      removeFromParent();
      return;
    }

    // Move particle slightly downwards / backwards relative to space scroll
    position.y += dt * 100;

    // Fade out and shrink particle
    final progress = lifespan / initialLifespan;
    opacity = progress.clamp(0.0, 1.0);
    size = Vector2.all(16 * progress);
  }
}
