import 'package:flutter/material.dart';

class WeatherError extends StatefulWidget {
  const WeatherError({super.key});

  @override
  State<WeatherError> createState() => _WeatherErrorState();
}

class _WeatherErrorState extends State<WeatherError>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shake: -12 → +12 → -8 → +8 → 0
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  void _replay() {
    _shakeController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
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

          // Red ambient glow (error tint)
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE05555).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE05555).withOpacity(0.05),
              ),
            ),
          ),

          // Content
          FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shaking icon with pulse ring
                  AnimatedBuilder(
                    animation: Listenable.merge([_shakeAnim, _pulseAnim]),
                    builder: (_, __) {
                      return Transform.translate(
                        offset: Offset(_shakeAnim.value, 0),
                        child: ScaleTransition(
                          scale: _pulseAnim,
                          child: GestureDetector(
                            onTap: _replay,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse ring
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE05555).withOpacity(
                                      0.06 + (_pulseController.value * 0.06),
                                    ),
                                  ),
                                ),
                                // Icon card
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.07),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE05555).withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE05555).withOpacity(0.2),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text('⚠️', style: TextStyle(fontSize: 42)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  // Title
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'We couldn\'t fetch the weather data.\nCheck your connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0x80FFFFFF),
                        fontSize: 14,
                        height: 1.65,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Error detail chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05555).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFE05555).withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE05555),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Unable to load weather data',
                          style: TextStyle(
                            color: Color(0xCCFF8A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 44),

                  // Suggestions
                  const _SuggestionList(),

                  const SizedBox(height: 48),

                  // Search hint
                  const _SearchHint(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggestion List ─────────────────────────────────────────────────────────

class _SuggestionList extends StatelessWidget {
  const _SuggestionList();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.wifi_off_rounded, 'Check your internet connection'),
      (Icons.location_city_rounded, 'Try searching a different city'),
      (Icons.refresh_rounded, 'Pull down to refresh'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: isLast
                  ? null
                  : BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.white.withOpacity(0.07)),
                      ),
                    ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(e.value.$1,
                        color: const Color(0xFF5FC0F0), size: 17),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    e.value.$2,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Search Hint ─────────────────────────────────────────────────────────────

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
          'Try searching a new city below',
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