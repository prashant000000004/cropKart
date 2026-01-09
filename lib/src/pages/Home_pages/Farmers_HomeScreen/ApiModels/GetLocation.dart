import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> determinePosition(BuildContext context) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await _gpsDialog(context);
      throw Exception("GPS OFF");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _permissionDialog(context);
        throw Exception("DENIED");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _permanentDialog(context);
      throw Exception("DENIED FOREVER");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<void> _gpsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Enable Location"),
            content: const Text("Turn ON location services"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: const Text("Settings"),
              ),
            ],
          ),
    );
  }

  static Future<void> _permissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (_) => const AlertDialog(
            title: Text("Permission Required"),
            content: Text("Location permission is needed"),
          ),
    );
  }

  static Future<void> _permanentDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Permission Required"),
            content: const Text("Enable permission from settings"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
    );
  }
}
