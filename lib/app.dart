import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/spalash/splash_page.dart';
import 'package:flutter_weather/theme/app_theme.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/models/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository, WeatherCondition;
    
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => WeatherRepository(),
      dispose: (repository) => repository.dispose(),
      child: BlocProvider(
        create: (context) => WeatherCubit(
          context.read<WeatherRepository>(),
        ),
        child: const WeatherAppView(),
      ),
    );
  }
}

class WeatherAppView extends StatelessWidget {
  const WeatherAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final seedColor = context.select(
  (WeatherCubit cubit) => cubit.state.weather.toColor,
);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seedColor),
      home: const SplashPage(),
    );
  }
}

extension on Weather {
  Color get toColor {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.yellow;

      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;

      case WeatherCondition.cloudy:
        return Colors.blueGrey;

      case WeatherCondition.rainy:
        return Colors.indigoAccent;

      case WeatherCondition.unknown:
        return Colors.cyan;
    }
  }
}