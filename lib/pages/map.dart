import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/api.dart';
import '../utils/custom_marker.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapPage> {

  List<Marker> customMarkers = [];
  List<LatLng> selectedPoints = [];
  Timer? _timer;
  late API _api;
  // Map<LatLng, Color> markerColors = {};
  // Map<LatLng, String> markerBuckets = {};
  

  @override
  void initState() {
    super.initState();

    _api = API(context: context);
    fetchLatLngPoints();
    
  }

  void tapHandler(LatLng markerPoint, int state ) {
    if (state == 1) {
      selectedPoints.add(markerPoint);
    }
    if (state == 0) {
      selectedPoints.remove(markerPoint);
    }
    
    print(selectedPoints);

  }


  Marker buildPin(LatLng point, int bucketInfo, int user, String status) {
    

    return Marker(
      point: point,
      width: 60,
      height: 60,
      child: CustomMarker(
        point: point,
        userId: user,
        status: status,
        buckets: bucketInfo,
        onColorChange: (Color newColor, int state) {
          
            tapHandler(point, state); // Update the color in the main state
          
        },
      ),
    );
  }


  void fetchLatLngPoints() async {
    const String baseUrl = 'http://147.102.160.160:8000/locations/locations/';

    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'status': _api.query['status'],
          'user': _api.query['user'],
          'created_at__gte': _api.query['created_at__gte'],
          'created_at__lte': _api.query['created_at__lte']
        },
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        setState(() {
          
        
        customMarkers = data.map((item) {

            final latitude = double.parse(item['latitude']);
            final longitude = double.parse(item['longitude']);
            final status = item['status'].toString();
            final int buckets = item['buckets'];
            final int user = item['user'];

            LatLng latLng = LatLng(latitude, longitude);
            
            return buildPin(latLng, buckets, user, status);
          }).toList();
        });
        // return markers;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
  }

  void _setShowOption(int opt) {
    _api.setShowOption(opt);
    fetchLatLngPoints();
  }


  // @override
  // void dispose() {
  //   // _timer?.cancel(); // Cancel the timer when widget is disposed
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Επισήμανση θέσης σάκου"),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Expanded(child: Text(_api.pageText)),
            ],
          ),
          Expanded(
            child: FlutterMap(
                    
                    options: const MapOptions(
                      initialCenter: LatLng(37.4835, 21.6479),
                      initialZoom: 12.0,
                      interactionOptions: InteractionOptions(
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
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: selectedPoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      )
                    ],
                  )
          ),
          
          Row(

            children: [
              
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  onPressed: () => _setShowOption(1),
                  child: const Text('Όλα τα δοχεία'),
                ),
              ),
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  onPressed: () => _setShowOption(2),
                  child: const Text('Σημερινά δοχεία'),
                ),
              ),
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  onPressed: () => _setShowOption(3),
                  child: const Text('Μη συλλεχθέντα σημερινά δοχεία'),
                ),
              ),
              
            ],
          ),
          
          const SizedBox(
            height: 50,
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


