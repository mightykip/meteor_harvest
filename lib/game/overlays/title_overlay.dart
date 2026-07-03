import 'package:flutter/material.dart';
import '../../game/meteor_harvest_game.dart';
import 'scale_button.dart';

class TitleOverlay extends StatelessWidget {
  final MeteorHarvestGame game;

  const TitleOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Title Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'METEOR HARVEST',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          shadows: [
                            const Shadow(
                              color: Colors.cyan,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mine crystals. Dodge meteors. Survive the field.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                // Start button with scale animation
                ScaleButton(
                  onTap: game.startRun,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    child: Text(
                      'START RUN',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  'Built with Flutter + Flame',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
