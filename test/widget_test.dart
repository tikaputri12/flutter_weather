import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/app.dart';

void main() {
  testWidgets('renders WeatherApp', (tester) async {
    await tester.pumpWidget(const WeatherApp());

    expect(find.byType(WeatherApp), findsOneWidget);
  });
}