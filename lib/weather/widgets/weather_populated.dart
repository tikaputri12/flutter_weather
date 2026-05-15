import 'package:flutter/material.dart';
import 'package:flutter_weather/weather/models/weather.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

class WeatherPopulated extends StatelessWidget {
  const WeatherPopulated({
    required this.weather,
    required this.units,
    required this.onRefresh,
    this.onSearchTap,
    super.key,
  });

  final Weather weather;
  final TemperatureUnits units;
  final ValueGetter<Future<void>> onRefresh;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _WeatherBackground(),
        RefreshIndicator(
          onRefresh: onRefresh,
          color: const Color(0xFF5FC0F0),
          backgroundColor: const Color(0xFF1A3A6B),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    _LocationRow(
                      location: weather.location,
                      onTap: onSearchTap,
                    ),
                    const SizedBox(height: 16),
                    _AnimatedCloudIcon(condition: weather.condition),
                    const SizedBox(height: 24),
                    _TemperatureDisplay(
                      weather: weather,
                      units: units,
                    ),
                    const SizedBox(height: 8),
                    _ConditionLabel(condition: weather.condition),
                    const SizedBox(height: 4),
                    _LastUpdatedLabel(lastUpdated: weather.lastUpdated),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _StatsRow(),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _HourlyForecast(condition: weather.condition),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _FiveDayForecast(condition: weather.condition),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Location Row ─────────────────────────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location, this.onTap});
  final String location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF5FC0F0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0xFF5FC0F0), blurRadius: 6, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              location,
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0x99FFFFFF), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Cloud Icon ──────────────────────────────────────────────────────

class _AnimatedCloudIcon extends StatelessWidget {
  const _AnimatedCloudIcon({required this.condition});
  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Center(
        child: Text(
          condition.toEmoji,
          style: const TextStyle(fontSize: 90),
        ),
      ),
    );
  }
}

// ─── Temperature Display ──────────────────────────────────────────────────────

class _TemperatureDisplay extends StatelessWidget {
  const _TemperatureDisplay({required this.weather, required this.units});
  final Weather weather;
  final TemperatureUnits units;

  @override
  Widget build(BuildContext context) {
    final tempStr = weather.temperature.value.toStringAsPrecision(2);
    final unit = units.isCelsius ? 'C' : 'F';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: tempStr,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 88,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 1,
              letterSpacing: -4,
              shadows: [
                Shadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 4)),
              ],
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '°$unit',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                  color: Color(0xB3FFFFFF),
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Condition Label ──────────────────────────────────────────────────────────

class _ConditionLabel extends StatelessWidget {
  const _ConditionLabel({required this.condition});
  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toLabel,
      style: const TextStyle(
        color: Color(0xFF7AC8F5),
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Last Updated ─────────────────────────────────────────────────────────────

class _LastUpdatedLabel extends StatelessWidget {
  const _LastUpdatedLabel({required this.lastUpdated});
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(lastUpdated).format(context);
    return Text(
      'Feels like • Updated $time',
      style: const TextStyle(
        color: Color(0x80FFFFFF),
        fontSize: 13,
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(icon: '💧', value: '82%', label: 'Humidity'),
          _VerticalDivider(),
          _StatItem(icon: '🌬️', value: '14 km/h', label: 'Wind'),
          _VerticalDivider(),
          _StatItem(icon: '👁️', value: '8 km', label: 'Visibility'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value, required this.label});
  final String icon, value, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: Color(0x73FFFFFF), fontSize: 10, letterSpacing: 0.8)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: Colors.white.withOpacity(0.12));
  }
}

// ─── Hourly Forecast ──────────────────────────────────────────────────────────

class _HourlyForecast extends StatefulWidget {
  const _HourlyForecast({required this.condition});
  final WeatherCondition condition;

  @override
  State<_HourlyForecast> createState() => _HourlyForecastState();
}

