import 'package:flutter/foundation.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/scrolling_starfield.dart';
import 'components/player_ship.dart';
import 'components/crystal.dart';
import 'components/asteroid.dart';
import 'components/engine_trail.dart';
import 'components/explosion_effect.dart';
import 'systems/difficulty_system.dart';
import 'systems/spawn_system.dart';
import 'systems/score_system.dart';
import 'shaders/nebula_background_component.dart';

enum MeteorHarvestState {
  title,
  playing,
  gameOver,
  paused,
}

class MeteorHarvestGame extends FlameGame with DragCallbacks, TapCallbacks, HasKeyboardHandlerComponents, HasCollisionDetection {
  MeteorHarvestState gameState = MeteorHarvestState.title;
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> bestScoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier<bool>(false);

  int get score => scoreNotifier.value;
  set score(int value) => scoreNotifier.value = value;

  int get bestScore => bestScoreNotifier.value;
  set bestScore(int value) => bestScoreNotifier.value = value;
  
  late SharedPreferences _prefs;
  
  Vector2? targetPosition;
  PlayerShip? playerShip;

  DifficultySystem? difficultySystem;
  SpawnSystem? spawnSystem;
  ScoreSystem? scoreSystem;

  bool isNewBest = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Initialize shared preferences for high scores
    _prefs = await SharedPreferences.getInstance();
    bestScore = _prefs.getInt('best_score') ?? 0;

    // Pre-cache audio assets
    await FlameAudio.audioCache.load('sfx_crystal_collect.mp3');
    await FlameAudio.audioCache.load('sfx_explosion.mp3');
    await FlameAudio.audioCache.load('sfx_new_best.mp3');

    // Add dynamic nebula clouds background shader
    await add(NebulaBackgroundComponent());

    // Add parallax scrolling starfield background
    await add(ScrollingStarfield()..priority = -10);
  }

  void _clearGameplayEntities() {
    // Collect all components to remove to avoid concurrent modification issues
    final toRemove = children.where((c) =>
        c is Crystal ||
        c is Asteroid ||
        c is EngineTrail ||
        c is CrystalSparkle ||
        c is ExplosionParticle ||
        c is ExplosionEffect
    ).toList();
    
    for (final component in toRemove) {
      component.removeFromParent();
    }
  }

  void startRun() {
    gameState = MeteorHarvestState.playing;
    score = 0;
    isPausedNotifier.value = false;
    targetPosition = null;
    isNewBest = false;

    // Clear any board debris
    _clearGameplayEntities();
    
    // Spawn player ship
    playerShip = PlayerShip()..priority = 5;
    add(playerShip!);

    // Start systems
    difficultySystem = DifficultySystem();
    spawnSystem = SpawnSystem(difficultySystem: difficultySystem!);
    scoreSystem = ScoreSystem();
    
    add(difficultySystem!);
    add(spawnSystem!);
    add(scoreSystem!);
    
    // Manage overlays
    overlays.remove('title');
    overlays.add('hud');
  }

  void endGame() {
    gameState = MeteorHarvestState.gameOver;
    isPausedNotifier.value = false;
    targetPosition = null;
    
    // Stop systems
    if (spawnSystem != null) {
      spawnSystem!.removeFromParent();
      spawnSystem = null;
    }
    if (difficultySystem != null) {
      difficultySystem!.removeFromParent();
      difficultySystem = null;
    }
    if (scoreSystem != null) {
      scoreSystem!.removeFromParent();
      scoreSystem = null;
    }

    // Remove player ship
    if (playerShip != null) {
      playerShip!.removeFromParent();
      playerShip = null;
    }
    
    // Save best score if current score exceeds it
    if (score > bestScore) {
      isNewBest = true;
      bestScore = score;
      _prefs.setInt('best_score', bestScore);
      FlameAudio.play('sfx_new_best.mp3');
    } else {
      isNewBest = false;
    }
    
    // Manage overlays
    overlays.remove('hud');
    overlays.add('gameOver');
  }

  void restartRun() {
    gameState = MeteorHarvestState.playing;
    score = 0;
    isPausedNotifier.value = false;
    targetPosition = null;
    isNewBest = false;
    if (paused) {
      resumeEngine();
    }

    // Clear all components
    _clearGameplayEntities();

    // Clean up old systems just in case
    if (spawnSystem != null) spawnSystem!.removeFromParent();
    if (difficultySystem != null) difficultySystem!.removeFromParent();
    if (scoreSystem != null) scoreSystem!.removeFromParent();

    // Recreate systems
    difficultySystem = DifficultySystem();
    spawnSystem = SpawnSystem(difficultySystem: difficultySystem!);
    scoreSystem = ScoreSystem();
    
    add(difficultySystem!);
    add(spawnSystem!);
    add(scoreSystem!);
    
    // Spawn new player ship
    playerShip = PlayerShip()..priority = 5;
    add(playerShip!);
    
    // Manage overlays
    overlays.remove('gameOver');
    overlays.add('hud');
  }

  void returnToMenu() {
    gameState = MeteorHarvestState.title;
    isPausedNotifier.value = false;
    targetPosition = null;
    isNewBest = false;
    if (paused) {
      resumeEngine();
    }

    // Clear board and stop systems
    _clearGameplayEntities();
    if (spawnSystem != null) {
      spawnSystem!.removeFromParent();
      spawnSystem = null;
    }
    if (difficultySystem != null) {
      difficultySystem!.removeFromParent();
      difficultySystem = null;
    }
    if (scoreSystem != null) {
      scoreSystem!.removeFromParent();
      scoreSystem = null;
    }

    // Remove ship
    if (playerShip != null) {
      playerShip!.removeFromParent();
      playerShip = null;
    }
    
    // Manage overlays
    overlays.remove('gameOver');
    overlays.add('title');
  }

  void togglePause() {
    if (gameState == MeteorHarvestState.playing) {
      gameState = MeteorHarvestState.paused;
      isPausedNotifier.value = true;
      pauseEngine();
    } else if (gameState == MeteorHarvestState.paused) {
      gameState = MeteorHarvestState.playing;
      isPausedNotifier.value = false;
      resumeEngine();
    }
  }

  // Pointer input event overrides
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (gameState == MeteorHarvestState.playing) {
      targetPosition = event.localPosition;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (gameState == MeteorHarvestState.playing) {
      targetPosition = event.localEndPosition;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    targetPosition = null;
  }
}
