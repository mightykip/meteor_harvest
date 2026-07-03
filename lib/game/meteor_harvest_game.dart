import 'package:flutter/foundation.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/scrolling_starfield.dart';
import 'components/player_ship.dart';
import 'systems/spawn_system.dart';
import 'shaders/nebula_shader_component.dart';

enum MeteorHarvestState { title, playing, gameOver, paused }

class MeteorHarvestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents, DragCallbacks {
  // Player & Controls
  late PlayerShip player;
  Vector2? targetPosition;

  // Game State
  MeteorHarvestState gameState = MeteorHarvestState.title;

  // Scoring
  int score = 0;
  int bestScore = 0;
  int currentCombo = 0;
  double _comboTimer = 0.0;
  static const double comboWindow = 2.0; // seconds to keep combo active
  double _survivalScoreAccumulator = 0.0;

  // Difficulty & Timing
  double playTime = 0.0;

  // Preferences
  late SharedPreferences _prefs;

  @override
  Future<void> onLoad() async {
    // 1. Load preferences
    _prefs = await SharedPreferences.getInstance();
    bestScore = _prefs.getInt('best_score') ?? 0;

    // 2. Cache audio files (flame_audio caching)
    try {
      await FlameAudio.audioCache.loadAll([
        'sfx_crystal_collect.mp3',
        'sfx_rare_collect.mp3',
        'sfx_explosion.mp3',
        'sfx_button_tap.mp3',
        'sfx_new_best.mp3',
      ]);

      // Warm up background music
      FlameAudio.bgm.initialize();
    } catch (e) {
      // Keep running if audio fails to initialize (e.g. on web or simulator without audio)
      debugPrint('Audio init failed: $e');
    }

    // 3. Load Images
    await images.loadAll([
      'ship_miner.png',
      'ship_engine_flame.png',
      'crystal_blue.png',
      'crystal_purple.png',
      'crystal_gold.png',
      'asteroid_small.png',
      'asteroid_medium.png',
      'asteroid_large.png',
      'particle_explosion.png',
      'particle_sparkle_blue.png',
      'particle_engine_cyan.png',
      'background_nebula.png',
      'stars_far.png',
      'stars_mid.png',
      'logo_meteor_harvest.png',
      'powerup_shield.png',
      'powerup_magnet.png',
      'powerup_time_warp.png',
    ]);

    // Start by showing the title screen overlay
    overlays.add('TitleScreen');

    // Add scrolling background
    add(ScrollingStarfield());
    add(NebulaShaderComponent());

    // Play background music loop on start
    _playBgm();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState == MeteorHarvestState.playing) {
      playTime += dt;

      // Update combo timer
      if (currentCombo > 0) {
        _comboTimer -= dt;
        if (_comboTimer <= 0) {
          currentCombo = 0;
        }
      }

      // Accumulate score slowly over survival time (1 point per second)
      _survivalScoreAccumulator += dt;
      if (_survivalScoreAccumulator >= 1.0) {
        _survivalScoreAccumulator -= 1.0;
        score += 1;
      }
    }
  }

  void _playBgm() {
    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play('music_space_arcade_loop.mp3', volume: 0.4);
      }
    } catch (e) {
      debugPrint('BGM failed to play: $e');
    }
  }

  // State transitions
  void startRun() {
    gameState = MeteorHarvestState.playing;
    score = 0;
    currentCombo = 0;
    _comboTimer = 0.0;
    playTime = 0.0;
    _survivalScoreAccumulator = 0.0;

    // Adjust overlays
    overlays.remove('TitleScreen');
    overlays.remove('GameOverScreen');
    overlays.add('HUD');

    // Clear and rebuild components
    _resetGameComponents();

    // Play tap sound
    playSfx('sfx_button_tap.mp3');
  }

  void endRun() {
    gameState = MeteorHarvestState.gameOver;

    // Stop BG music or dim it

    // Check if new best score
    bool isNewBest = false;
    if (score > bestScore) {
      bestScore = score;
      _prefs.setInt('best_score', bestScore);
      isNewBest = true;
    }

    // Adjust overlays
    overlays.remove('HUD');
    overlays.add('GameOverScreen');

    // Play appropriate sound
    if (isNewBest) {
      playSfx('sfx_new_best.mp3');
    } else {
      playSfx('sfx_explosion.mp3');
    }
  }

  void resetToTitle() {
    gameState = MeteorHarvestState.title;

    overlays.remove('GameOverScreen');
    overlays.remove('HUD');
    overlays.add('TitleScreen');

    _clearGameplayComponents();
    playSfx('sfx_button_tap.mp3');
  }

  void playSfx(String name) {
    try {
      FlameAudio.play(name, volume: 0.6);
    } catch (e) {
      debugPrint('SFX failed to play: $e');
    }
  }

  void addScore(int value) {
    if (gameState != MeteorHarvestState.playing) return;

    // Increase combo
    currentCombo++;
    _comboTimer = comboWindow;

    // Calculate combo bonus: e.g. 1x: +10, 2x: +12, 3x: +15, 4x: +18, 5x+: +20
    int bonus = 0;
    if (currentCombo > 1) {
      if (currentCombo == 2) {
        bonus = 2;
      } else if (currentCombo == 3) {
        bonus = 5;
      } else if (currentCombo == 4) {
        bonus = 8;
      } else {
        bonus = 10;
      }
    }

    score += (value + bonus);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (gameState == MeteorHarvestState.playing) {
      targetPosition = event.localPosition;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (gameState == MeteorHarvestState.playing) {
      targetPosition = event.localEndPosition;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    targetPosition = null;
  }

  void _resetGameComponents() {
    _clearGameplayComponents();
    player = PlayerShip();
    player.position = Vector2(size.x / 2, size.y * 0.85);
    add(player);
    add(SpawnSystem());
    targetPosition = null;
  }

  void _clearGameplayComponents() {
    // Remove all gameplay components (PlayerShip, Crystals, Asteroids)
    // Keep scrolling background if it's supposed to stay
    children
        .where(
          (child) =>
              child.runtimeType.toString() != 'ScrollingStarfield' &&
              child.runtimeType.toString() != 'NebulaShaderComponent',
        )
        .forEach((child) {
          child.removeFromParent();
        });
  }
}
