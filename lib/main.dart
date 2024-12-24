import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Contoller/Api_provider/api_provider.dart';
import 'package:weather_app/Contoller/Location_provider/location_provider.dart';
import 'package:weather_app/View/home_screen/home_screen.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ApiProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
