import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static Route<String> route() {
    return MaterialPageRoute(builder: (_) => const SearchPage());
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=7',
      );

      final response = await http.get(
        uri,
        headers: {'Accept-Language': 'id,en'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final results = data.map<String>((item) {
          final address = item['address'];
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'] ??
              '';
          final country = address['country'] ?? '';
          if (city.isEmpty) return item['display_name'] ?? '';
          return '$city, $country';
        }).where((s) => s.isNotEmpty).toSet().toList();

        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(value);
    });
  }

  void _submitCity(String city) {
    Navigator.of(context).pop(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2149),
      extendBodyBehindAppBar: true,
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
            top: -60,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5FC0F0).withOpacity(0.07),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  // ── Top bar ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Cari Kota',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Search field ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? const Color(0xFF5FC0F0).withOpacity(0.6)
                              : Colors.white.withOpacity(0.12),
                          width: 1.5,
                        ),
                        boxShadow: _focusNode.hasFocus
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF5FC0F0).withOpacity(0.1),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        cursorColor: const Color(0xFF5FC0F0),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Jakarta, Bandung, Surabaya...',
                          hintStyle: const TextStyle(
                            color: Color(0x60FFFFFF),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF5FC0F0),
                            size: 20,
                          ),
                          suffixIcon: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(13),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF5FC0F0),
                                    ),
                                  ),
                                )
                              : _textController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _textController.clear();
                                        setState(() => _suggestions = []);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Color(0xB3FFFFFF),
                                          size: 16,
                                        ),
                                      ),
                                    )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          _onTextChanged(value);
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty) _submitCity(value);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Results ──────────────────────────────────────────────
                  Expanded(
                    child: _suggestions.isEmpty && !_isLoading
                        ? _buildEmptyState()
                        : _buildResultsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final city = _suggestions[index];
        // Split "City, Country" for two-line display
        final parts = city.split(', ');
        final cityName = parts.first;
        final countryName = parts.length > 1 ? parts.sublist(1).join(', ') : '';

        return GestureDetector(
          onTap: () => _submitCity(city),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5FC0F0).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF5FC0F0).withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: Color(0xFF5FC0F0),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                // City + country
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (countryName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          countryName,
                          style: const TextStyle(
                            color: Color(0x80FFFFFF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0x40FFFFFF),
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isEmpty = _textController.text.isEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: Icon(
                isEmpty
                    ? Icons.travel_explore_rounded
                    : Icons.search_off_rounded,
                size: 40,
                color: const Color(0xFF5FC0F0).withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEmpty ? 'Cari kota di seluruh dunia' : 'Kota tidak ditemukan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEmpty
                ? 'Ketik nama kota untuk mulai mencari'
                : 'Coba nama kota yang berbeda',
            style: const TextStyle(
              color: Color(0x60FFFFFF),
              fontSize: 13,
            ),
          ),

          // Popular cities hint (only on empty input)
          if (isEmpty) ...[
            const SizedBox(height: 36),
            const Padding(
              padding: EdgeInsets.only(left: 32),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'POPULER',
                  style: TextStyle(
                    color: Color(0x73FFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                'Jakarta', 'Surabaya', 'Bandung',
                'Bali', 'Medan', 'Yogyakarta',
              ].map((city) => GestureDetector(
                onTap: () => _submitCity(city),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Color(0xFF5FC0F0), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        city,
                        style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}