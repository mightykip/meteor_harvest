import 'dart:math';
import 'package:flame/components.dart';
import '../meteor_harvest_game.dart';
import '../components/crystal.dart';
import '../components/asteroid.dart';
import 'difficulty_system.dart';

class SpawnSystem extends Component with HasGameReference<MeteorHarvestGame> {
  final DifficultySystem difficultySystem;
  final Random _random = Random();

  double _crystalTimer = 0;
  double _asteroidTimer = 0;
  
  double _lastAsteroidX = -999;
  double _lastAsteroidTime = 0;

  SpawnSystem({required this.difficultySystem});

  @override
  void update(double dt) {
    super.update(dt);

    if (game.gameState != MeteorHarvestState.playing) return;

    final elapsed = difficultySystem.timeElapsed;

    // 1. Spawn crystals
    _crystalTimer += dt;
    final nextCrystalSpawn = 0.8 + _random.nextDouble() * 0.4; // 0.8s to 1.2s
    if (_crystalTimer >= nextCrystalSpawn) {
      _crystalTimer = 0;
      _spawnCrystal();
    }

    // 2. Spawn asteroids
    _asteroidTimer += dt;
    final asteroidSpawnInterval = difficultySystem.asteroidSpawnInterval;
    if (_asteroidTimer >= asteroidSpawnInterval) {
      _asteroidTimer = 0;
      _spawnAsteroid(elapsed);
    }
  }

  void _spawnCrystal() {
    final xPos = 30 + _random.nextDouble() * (game.size.x - 60);
    final speed = 120.0 + _random.nextDouble() * 55.0; // 120 to 175 px/s
    game.add(Crystal(
      position: Vector2(xPos, -40),
      speed: speed,
    )..priority = 4);
  }

  void _spawnAsteroid(double elapsed) {
    double xPos = 40 + _random.nextDouble() * (game.size.x - 80);
    
    // Fairness check: if spawned recently, ensure new asteroid is at least 140px away horizontally
    if (elapsed - _lastAsteroidTime < 0.4) {
      if ((xPos - _lastAsteroidX).abs() < 140) {
        if (xPos < game.size.x / 2) {
          xPos += 140;
        } else {
          xPos -= 140;
        }
      }
    }
    
    _lastAsteroidX = xPos;
    _lastAsteroidTime = elapsed;

    // Determine type based on difficulty distribution
    final dist = difficultySystem.typeDistribution;
    final randVal = _random.nextDouble();
    AsteroidType type;
    if (randVal < dist[0]) {
      type = AsteroidType.small;
    } else if (randVal < dist[0] + dist[1]) {
      type = AsteroidType.medium;
    } else {
      type = AsteroidType.large;
    }

    // Speeds
    final minSpeed = difficultySystem.asteroidMinSpeed;
    final maxSpeed = difficultySystem.asteroidMaxSpeed;
    final speed = minSpeed + _random.nextDouble() * (maxSpeed - minSpeed);
    
    // Drift
    final driftSpeed = (_random.nextDouble() * 2 - 1) * 35.0; // horizontal drift speed
    
    // Rotation speed
    final rotationSpeed = (0.5 + _random.nextDouble() * 1.5) * (_random.nextBool() ? 1 : -1);

    game.add(Asteroid(
      position: Vector2(xPos, -60),
      type: type,
      speed: speed,
      driftSpeed: driftSpeed,
      rotationSpeed: rotationSpeed,
    )..priority = 4);
  }
}
