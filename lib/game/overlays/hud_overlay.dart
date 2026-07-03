import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../game/meteor_harvest_game.dart';

class HudOverlay extends StatelessWidget {
  final MeteorHarvestGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score Panel (Top Left)
                  _buildStatPanel(
                    context,
                    label: 'SCORE',
                    valueListenable: game.scoreNotifier,
                    color: Colors.cyanAccent,
                  ),
                  // Pause Button (Top Center)
                  ValueListenableBuilder<bool>(
                    valueListenable: game.isPausedNotifier,
                    builder: (context, isPaused, child) {
                      return IconButton(
                        icon: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                        onPressed: game.togglePause,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                          padding: const EdgeInsets.all(10),
                        ),
                      );
                    },
                  ),
                  // Best Score Panel (Top Right)
                  _buildStatPanel(
                    context,
                    label: 'BEST',
                    valueListenable: game.bestScoreNotifier,
                    color: Colors.amberAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPanel(
    BuildContext context, {
    required String label,
    required ValueListenable<int> valueListenable,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          AnimatedScoreText(
            scoreListenable: valueListenable,
            color: color,
          ),
        ],
      ),
    );
  }
}

class AnimatedScoreText extends StatefulWidget {
  final ValueListenable<int> scoreListenable;
  final Color color;

  const AnimatedScoreText({
    super.key,
    required this.scoreListenable,
    required this.color,
  });

  @override
  State<AnimatedScoreText> createState() => _AnimatedScoreTextState();
}

class _AnimatedScoreTextState extends State<AnimatedScoreText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _lastScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    widget.scoreListenable.addListener(_onScoreChanged);
    _lastScore = widget.scoreListenable.value;
  }

  @override
  void dispose() {
    widget.scoreListenable.removeListener(_onScoreChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onScoreChanged() {
    final currentScore = widget.scoreListenable.value;
    if (currentScore != _lastScore) {
      _lastScore = currentScore;
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ValueListenableBuilder<int>(
        valueListenable: widget.scoreListenable,
        builder: (context, value, child) {
          return Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: widget.color,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
