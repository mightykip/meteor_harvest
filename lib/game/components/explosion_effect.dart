import 'dart:math';
import 'package:flame/components.dart';
import '../meteor_harvest_game.dart';

class ExplosionEffect extends Component with HasGameReference<MeteorHarvestGame> {
  final Vector2 position;

  ExplosionEffect({required this.position});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final random = Random();
    
    // Spawn 16-24 orange explosion particles
    final particleCount = 16 + random.nextInt(9);
    for (int i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 80.0 + random.nextDouble() * 160.0;
      final velocity = Vector2(cos(angle), sin(angle)) * speed;
      final sizeVal = 20.0 + random.nextDouble() * 25.0;
      final maxLife = 0.5 + random.nextDouble() * 0.4;
      
      game.add(
        ExplosionParticle(
          position: position.clone(),
          velocity: velocity,
          size: Vector2.all(sizeVal),
          maxLife: maxLife,
        )..priority = 6,
      );
    }
  }
}

class ExplosionParticle extends SpriteComponent with HasGameReference<MeteorHarvestGame> {
  final Vector2 velocity;
  final double maxLife;
  double life;

  ExplosionParticle({
    required Vector2 position,
    required this.velocity,
    required Vector2 size,
    required this.maxLife,
  })  : life = maxLife,
        super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('particle_explosion.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    } else {
      // Move outwards
      position += velocity * dt;
      
      // Fade and shrink
      final progress = life / maxLife;
      opacity = progress;
      scale = Vector2.all(progress);
    }
  }
}
