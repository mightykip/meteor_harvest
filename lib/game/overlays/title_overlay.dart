import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../meteor_harvest_game.dart';

class TitleOverlay extends StatefulWidget {
  final MeteorHarvestGame game;

  const TitleOverlay({super.key, required this.game});

  @override
  State<TitleOverlay> createState() => _TitleOverlayState();
}

class _TitleOverlayState extends State<TitleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bobAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Smooth sinusoidal bobbing for the game logo
    _bobAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Continuous pulsing effect for the primary action button
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Background scrolling starfield is behind
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with Bobbing Animation
              AnimatedBuilder(
                animation: _bobAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bobAnimation.value),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    'assets/images/logo_meteor_harvest.png',
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'METEOR HARVEST',
                        style: AppTheme.titleStyle,
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Mine crystals. Dodge meteors. Survive the field.',
                  style: AppTheme.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),

              // Start Button with Pulsing Scale
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: ElevatedButton(
                  onPressed: widget.game.startRun,
                  style: AppTheme.primaryButtonStyle,
                  child: const Text(
                    'START RUN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),

              // Footer
              const Text(
                'Built with Flutter + Flame',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white30,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
