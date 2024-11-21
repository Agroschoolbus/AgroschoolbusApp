import 'package:geolocator/geolocator.dart';

Future<Stream<Position>> initializeLocationStream({
  LocationAccuracy accuracy = LocationAccuracy.high,
  int distanceFilter = 10,
}) async {
  // Request permissions
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception("Location permissions are denied.");
  }

  // Configure location settings
  final LocationSettings locationSettings = LocationSettings(
    accuracy: accuracy,
    distanceFilter: distanceFilter,
  );

  // Return the position stream
  return Geolocator.getPositionStream(locationSettings: locationSettings);
}
