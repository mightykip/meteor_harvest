import 'package:flame/components.dart';
import '../meteor_harvest_game.dart';

class DifficultySystem extends Component with HasGameReference<MeteorHarvestGame> {
  double timeElapsed = 0;
  int level = 0;

  double get asteroidSpawnInterval {
    if (level == 0) return 1.5;
    if (level == 1) return 1.2;
    if (level == 2) return 0.9;
    return 0.7;
  }

  double get asteroidMinSpeed {
    if (level == 0) return 100.0;
    if (level == 1) return 140.0;
    if (level == 2) return 180.0;
    return 220.0;
  }

  double get asteroidMaxSpeed {
    if (level == 0) return 140.0;
    if (level == 1) return 180.0;
    if (level == 2) return 240.0;
    return 320.0;
  }

  // Probabilities for small, medium, large asteroids
  List<double> get typeDistribution {
    if (level == 0) return [0.85, 0.15, 0.00]; // 85% small, 15% medium
    if (level == 1) return [0.60, 0.30, 0.10]; // 60% small, 30% medium, 10% large
    if (level == 2) return [0.45, 0.35, 0.20]; // 45% small, 35% medium, 20% large
    return [0.30, 0.40, 0.30];                 // 30% small, 40% medium, 30% large
  }

  void reset() {
    timeElapsed = 0;
    level = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState == MeteorHarvestState.playing) {
      timeElapsed += dt;
      // Increase difficulty level every 10 seconds, max level 3
      level = (timeElapsed / 10).floor().clamp(0, 3);
    }
  }
}
