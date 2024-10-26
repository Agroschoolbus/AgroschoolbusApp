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
  LatLng? apiPosition;

  final ButtonStyle b_style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  

  late Future<List<Marker>> customMarkers;

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


  
  final String baseUrl = 'http://147.102.160.160:8000/locations/locations/';

  Future<List<Marker>> fetchLatLngPoints() async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'status': 'False',
        },
      );
      // final response = await http.get(Uri.parse(baseUrl));
      final response = await http.get(uri);

      // Check if request was successful
      if (response.statusCode == 200) {
        // Decode the JSON data
        final List<dynamic> data = json.decode(response.body);
        
        // Map each item to a Marker using latitude and longitude
        List<Marker> markers = data.map((item) {
          final latitude = double.parse(item['latitude']);
          final longitude = double.parse(item['longitude']);
          final id = item['id'].toString();  // Assuming 'id' is in the JSON
          LatLng latLng = LatLng(latitude, longitude);
          return buildPin(latLng);
        }).toList();

        return markers;
        
        // Map each item to LatLng and return as a List
        // return data.map((item) => LatLng.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Call the fetchMarkers method when the page gets initiated
    customMarkers = fetchLatLngPoints();
    
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
            child: FutureBuilder<List<Marker>>(
              future: customMarkers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No markers found'));
                } else {
                  // Extract the LatLng points from the snapshot
                  final List<Marker> markers = snapshot.data!;

                  return FlutterMap(
                    
                    options: MapOptions(
                      initialCenter: const LatLng(37.4835, 21.6479),
                      initialZoom: 12.0,
                      
                      // onTap: (_, p) => setState(() => customMarkers.add(buildPin(p))),
                      // onTap: (_, p) => addSinglePin(p),
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
                        markers: markers,
                      ),
                    ],
                  );
                }
              }
            ),
          ),
          
          Row(

            children: [
              
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  onPressed: fetchLatLngPoints,
                  child: const Text('Test'),
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


