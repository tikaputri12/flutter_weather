import 'package:flutter/material.dart';

class WeatherLoading extends StatefulWidget {
  const WeatherLoading({super.key});

  @override
  State<WeatherLoading> createState() => _WeatherLoadingState();
}

class _WeatherLoadingState extends State<WeatherLoading>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.4, 0.6, 1.0],
                colors: [
                  Color(0xFF0D2149),
                  Color(0xFF1A3A6B),
                  Color(0xFF1E4080),
                  Color(0xFF2659A0),
                ],
              ),
            ),
          ),

          // Ambient glow circles
          Positioned(
            top: -80,
            left: -60,
            child: _GlowCircle(size: 280, opacity: 0.06),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _GlowCircle(size: 220, opacity: 0.05),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing cloud icon
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow ring
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF5FC0F0).withOpacity(
                              0.06 + (_pulseController.value * 0.06),
                            ),
                          ),
                        ),
                      ),
                      // Icon card
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5FC0F0).withOpacity(0.2),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('⛅', style: TextStyle(fontSize: 44)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Title
                const Text(
                  'Fetching Weather',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Getting the latest conditions for you',
                  style: TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 36),

                // Animated dots loader
                _AnimatedDots(controller: _dotsController),

                const SizedBox(height: 48),

                // Shimmer skeleton cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _ShimmerCard(width: double.infinity, height: 70),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _ShimmerCard(height: 60)),
                          const SizedBox(width: 10),
                          Expanded(child: _ShimmerCard(height: 60)),
                          const SizedBox(width: 10),
                          Expanded(child: _ShimmerCard(height: 60)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ShimmerCard(width: double.infinity, height: 160),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Dots ────────────────────────────────────────────────────────────

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.6 + (0.4 * (1 - (t * 2 - 1).abs()));
            final opacity = 0.3 + (0.7 * (1 - (t * 2 - 1).abs()));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5FC0F0),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Shimmer Card ─────────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({this.width, required this.height});
  final double? width;
  final double height;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value, 0),
              colors: [
                Colors.white.withOpacity(0.04),
                Colors.white.withOpacity(0.09),
                Colors.white.withOpacity(0.04),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
        );
      },
    );
  }
}

// ─── Glow Circle ─────────────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF5FC0F0).withOpacity(opacity),
      ),
    );
  }
}