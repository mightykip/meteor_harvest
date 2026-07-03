import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/foundation.dart';
import '../meteor_harvest_game.dart';
import 'player_ship.dart';

enum AsteroidSize { small, medium, large }

class Asteroid extends SpriteComponent
    with HasGameReference<MeteorHarvestGame>, CollisionCallbacks {
  final AsteroidSize sizeType;

  late double speed;
  late double rotationSpeed;
  late double horizontalDrift;
  double _dustTimer = 0.0;

  Asteroid({required Vector2 position, required this.sizeType})
    : super(anchor: Anchor.center, position: position, priority: 4) {
    // Determine size and physics based on type
    final rand = math.Random();
    switch (sizeType) {
      case AsteroidSize.small:
        size = Vector2.all(48);
        speed = 180.0 + rand.nextDouble() * 60.0; // 180 to 240
        rotationSpeed = 1.5 + rand.nextDouble() * 2.0;
        horizontalDrift = (rand.nextDouble() - 0.5) * 40.0; // -20 to 20
        break;
      case AsteroidSize.medium:
        size = Vector2.all(72);
        speed = 110.0 + rand.nextDouble() * 50.0; // 110 to 160
        rotationSpeed = 0.8 + rand.nextDouble() * 1.2;
        horizontalDrift = (rand.nextDouble() - 0.5) * 30.0; // -15 to 15
        break;
      case AsteroidSize.large:
        size = Vector2.all(96);
        speed = 60.0 + rand.nextDouble() * 40.0; // 60 to 100
        rotationSpeed = 0.3 + rand.nextDouble() * 0.7;
        horizontalDrift = (rand.nextDouble() - 0.5) * 20.0; // -10 to 10
        break;
    }
  }

  String get spriteName {
    switch (sizeType) {
      case AsteroidSize.small:
        return 'asteroid_small.png';
      case AsteroidSize.medium:
        return 'asteroid_medium.png';
      case AsteroidSize.large:
        return 'asteroid_large.png';
    }
  }

  double get collisionRadius {
    switch (sizeType) {
      case AsteroidSize.small:
        return 20.0;
      case AsteroidSize.medium:
        return 32.0;
      case AsteroidSize.large:
        return 42.0;
    }
  }

  @override
  Future<void> onLoad() async {
    // 1. Load sprite
    sprite = Sprite(game.images.fromCache(spriteName));

    // 2. Add circular collision hitbox
    add(
      CircleHitbox(
        radius: collisionRadius,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState != MeteorHarvestState.playing) return;

    // 1. Move downward
    position.y += speed * dt;

    // 2. Apply horizontal drift
    position.x += horizontalDrift * dt;

    // 3. Rotate
    angle += rotationSpeed * dt;

    // 4. Spawn trailing dust
    _dustTimer += dt;
    if (_dustTimer >= 0.15) {
      _dustTimer = 0.0;
      _spawnDustParticle();
    }

    // 5. Bounds clean up
    if (position.y > game.size.y + 100) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerShip) {
      _triggerCrash();
    }
  }

  void _triggerCrash() {
    // 1. Spawn explosion particles
    _spawnExplosion();

    // 2. Trigger screen shake
    _shakeCamera();

    // 3. End Game Run in main system
    game.endRun();

    // 4. Remove this asteroid
    removeFromParent();
  }

  void _spawnExplosion() {
    final rand = math.Random();
    // Spawn 15-20 particles
    final numParticles = 15 + rand.nextInt(10);
    for (int i = 0; i < numParticles; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 100.0 + rand.nextDouble() * 250.0;
      final velocity = Vector2(math.cos(angle), math.sin(angle))..scale(speed);

      game.add(
        AsteroidExplosionParticle(
          position: position.clone(),
          velocity: velocity,
        ),
      );
    }
  }

  void _shakeCamera() {
    // Standard camera shake by shaking the viewfinder position
    try {
      game.camera.viewfinder.add(
        MoveEffect.by(
          Vector2(6, 6),
          EffectController(duration: 0.05, alternate: true, repeatCount: 6),
        ),
      );
    } catch (e) {
      debugPrint('Camera shake failed: $e');
    }
  }

  void _spawnDustParticle() {
    final rand = math.Random();
    final spawnPos = position - (Vector2(0, size.y / 2 - 5)..rotate(angle));
    game.add(
      AsteroidExplosionParticle(
        position: spawnPos,
        velocity: Vector2((rand.nextDouble() - 0.5) * 35.0, speed * 0.4),
        sizeMultiplier: 0.35,
      ),
    );
  }
}

// Particle explosion component
class AsteroidExplosionParticle extends SpriteComponent
    with HasGameReference<MeteorHarvestGame> {
  final Vector2 velocity;
  final double initialLifespan = 0.8; // 800ms
  late double lifespan;
  late double rotSpeed;

  final double sizeMultiplier;

  AsteroidExplosionParticle({
    required Vector2 position,
    required this.velocity,
    this.sizeMultiplier = 1.0,
  }) : super(
         size: Vector2.all(24 * sizeMultiplier),
         anchor: Anchor.center,
         position: position,
         priority: 7, // In front of most game components
       ) {
    lifespan = initialLifespan;
    rotSpeed = (math.Random().nextDouble() - 0.5) * 8.0;
  }

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('particle_explosion.png'));
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
    velocity.scale(1.0 - (dt * 3.0));

    // Rotate
    angle += rotSpeed * dt;

    // Fade out and shrink
    final progress = lifespan / initialLifespan;
    opacity = progress.clamp(0.0, 1.0);
    size = Vector2.all(24 * sizeMultiplier * progress);
  }
}
