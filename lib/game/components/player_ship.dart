import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../meteor_harvest_game.dart';
import 'engine_trail.dart';

class PlayerShip extends SpriteComponent with HasGameReference<MeteorHarvestGame>, KeyboardHandler {
  Vector2 velocity = Vector2.zero();
  
  final double maxSpeed = 380.0;
  final double acceleration = 1500.0;
  final double deceleration = 1200.0;
  final double maxTiltAngle = 0.25; // ~14 degrees of tilt
  
  late SpriteComponent _engineFlame;
  double _flameTime = 0;
  
  double _trailTimer = 0;
  static const double _trailInterval = 0.04; // spawn trail particle every 0.04s

  final Vector2 _keyboardDirection = Vector2.zero();

  bool _isFlashing = false;
  double _flashTimer = 0;
  static const double _flashDuration = 0.15;

  void flash() {
    _isFlashing = true;
    _flashTimer = _flashDuration;
    paint.colorFilter = const ColorFilter.mode(Colors.cyanAccent, BlendMode.srcATop);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load main ship sprite
    sprite = await game.loadSprite('ship_miner.png');
    size = Vector2(64, 64);
    anchor = Anchor.center;
    
    // Start position near bottom center
    position = Vector2(game.size.x / 2, game.size.y - 120);

    // Add circular hitbox (forgiving, radius 22)
    add(CircleHitbox(
      radius: 22, 
      anchor: Anchor.center, 
      position: Vector2(32, 32),
    ));

    // Add pulsing engine flame sprite behind ship
    final flameSprite = await game.loadSprite('ship_engine_flame.png');
    _engineFlame = SpriteComponent(
      sprite: flameSprite,
      size: Vector2(32, 32),
      anchor: Anchor.topCenter,
      position: Vector2(32, 58), // sits at engine exhaust nozzle
      priority: -1,
    );
    add(_engineFlame);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isFlashing) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _isFlashing = false;
        paint.colorFilter = null;
      }
    }

    // Calculate target velocity
    Vector2 targetVelocity = Vector2.zero();

    if (_keyboardDirection.length2 > 0) {
      targetVelocity = _keyboardDirection * maxSpeed;
    } else if (game.targetPosition != null) {
      final toTarget = game.targetPosition! - position;
      final distance = toTarget.length;
      
      if (distance > 6) {
        final dir = toTarget.normalized();
        // Ease-in velocity when close to target to prevent jittering
        final speedFactor = (distance / 60).clamp(0.0, 1.0);
        targetVelocity = dir * (maxSpeed * speedFactor);
      }
    }

    // Apply acceleration or deceleration
    if (targetVelocity.length2 > 0) {
      final toTargetVelocity = targetVelocity - velocity;
      final accelStep = acceleration * dt;
      if (toTargetVelocity.length <= accelStep) {
        velocity = targetVelocity;
      } else {
        velocity += toTargetVelocity.normalized() * accelStep;
      }
    } else {
      final decelStep = deceleration * dt;
      if (velocity.length <= decelStep) {
        velocity.setZero();
      } else {
        velocity -= velocity.normalized() * decelStep;
      }
    }

    // Move ship
    position += velocity * dt;

    // Keep ship inside bounds
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
    position.x = position.x.clamp(halfWidth, game.size.x - halfWidth);
    position.y = position.y.clamp(halfHeight, game.size.y - halfHeight);

    // Apply horizontal tilting
    final tiltTarget = (velocity.x / maxSpeed) * maxTiltAngle;
    angle = angle + (tiltTarget - angle) * 0.15; // smooth interpolation

    // Pulse engine flame
    _flameTime += dt;
    _engineFlame.scale = Vector2.all(0.95 + 0.15 * sin(_flameTime * 25));

    // Spawn engine trail particles
    if (velocity.length > 20) {
      _trailTimer += dt;
      if (_trailTimer >= _trailInterval) {
        _trailTimer = 0;
        final trailOffset = Vector2(0, 26)..rotate(angle);
        game.add(EngineTrail(
          position: position + trailOffset,
          initialScale: 0.7 + Random().nextDouble() * 0.4,
        )..priority = 4); // layer trail just under ship (priority 5)
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardDirection.setZero();
    
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _keyboardDirection.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _keyboardDirection.x += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _keyboardDirection.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) {
      _keyboardDirection.y += 1;
    }
    
    if (_keyboardDirection.length2 > 0) {
      _keyboardDirection.normalize();
    }
    
    return true;
  }
}
