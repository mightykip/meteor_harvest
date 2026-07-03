import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../meteor_harvest_game.dart';
import 'player_ship.dart';
import 'floating_text.dart';

enum CrystalType { common, rare, legendary }

class Crystal extends SpriteComponent
    with HasGameReference<MeteorHarvestGame>, CollisionCallbacks {
  final CrystalType type;

  // Physics parameters
  final double speed = 120.0;
  final double rotationSpeed = 1.2;
  final double wobbleSpeed = 2.5;
  final double wobbleAmplitude = 18.0;

  late double _spawnX;
  double _wobbleTimer = 0.0;

  Crystal({required Vector2 position, required this.type})
    : super(
        size: Vector2.all(32), // visually 32x32
        anchor: Anchor.center,
        position: position,
        priority: 3,
      );

  int get points {
    switch (type) {
      case CrystalType.common:
        return 10;
      case CrystalType.rare:
        return 50;
      case CrystalType.legendary:
        return 100;
    }
  }

  Color get textColor {
    switch (type) {
      case CrystalType.common:
        return Colors.cyanAccent;
      case CrystalType.rare:
        return Colors.purpleAccent;
      case CrystalType.legendary:
        return Colors.amberAccent;
    }
  }

  String get spriteName {
    switch (type) {
      case CrystalType.common:
        return 'crystal_blue.png';
      case CrystalType.rare:
        return 'crystal_purple.png';
      case CrystalType.legendary:
        return 'crystal_gold.png';
    }
  }

  @override
  Future<void> onLoad() async {
    // 1. Set sprite
    sprite = Sprite(game.images.fromCache(spriteName));

    // 2. Spawn X reference for sinusoidal wobble
    _spawnX = position.x;

    // 3. Add collision hitbox
    add(CircleHitbox(radius: 12, anchor: Anchor.center, position: size / 2));

    // Randomize initial wobble phase
    _wobbleTimer = math.Random().nextDouble() * 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState != MeteorHarvestState.playing) return;

    // 1. Move downward
    position.y += speed * dt;

    // 2. Sinusoidal horizontal wobble
    _wobbleTimer += dt;
    position.x =
        _spawnX + math.sin(_wobbleTimer * wobbleSpeed) * wobbleAmplitude;

    // 3. Constant slow rotation
    angle += rotationSpeed * dt;

    // 4. Subtle scale pulsation
    final pulse = 1.0 + (math.sin(_wobbleTimer * 6.0) * 0.08);
    scale = Vector2.all(pulse);

    // 5. Bounds clean up
    if (position.y > game.size.y + 50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw soft glowing aura behind crystal sprite
    final glowPaint = Paint()
      ..color = textColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.45, glowPaint);

    super.render(canvas);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerShip) {
      _collect();
    }
  }

  void _collect() {
    // Flash player ship
    game.player.flash();

    // Trigger screen bump for rare/legendary collectables
    if (type == CrystalType.rare || type == CrystalType.legendary) {
      try {
        game.camera.viewfinder.add(
          MoveEffect.by(
            Vector2(3, 3),
            EffectController(duration: 0.04, alternate: true, repeatCount: 2),
          ),
        );
      } catch (e) {
        // Safe fallback
      }
    }

    // Add score
    game.addScore(points);

    // Play sound
    final sfx = type == CrystalType.legendary
        ? 'sfx_rare_collect.mp3'
        : 'sfx_crystal_collect.mp3';
    game.playSfx(sfx);

    // 3. Floating Score Text
    game.add(
      FloatingText(
        text: '+$points',
        position: position.clone(),
        color: textColor,
      ),
    );

    // 4. Sparkle Particle Burst
    _spawnSparkleBurst();

    // 5. Remove
    removeFromParent();
  }

  void _spawnSparkleBurst() {
    final rand = math.Random();
    for (int i = 0; i < 8; i++) {
      // Random direction
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 80.0 + rand.nextDouble() * 120.0;
      final velocity = Vector2(math.cos(angle), math.sin(angle))..scale(speed);

      game.add(
        CrystalSparkleParticle(position: position.clone(), velocity: velocity),
      );
    }
  }
}

// Sparkle Particle Component
class CrystalSparkleParticle extends SpriteComponent
    with HasGameReference<MeteorHarvestGame> {
  final Vector2 velocity;
  final double initialLifespan = 0.5; // 500ms
  late double lifespan;

  CrystalSparkleParticle({required Vector2 position, required this.velocity})
    : super(
        size: Vector2.all(12),
        anchor: Anchor.center,
        position: position,
        priority: 6,
      ) {
    lifespan = initialLifespan;
  }

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('particle_sparkle_blue.png'));
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifespan -= dt;

    if (lifespan <= 0) {
      removeFromParent();
      return;
    }

    // Move
    position.add(velocity * dt);

    // Slow down (friction)
    velocity.scale(1.0 - (dt * 4.0));

    // Fade out and shrink
    final progress = lifespan / initialLifespan;
    opacity = progress.clamp(0.0, 1.0);
    size = Vector2.all(12 * progress);
  }
}
