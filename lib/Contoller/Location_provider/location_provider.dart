import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  Placemark? _currentLocationName;
  Placemark? get currentLocation => _currentLocationName;
  Position? get currentPosition => _currentPosition;
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _currentPosition = null;
      notifyListeners();
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _currentPosition = null;
        notifyListeners();
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _currentPosition = null;
      notifyListeners();
      return;
    }
    _currentPosition = await Geolocator.getCurrentPosition();
    print(_currentPosition);

    _currentLocationName = await getPositionName(_currentPosition);
    print(_currentLocationName);
    notifyListeners();
  }

  Future<Placemark?> getPositionName(Position? position) async {
    if (position != null) {
      try {
        final Placemark = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (Placemark.isNotEmpty) {
          return Placemark[0];
        }
      } catch (e) {
        print("Error in fecting the data");
      }
    }
    return null;
  }
}
