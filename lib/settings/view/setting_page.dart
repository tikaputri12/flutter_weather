import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/weather.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SettingsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2149),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Stack(
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

          // Ambient glow
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5FC0F0).withOpacity(0.07),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                // Section label
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'PREFERENCES',
                    style: TextStyle(
                      color: Color(0x73FFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Temperature units toggle
                BlocBuilder<WeatherCubit, WeatherState>(
                  buildWhen: (previous, current) =>
                      previous.temperatureUnits != current.temperatureUnits,
                  builder: (context, state) {
                    final isCelsius = state.temperatureUnits.isCelsius;
                    return _SettingCard(
                      icon: Icons.thermostat_rounded,
                      iconColor: const Color(0xFF5FC0F0),
                      title: 'Temperature Units',
                      subtitle: isCelsius
                          ? 'Currently using Celsius (°C)'
                          : 'Currently using Fahrenheit (°F)',
                      trailing: _UnitToggle(
                        isCelsius: isCelsius,
                        onToggle: () =>
                            context.read<WeatherCubit>().toggleUnits(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Static info cards
                _SettingCard(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF7AC8F5),
                  title: 'About',
                  subtitle: 'Flutter Weather App · v1.0.0',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0x40FFFFFF),
                    size: 20,
                  ),
                ),

                const SizedBox(height: 32),

                // Section label
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'UNIT PREVIEW',
                    style: TextStyle(
                      color: Color(0x73FFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // C vs F preview card
                BlocBuilder<WeatherCubit, WeatherState>(
                  buildWhen: (previous, current) =>
                      previous.temperatureUnits != current.temperatureUnits,
                  builder: (context, state) {
                    final isCelsius = state.temperatureUnits.isCelsius;
                    return _UnitPreviewCard(isCelsius: isCelsius);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Setting Card ─────────────────────────────────────────────────────────────

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

// ─── Unit Toggle ──────────────────────────────────────────────────────────────

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.isCelsius, required this.onToggle});
  final bool isCelsius;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 72,
        height: 34,
        decoration: BoxDecoration(
          color: isCelsius
              ? const Color(0xFF3A9BD5).withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isCelsius
                ? const Color(0xFF5FC0F0).withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Stack(
          children: [
            // Labels
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '°C',
                  style: TextStyle(
                    color: isCelsius
                        ? const Color(0xFF5FC0F0)
                        : Colors.white.withOpacity(0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '°F',
                  style: TextStyle(
                    color: !isCelsius
                        ? const Color(0xFF5FC0F0)
                        : Colors.white.withOpacity(0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment:
                  isCelsius ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF5FC0F0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x665FC0F0),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Unit Preview Card ────────────────────────────────────────────────────────

class _UnitPreviewCard extends StatelessWidget {
  const _UnitPreviewCard({required this.isCelsius});
  final bool isCelsius;

  @override
  Widget build(BuildContext context) {
    const examples = [
      ('Freezing', 0, 32),
      ('Cool', 15, 59),
      ('Warm', 25, 77),
      ('Hot', 35, 95),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: examples.asMap().entries.map((e) {
          final isLast = e.key == examples.length - 1;
          final label = e.value.$1;
          final celsius = e.value.$2;
          final fahrenheit = e.value.$3;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: isLast
                ? null
                : BoxDecoration(
                    border: Border(
                      bottom:
                          BorderSide(color: Colors.white.withOpacity(0.07)),
                    ),
                  ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isCelsius ? '$celsius°C' : '$fahrenheit°F',
                      key: ValueKey(isCelsius ? celsius : fahrenheit),
                      style: const TextStyle(
                        color: Color(0xFF5FC0F0),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Active indicator dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCelsius
                        ? const Color(0xFF5FC0F0)
                        : const Color(0xFFF5A623),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}