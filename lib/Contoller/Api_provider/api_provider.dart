import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:weather_app/Model/Air_Quality_model/air_quality_model.dart';
import 'package:weather_app/Model/Forecaste_model/forecaste_model.dart';
import 'package:weather_app/Secret/api_endpoints.dart';
import 'package:weather_app/Secret/api_key.dart';
import 'package:weather_app/model/Weather_model/weather_model.dart';
import 'package:http/http.dart' as http;

class ApiProvider with ChangeNotifier {
  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String error = "";
  Future<void> fetchDataOfCity(String city) async {
    _isLoading = true;
    error = "";
    try {
      final String apiUrl =
          "${ApiEndpoints.baseurl}${ApiEndpoints.cityUrl}${city}${ApiKey().apiKey}${ApiEndpoints.units}";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        _weather = WeatherModel.fromJson(data);
        notifyListeners();
      } else {
        error = "Failed to get data";
      }
    } catch (e) {
      error = "Failed to load $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ForecastModel? forcasteData;
  Future<void> forcaste(String city) async {
    _isLoading = true;
    error = "";
    try {
      final String forcasteUrl =
          "${ApiEndpoints.baseurl}${ApiEndpoints.forecast}${city}${ApiKey().apiKey}${ApiEndpoints.units}";
      final response = await http.get(Uri.parse(forcasteUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Forecast Response: $data"); // Log the entire response for debugging
        forcasteData = ForecastModel.fromJson(data);
        notifyListeners();
      } else {
        error = "Failed to load data. Status Code: ${response.statusCode}";
        print(error); // Log error message
      }
    } catch (e) {
      error = "Failed to load data: $e";
      print(error); // Log error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AirQualityModel? air;
  Future<void> airPolution(double lat, double long) async {
    _isLoading = true;
    error = "";
    try {
      final String airUrl =
          "${ApiEndpoints.baseurl}${ApiEndpoints.airQuality}lat=${lat}&lon=${long}${ApiKey().apiKey}${ApiEndpoints.units}";
      final response = await http.get(Uri.parse(airUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        air = AirQualityModel.fromJson(data);
        notifyListeners();
      } else {
        error = "Failed to load data. Status Code: ${response.statusCode}";
        print(error); // Log error message
      }
    } catch (e) {
      error = "Failed to load data: $e";
      print(error); // Log error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
