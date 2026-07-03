import 'dart:math' as math;
import 'package:flame/components.dart';
import '../meteor_harvest_game.dart';
import '../components/crystal.dart';
import '../components/asteroid.dart';

class SpawnSystem extends Component with HasGameReference<MeteorHarvestGame> {
  // Spawning intervals
  double asteroidInterval = 1.5;
  double crystalInterval = 1.0;

  double _asteroidTimer = 0.0;
  double _crystalTimer = 0.0;

  final math.Random _rand = math.Random();

  // Track last spawn positions to prevent overlays or impossible walls
  double? _lastAsteroidX;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState != MeteorHarvestState.playing) return;

    // 1. Calculate difficulty scaling based on playTime
    _updateDifficulty(game.playTime);

    // 2. Spawn Asteroids
    _asteroidTimer += dt;
    if (_asteroidTimer >= asteroidInterval) {
      _asteroidTimer = 0.0;
      _spawnAsteroid();
    }

    // 3. Spawn Crystals
    _crystalTimer += dt;
    if (_crystalTimer >= crystalInterval) {
      _crystalTimer = 0.0;
      _spawnCrystal();
    }
  }

  void _updateDifficulty(double playTime) {
    // Escalate difficulty in stages:
    if (playTime < 10.0) {
      // Stage 1 (0-10s): Safe Intro
      asteroidInterval = 1.5;
    } else if (playTime < 20.0) {
      // Stage 2 (10-20s): Engaged
      asteroidInterval = 1.2;
    } else if (playTime < 40.0) {
      // Stage 3 (20-40s): Challenge
      asteroidInterval = 0.9;
    } else {
      // Stage 4 (40s+): Intensity
      asteroidInterval = 0.75;
    }

    // Slowly adjust crystal spawn rate slightly to keep pace
    crystalInterval = (1.0 - (playTime / 120.0)).clamp(0.65, 1.2);
  }

  void _spawnAsteroid() {
    if (!game.isMounted) return;

    // Determine type
    final roll = _rand.nextDouble();
    AsteroidSize size;
    if (roll < 0.50) {
      size = AsteroidSize.small; // 50%
    } else if (roll < 0.85) {
      size = AsteroidSize.medium; // 35%
    } else {
      size = AsteroidSize.large; // 15%
    }

    // Calculate random X position (leave safety padding on left/right)
    final padding = 40.0;
    double spawnX = padding + _rand.nextDouble() * (game.size.x - padding * 2);

    // Fairness rule: prevent consecutive asteroids from spawning directly on top of each other
    if (_lastAsteroidX != null) {
      final diff = (spawnX - _lastAsteroidX!).abs();
      if (diff < 80.0) {
        // Shift it away to preserve a passage lane
        spawnX = (spawnX + 120.0) % (game.size.x - padding * 2);
        if (spawnX < padding) spawnX += padding;
      }
    }
    _lastAsteroidX = spawnX;

    // Don't spawn right above player if they are static near spawn
    final playerX = game.player.position.x;
    if ((spawnX - playerX).abs() < 30.0 && _rand.nextDouble() < 0.6) {
      // Slight shift for fairness
      spawnX = (spawnX + 60.0) % (game.size.x - padding * 2);
      if (spawnX < padding) spawnX += padding;
    }

    // Create and add
    final asteroid = Asteroid(position: Vector2(spawnX, -50), sizeType: size);
    game.add(asteroid);
  }

  void _spawnCrystal() {
    if (!game.isMounted) return;

    // Determine type
    final roll = _rand.nextDouble();
    CrystalType type;
    if (roll < 0.70) {
      type = CrystalType.common; // 70%
    } else if (roll < 0.90) {
      type = CrystalType.rare; // 20%
    } else {
      type = CrystalType.legendary; // 10%
    }

    // Spawn X position
    final padding = 40.0;
    final spawnX = padding + _rand.nextDouble() * (game.size.x - padding * 2);

    // Spawn slightly above screen
    final crystal = Crystal(position: Vector2(spawnX, -40), type: type);
    game.add(crystal);
  }
}
