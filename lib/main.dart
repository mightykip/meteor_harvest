import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/meteor_harvest_game.dart';
import 'game/overlays/title_overlay.dart';
import 'game/overlays/hud_overlay.dart';
import 'game/overlays/game_over_overlay.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MeteorHarvestApp());
}

class MeteorHarvestApp extends StatelessWidget {
  const MeteorHarvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = MeteorHarvestGame();

    return MaterialApp(
      title: 'Meteor Harvest',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<MeteorHarvestGame>(
          game: game,
          overlayBuilderMap: {
            'title': (context, gameInstance) => TitleOverlay(game: gameInstance),
            'hud': (context, gameInstance) => HudOverlay(game: gameInstance),
            'gameOver': (context, gameInstance) => GameOverOverlay(game: gameInstance),
          },
          initialActiveOverlays: const ['title'],
        ),
      ),
    );
  }
}
