import 'dart:math';
import 'package:flame/components.dart';
import '../meteor_harvest_game.dart';

class ScreenShaker extends Component with HasGameReference<MeteorHarvestGame> {
  final double duration;
  final double intensity;
  double _timer = 0;

  ScreenShaker({
    this.duration = 0.4,
    this.intensity = 8.0,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= duration) {
      // Reset viewfinder offset
      game.camera.viewfinder.position.setZero();
      removeFromParent();
    } else {
      // Calculate random shake displacement
      final random = Random();
      final dx = (random.nextDouble() * 2 - 1) * intensity;
      final dy = (random.nextDouble() * 2 - 1) * intensity;
      game.camera.viewfinder.position.setValues(dx, dy);
    }
  }
}
