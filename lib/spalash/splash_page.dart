import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_weather/weather/view/weather_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WeatherPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
              Color(0xFF38BDF8),
            ],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.cloud,
                size: 100,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Weather App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Check weather anytime anywhere',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 50),

            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}