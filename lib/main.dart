import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/meteor_harvest_game.dart';
import 'game/overlays/title_overlay.dart';
import 'game/overlays/hud_overlay.dart';
import 'game/overlays/game_over_overlay.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation and hide system UI for full screen arcade feel
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MeteorHarvestApp());
}

class MeteorHarvestApp extends StatelessWidget {
  const MeteorHarvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meteor Harvest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.spaceBackground,
        useMaterial3: true,
      ),
      home: const Scaffold(body: GameWidgetWrapper()),
    );
  }
}

class GameWidgetWrapper extends StatelessWidget {
  const GameWidgetWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget<MeteorHarvestGame>.controlled(
      gameFactory: MeteorHarvestGame.new,
      overlayBuilderMap: {
        'TitleScreen': (context, game) => TitleOverlay(game: game),
        'HUD': (context, game) => HUDOverlay(game: game),
        'GameOverScreen': (context, game) => GameOverOverlay(game: game),
      },
    );
  }
}
