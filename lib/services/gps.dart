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


class GPS {

  GPS();

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) { 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 
    return await Geolocator.getCurrentPosition();
  }

}
