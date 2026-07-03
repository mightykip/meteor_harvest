import 'package:flame/components.dart';
import '../meteor_harvest_game.dart';

class EngineTrail extends SpriteComponent with HasGameReference<MeteorHarvestGame> {
  final double maxLife = 0.4; // 0.4 seconds lifetime
  double life = 0.4;
  final double initialScale;

  EngineTrail({
    required Vector2 position,
    required this.initialScale,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('particle_engine_cyan.png');
    size = Vector2(24, 24); // base size of engine trail particle
    scale = Vector2.all(initialScale);
  }

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    } else {
      // Fade out and shrink
      final progress = life / maxLife;
      opacity = progress;
      scale = Vector2.all(initialScale * progress);
    }
  }
}
