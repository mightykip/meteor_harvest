import 'package:flame/components.dart';
import '../meteor_harvest_game.dart';

class ScoreSystem extends Component with HasGameReference<MeteorHarvestGame> {
  double _survivalTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    
    if (game.gameState == MeteorHarvestState.playing) {
      _survivalTimer += dt;
      // Add +1 survival point every 1.0 seconds
      if (_survivalTimer >= 1.0) {
        _survivalTimer -= 1.0;
        game.score += 1;
      }
    }
  }
}
