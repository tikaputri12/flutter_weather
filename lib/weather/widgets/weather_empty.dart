import 'package:flutter/material.dart';

class WeatherEmpty extends StatefulWidget {
  const WeatherEmpty({super.key});

  @override
  State<WeatherEmpty> createState() => _WeatherEmptyState();
}

class _WeatherEmptyState extends State<WeatherEmpty>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _fadeController;
  late final Animation<double> _floatAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background gradient
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

          // Ambient glow orbs
          Positioned(
            top: -100,
            right: -60,
            child: _GlowOrb(size: 300, color: const Color(0xFF2E7DD1), opacity: 0.12),
          ),
          Positioned(
            bottom: 60,
            left: -80,
            child: _GlowOrb(size: 240, color: const Color(0xFF5FC0F0), opacity: 0.08),
          ),

          // Decorative floating particles
          ..._buildParticles(),

          // Main content
          FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Floating city + weather illustration
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: child,
                    ),
                    child: _IllustrationCard(),
                  ),

                  const SizedBox(height: 40),

                  // Headline
                  const Text(
                    'Where are you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Search for a city to get the latest\nweather conditions instantly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0x80FFFFFF),
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 44),

                  // Feature pills
                  const _FeaturePills(),

                  const SizedBox(height: 44),

                  // Search hint arrow
                  const _SearchHint(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    const positions = [
      [0.15, 0.12], [0.78, 0.18], [0.08, 0.45],
      [0.88, 0.38], [0.22, 0.72], [0.72, 0.65],
    ];
    const sizes = [3.0, 2.0, 4.0, 2.5, 3.5, 2.0];

    return List.generate(positions.length, (i) {
      return AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) {
          final offset = (i % 2 == 0 ? 1 : -1) *
              4.0 *
              (_floatController.value - 0.5).abs();
          return Positioned(
            left: MediaQuery.of(context).size.width * (positions[i][0] as double),
            top: MediaQuery.of(context).size.height * (positions[i][1] as double),
            child: Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                width: sizes[i],
                height: sizes[i],
                decoration: BoxDecoration(
                  color: const Color(0xFF5FC0F0).withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

// ─── Illustration Card ────────────────────────────────────────────────────────

class _IllustrationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5FC0F0).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
          ),
          // Emoji stack
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🌤️', style: TextStyle(fontSize: 60)),
              SizedBox(height: 4),
              Text('🏙️', style: TextStyle(fontSize: 36)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Feature Pills ────────────────────────────────────────────────────────────

class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  @override
  Widget build(BuildContext context) {
    const features = [
      ('🌡️', 'Temperature'),
      ('💧', 'Humidity'),
      ('🌬️', 'Wind'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(f.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  f.$2,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Search Hint ──────────────────────────────────────────────────────────────

class _SearchHint extends StatefulWidget {
  const _SearchHint();

  @override
  State<_SearchHint> createState() => _SearchHintState();
}

class _SearchHintState extends State<_SearchHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: 8).animate(
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
    return Column(
      children: [
        const Text(
          'Tap Search below to get started',
          style: TextStyle(
            color: Color(0x60FFFFFF),
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _bounce,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _bounce.value),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF5FC0F0),
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glow Orb ─────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color, required this.opacity});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}