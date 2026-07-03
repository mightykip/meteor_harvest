import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../meteor_harvest_game.dart';

class GameOverOverlay extends StatelessWidget {
  final MeteorHarvestGame game;

  const GameOverOverlay({super.key, required this.game});

  String _getPerformanceLabel(int score) {
    if (score < 100) return 'Rookie Miner';
    if (score < 300) return 'Crystal Chaser';
    if (score < 600) return 'Meteor Dodger';
    return 'Legendary Harvester';
  }

  Color _getPerformanceColor(int score) {
    if (score < 100) return Colors.grey;
    if (score < 300) return AppTheme.crystalBlue;
    if (score < 600) return AppTheme.cyanGlow;
    return AppTheme.crystalGold;
  }

  @override
  Widget build(BuildContext context) {
    final performance = _getPerformanceLabel(game.score);
    final perfColor = _getPerformanceColor(game.score);
    final isNewRecord = game.score >= game.bestScore && game.score > 0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            color: AppTheme.darkOverlay.withValues(alpha: 0.8 * opacity),
            child: child,
          ),
        );
      },
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(32.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 36.0,
            ),
            decoration: BoxDecoration(
              color: AppTheme.spaceBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isNewRecord
                    ? AppTheme.crystalGold.withValues(alpha: 0.5)
                    : AppTheme.asteroidOrange.withValues(alpha: 0.5),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isNewRecord
                              ? AppTheme.crystalGold
                              : AppTheme.asteroidOrange)
                          .withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Over Title
                Text(
                  'GAME OVER',
                  style: AppTheme.gameOverStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // New High Score Banner
                if (isNewRecord) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.crystalGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.crystalGold),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: AppTheme.crystalGold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'NEW RECORD!',
                          style: TextStyle(
                            color: AppTheme.crystalGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Final Score
                const Text(
                  'FINAL SCORE',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: game.score),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, animatedScore, _) {
                    return Text(
                      '$animatedScore',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: isNewRecord
                            ? AppTheme.crystalGold
                            : Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Best Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'BEST SCORE: ',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    Text(
                      '${game.bestScore}',
                      style: const TextStyle(
                        color: AppTheme.crystalGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Performance Title
                const Text(
                  'RANK',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white30,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  performance.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: perfColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 40),

                // Buttons
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: game.startRun,
                      style: AppTheme.primaryButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          isNewRecord
                              ? AppTheme.crystalGold
                              : AppTheme.cyanGlow,
                        ),
                        shadowColor: WidgetStateProperty.all(
                          (isNewRecord
                                  ? AppTheme.crystalGold
                                  : AppTheme.cyanGlow)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: const SizedBox(
                        width: 160,
                        child: Text(
                          'PLAY AGAIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: game.resetToTitle,
                      style: AppTheme.secondaryButtonStyle,
                      child: const SizedBox(
                        width: 160,
                        child: Text(
                          'MAIN MENU',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
