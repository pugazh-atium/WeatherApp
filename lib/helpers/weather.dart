import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherProvider with ChangeNotifier {
  String _weatherCondition = "";
  double _temperature = 0.0;

  String get weatherCondition => _weatherCondition;
  double get temperature => _temperature;

  Future<void> fetchWeather(double latitude, double longitude) async {
    const apiKey = 'd1c8e7643c893aa082cdff9f721151d9';
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&exclude=minutely,hourly&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      _weatherCondition = data['weather'][0]['main'];
      _temperature = data['main']['temp'];
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
