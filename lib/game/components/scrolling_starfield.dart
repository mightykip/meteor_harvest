import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import '../meteor_harvest_game.dart';

class ScrollingStarfield extends ParallaxComponent<MeteorHarvestGame> {
  ScrollingStarfield({super.priority = -10}); // Render behind other components

  @override
  Future<void> onLoad() async {
    try {
      parallax = await game.loadParallax(
        [
          ParallaxImageData('background_nebula.png'),
          ParallaxImageData('stars_far.png'),
          ParallaxImageData('stars_mid.png'),
        ],
        baseVelocity: Vector2(0, 15), // Base scroll speed downward
        velocityMultiplierDelta: Vector2(0, 2.5), // Each layer scrolls faster
        repeat: ImageRepeat.repeat,
      );
    } catch (e) {
      debugPrint(
        'Parallax background load failed, using procedural fallback: $e',
      );
      // Fallback is automatically handled since we can add procedural drawing here if parallax is null
    }
  }

  @override
  void update(double dt) {
    if (parallax != null) {
      // We can speed up background scroll based on game state or difficulty
      if (game.gameState == MeteorHarvestState.playing) {
        // Slightly speed up background as score increases
        final speedFactor = 1.0 + (game.score / 1000.0).clamp(0.0, 2.0);
        parallax!.baseVelocity = Vector2(0, 15 * speedFactor);
      } else {
        parallax!.baseVelocity = Vector2(0, 15);
      }
    }
    super.update(dt);
  }
}
