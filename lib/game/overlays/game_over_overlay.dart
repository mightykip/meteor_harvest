import 'package:flutter/material.dart';
import '../../game/meteor_harvest_game.dart';
import 'scale_button.dart';

class GameOverOverlay extends StatelessWidget {
  final MeteorHarvestGame game;

  const GameOverOverlay({super.key, required this.game});

  String _getPerformanceLabel(int score) {
    if (score < 100) return 'Rookie Miner';
    if (score < 300) return 'Crystal Chaser';
    if (score < 600) return 'Meteor Dodger';
    return 'Legendary Harvester';
  }

  @override
  Widget build(BuildContext context) {
    final finalScore = game.scoreNotifier.value;
    final bestScore = game.bestScoreNotifier.value;
    final performance = _getPerformanceLabel(finalScore);

    return Scaffold(
      backgroundColor: Colors.black54,
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF111625),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red glowing Title
                Text(
                  'GAME OVER',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                    shadows: [
                      const Shadow(
                        color: Colors.red,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Performance Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    performance.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                if (game.isNewBest) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.amberAccent, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'NEW HIGH SCORE!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            shadows: [
                              const Shadow(color: Colors.amber, blurRadius: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Final score display with count-up animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                    CountUpText(
                      targetValue: finalScore,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                // Best score display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Best Score:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      '$bestScore',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Interactive Buttons
                Column(
                  children: [
                    // Play Again Button (with tap scaling)
                    ScaleButton(
                      onTap: game.restartRun,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'PLAY AGAIN',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Main Menu Button (with tap scaling)
                    ScaleButton(
                      onTap: game.returnToMenu,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'MAIN MENU',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
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

class CountUpText extends StatefulWidget {
  final int targetValue;
  final TextStyle? style;

  const CountUpText({
    super.key,
    required this.targetValue,
    this.style,
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.targetValue.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value.round()}',
          style: widget.style,
        );
      },
    );
  }
}
