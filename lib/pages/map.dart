import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapPage> {
  Position? _position;
  LatLng? _currentPosition;
  LatLng? apiPosition;

  final ButtonStyle b_style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  // Should be placed in a separate file as a service
  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
      _currentPosition = LatLng(_position!.latitude, _position!.longitude);
      apiPosition = LatLng(_position!.latitude, _position!.longitude);
      if (_position != null) {
        customMarkers = <Marker>[];
        customMarkers.add(buildPin(LatLng(_position!.latitude.toDouble(), _position!.longitude.toDouble())));
      }
    });
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  late var customMarkers = <Marker>[];

  Marker buildPin(LatLng point) => Marker(
        point: point,
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Σάκος χρήστης με id 2'),
              duration: Duration(seconds: 1),
              showCloseIcon: true,
            ),
          ),
          child: Icon(Icons.location_pin, size: 30, color: Theme.of(context).colorScheme.error),
        ),
      );

  void addSinglePin(LatLng point) {
    setState(() {
      customMarkers = <Marker>[];
      customMarkers.add(buildPin(point));
    });
  }

  Future<void> sendLocation(double latitude, double longitude) async {
    var url = Uri.parse('http://147.102.160.160:8000/locations/add-location/'); // Update with your API endpoint

    // Create the body of the request with latitude and longitude
    Map<String, String> body = {
      "latitude": double.parse(latitude.toStringAsFixed(6)).toString(),
      "longitude": double.parse(longitude.toStringAsFixed(6)).toString(),
    };

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Success: $data');
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Επισήμανση θέσης σάκου"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(37.4835, 21.6479),
                initialZoom: 12.0,
                
                // onTap: (_, p) => setState(() => customMarkers.add(buildPin(p))),
                onTap: (_, p) => addSinglePin(p),
                interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: customMarkers,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                flex:3,
                child: Center(child: customMarkers.isEmpty != true? Text(customMarkers.first.point.latitude.toString()): null)
              ),
              Expanded(
                flex:3,
                child: Center(child: customMarkers.isEmpty != true? Text(customMarkers.first.point.longitude.toString()): null)
              )
            ],
          ),
          Row(

            children: [
              
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  onPressed: _getCurrentLocation,
                  child: const Text('Λήψη τοπεθεσίας GPS'),
                ),
              ),
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  // onPressed: _getCurrentLocation,
                  onPressed: customMarkers.isEmpty != true ? () {
                    sendLocation(customMarkers.first.point.latitude, customMarkers.first.point.longitude);
                  } : null,
                  child: const Text('Αποστολή θέσης σάκου'),
                ),
              ),
              // Expanded(
              //   flex: 3,
              //   child: OutlinedButton(
              //     style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
              //     onPressed: null,
              //     child: const Text('Enabled'),
              //   ),
              // ),
            ],
          ),
          
          const SizedBox(
            height: 50,
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _getCurrentLocation,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


