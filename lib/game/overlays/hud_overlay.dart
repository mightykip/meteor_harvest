import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../meteor_harvest_game.dart';

class HUDOverlay extends StatefulWidget {
  final MeteorHarvestGame game;

  const HUDOverlay({super.key, required this.game});

  @override
  State<HUDOverlay> createState() => _HUDOverlayState();
}

class _HUDOverlayState extends State<HUDOverlay> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // Poll the game score/combo to redraw the HUD.
    // 100ms interval is very fast and responsive, and cheap to redraw.
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Stack(
          children: [
            // Top row for Score and Best Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Score
                _AnimatedScoreDisplay(
                  label: 'SCORE',
                  value: widget.game.score,
                  valueColor: AppTheme.cyanGlow,
                ),

                // Best Score
                _AnimatedScoreDisplay(
                  label: 'BEST',
                  value: widget.game.bestScore,
                  valueColor: AppTheme.crystalGold,
                  alignRight: true,
                ),
              ],
            ),

            // Top center combo display
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: _ComboIndicator(combo: widget.game.currentCombo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedScoreDisplay extends StatefulWidget {
  final String label;
  final int value;
  final Color valueColor;
  final bool alignRight;

  const _AnimatedScoreDisplay({
    required this.label,
    required this.value,
    required this.valueColor,
    this.alignRight = false,
  });

  @override
  State<_AnimatedScoreDisplay> createState() => _AnimatedScoreDisplayState();
}

class _AnimatedScoreDisplayState extends State<_AnimatedScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _AnimatedScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value > oldWidget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 1.0,
          ),
        ),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            '${widget.value}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: widget.valueColor,
              shadows: const [
                Shadow(
                  blurRadius: 6.0,
                  color: Colors.black45,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ComboIndicator extends StatelessWidget {
  final int combo;

  const _ComboIndicator({required this.combo});

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox.shrink();

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: 1.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppTheme.cyanGlow.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cyanGlow.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          'COMBO x$combo',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.cyanGlow,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
