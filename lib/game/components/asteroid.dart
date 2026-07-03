import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import '../meteor_harvest_game.dart';
import 'player_ship.dart';
import 'explosion_effect.dart';
import 'screen_shaker.dart';
import '../shaders/shockwave_component.dart';

enum AsteroidType {
  small,
  medium,
  large,
}

class Asteroid extends SpriteComponent with HasGameReference<MeteorHarvestGame>, CollisionCallbacks {
  final AsteroidType type;
  final double speed;
  final double driftSpeed;
  final double rotationSpeed;

  Asteroid({
    required Vector2 position,
    required this.type,
    required this.speed,
    required this.driftSpeed,
    required this.rotationSpeed,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    double visualSize;
    double collisionRadius;
    String spriteFile;

    switch (type) {
      case AsteroidType.small:
        visualSize = 48;
        collisionRadius = 18;
        spriteFile = 'asteroid_small.png';
        break;
      case AsteroidType.medium:
        visualSize = 72;
        collisionRadius = 30;
        spriteFile = 'asteroid_medium.png';
        break;
      case AsteroidType.large:
        visualSize = 96;
        collisionRadius = 40;
        spriteFile = 'asteroid_large.png';
        break;
    }

    size = Vector2.all(visualSize);
    sprite = await game.loadSprite(spriteFile);

    // Add a circular hitbox smaller than visual size for fairness (forgiving hitboxes)
    add(CircleHitbox(
      radius: collisionRadius,
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Drift downward and slightly horizontally
    position.y += speed * dt;
    position.x += driftSpeed * dt;

    // Spin continuously
    angle += rotationSpeed * dt;

    // Auto-remove when it leaves the bottom of the screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerShip) {
      _crash(other.position);
    }
  }

  void _crash(Vector2 shipPosition) {
    // 1. Play explosion audio
    FlameAudio.play('sfx_explosion.mp3');

    // 2. Spawn explosion particle effect at the crash site
    game.add(ExplosionEffect(position: shipPosition));

    // 3. Trigger viewport screen shake
    game.add(ScreenShaker(duration: 0.45, intensity: 10));

    // Spawn impact shockwave ripple shader
    game.add(ShockwaveComponent(shockwaveCenter: shipPosition));

    // 4. Trigger game over state transitions
    game.endGame();
  }
}