class _HourlyForecastState extends State<_HourlyForecast> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hours = [
      _HourData('Now', widget.condition.toEmoji, '26°', true),
      _HourData('10 AM', '⛅', '27°', false),
      _HourData('12 PM', '🌧️', '25°', false),
      _HourData('2 PM', '🌦️', '26°', false),
      _HourData('4 PM', '⛅', '28°', false),
      _HourData('6 PM', '🌤️', '27°', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOURLY FORECAST',
          style: TextStyle(
            color: Color(0x73FFFFFF),
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _HourCard(
              data: hours[i],
              index: i,
              selectedIndex: _selectedIndex,
              onSelect: (idx) => setState(() => _selectedIndex = idx),
            ),
          ),
        ),
      ],
    );
  }
}

class _HourData {
  const _HourData(this.time, this.emoji, this.temp, this.isActive);
  final String time, emoji, temp;
  final bool isActive;
}

class _HourCard extends StatefulWidget {
  const _HourCard({required this.data, required this.index, required this.selectedIndex, required this.onSelect});
  final _HourData data;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  State<_HourCard> createState() => _HourCardState();
}

class _HourCardState extends State<_HourCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isActive => widget.index == widget.selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onSelect(widget.index);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: _isActive
                ? const Color(0xFF5CB4F0).withOpacity(0.25)
                : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isActive
                  ? const Color(0xFF5CB4F0).withOpacity(0.55)
                  : Colors.white.withOpacity(0.1),
              width: _isActive ? 1.5 : 1.0,
            ),
            boxShadow: _isActive
                ? [BoxShadow(color: const Color(0xFF5CB4F0).withOpacity(0.2), blurRadius: 12)]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(widget.data.time,
                  style: TextStyle(
                    color: _isActive ? const Color(0xCCFFFFFF) : const Color(0x8CFFFFFF),
                    fontSize: 11,
                  )),
              Text(widget.data.emoji, style: const TextStyle(fontSize: 22)),
              Text(widget.data.temp,
                  style: TextStyle(
                    color: _isActive ? Colors.white : const Color(0xCCFFFFFF),
                    fontSize: 14,
                    fontWeight: _isActive ? FontWeight.w700 : FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 5-Day Forecast ───────────────────────────────────────────────────────────

class _FiveDayForecast extends StatelessWidget {
  const _FiveDayForecast({required this.condition});
  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    final days = [
      _DayData('Today', condition.toEmoji, 22, 28, 0.65, false),
      _DayData('Fri', '🌧️', 21, 27, 0.55, false),
      _DayData('Sat', '⛅', 23, 31, 0.70, false),
      _DayData('Sun', '☀️', 24, 33, 0.85, true),
      _DayData('Mon', '🌤️', 22, 30, 0.60, false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5-DAY FORECAST',
          style: TextStyle(
            color: Color(0x73FFFFFF),
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: days
                .asMap()
                .entries
                .map((e) => _ForecastRow(
                      data: e.value,
                      isLast: e.key == days.length - 1,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DayData {
  const _DayData(this.day, this.emoji, this.lo, this.hi, this.fill, this.isHot);
  final String day, emoji;
  final int lo, hi;
  final double fill;
  final bool isHot;
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({required this.data, required this.isLast});
  final _DayData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${data.day}: ${data.lo}° – ${data.hi}°',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF1A3A6B),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        splashColor: const Color(0xFF5FC0F0).withOpacity(0.1),
        highlightColor: const Color(0xFF5FC0F0).withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: isLast
              ? null
              : const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0x12FFFFFF)),
                  ),
                ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  data.day,
                  style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(data.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('${data.lo}°',
                  style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: data.fill,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: data.isHot
                              ? [const Color(0xFFF5A623), const Color(0xFFE8631A)]
                              : [const Color(0xFF5FC0F0), const Color(0xFF2E7DD1)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${data.hi}°',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Background ───────────────────────────────────────────────────────────────

class _WeatherBackground extends StatelessWidget {
  const _WeatherBackground();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: DecoratedBox(
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
    );
  }
}

// ─── Extensions ───────────────────────────────────────────────────────────────

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '🌦️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '⛅';
    }
  }

  String get toLabel {
    switch (this) {
      case WeatherCondition.clear:
        return 'Sunny & Clear';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.cloudy:
        return 'Mostly Cloudy';
      case WeatherCondition.snowy:
        return 'Snowy';
      case WeatherCondition.unknown:
        return 'Partly Cloudy';
    }
  }
}

extension on Color {
  Color brighten([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }
}