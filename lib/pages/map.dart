import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/api.dart';

class CustomMarker extends StatefulWidget {
  final LatLng point;
  final Color initialColor;
  final String bucketInfo;
  final Function(Color) onColorChange;

  const CustomMarker({
    Key? key,
    required this.point,
    required this.initialColor,
    required this.bucketInfo,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _CustomMarkerState createState() => _CustomMarkerState();
}

class _CustomMarkerState extends State<CustomMarker> {
  late Color markerColor;

  @override
  void initState() {
    super.initState();
    markerColor = widget.initialColor;
  }

  void toggleColor() {
    setState(() {
      if (markerColor == const Color.fromARGB(255, 201, 4, 4)) {
        markerColor = const Color.fromARGB(255, 21, 13, 253);
      } else if (markerColor == const Color.fromARGB(255, 21, 13, 253)) {
        markerColor = const Color.fromARGB(255, 201, 4, 4);
      }
          
    });
    widget.onColorChange(markerColor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.bucketInfo,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.white.withOpacity(0.7),
            ),
          ),
          Icon(
            Icons.location_pin,
            size: 30,
            color: markerColor,
          ),
        ],
      ),
    );
  }
}



class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapPage> {

  List<Marker> customMarkers = [];
  Timer? _timer;
  late API _api;
  Map<LatLng, Color> markerColors = {};
  Map<LatLng, String> markerBuckets = {};
  

  @override
  void initState() {
    super.initState();

    _api = API(context: context);
    fetchLatLngPoints();
    
  }

  // void buildMarkers() {
  //   setState(() {
  //     customMarkers = customMarkers.map((marker) {
  //       return buildPin(marker.point);
  //     }).toList();
  //   });

    
  // }

  // void changeMarkerColor(LatLng point) {
    
  //     if (markerColors[point] == const Color.fromARGB(255, 201, 4, 4)) {
  //       markerColors[point] = Color.fromARGB(255, 21, 13, 253);
  //     } else if (markerColors[point] == const Color.fromARGB(255, 21, 13, 253)) {
  //       markerColors[point] = Color.fromARGB(255, 201, 4, 4);
  //     }
      
      
  //     buildMarkers();
    
  // }

  // Marker buildPin(LatLng point) => Marker(
  //   point: point,
  //   width: 60,
  //   height: 60,
  //   child: GestureDetector(
  //     onTap: () {
        
  //       changeMarkerColor(point);
        
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Σάκος χρήστης με id 2'),
  //           duration: Duration(seconds: 1),
  //           showCloseIcon: true,
  //         ),
  //       );
  //     },
  //     child: 
  //       Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             '${markerBuckets[point]}',
  //             style: TextStyle(
  //               fontSize: 10,
  //               color: Colors.black,
  //               fontWeight: FontWeight.bold,
  //               backgroundColor: Colors.white.withOpacity(0.7),
  //             ),
  //           ),
  //           Icon(
  //             Icons.location_pin,
  //             size: 30,
  //             color: markerColors[point],
  //           ),
  //         ],
  //       ),
  //     // Icon(Icons.location_pin, size: 30, color: pinColor),
  //   ),
  // );


  Marker buildPin(LatLng point) {
    Color color = markerColors[point] ?? const Color.fromARGB(255, 201, 4, 4);
    String bucketInfo = markerBuckets[point] ?? '';

    return Marker(
      point: point,
      width: 60,
      height: 60,
      child: CustomMarker(
        point: point,
        initialColor: color,
        bucketInfo: bucketInfo,
        onColorChange: (Color newColor) {
          setState(() {
            markerColors[point] = newColor; // Update the color in the main state
          });
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

            String buck = "";
            if (buckets < 2) {
              buck = user.toString() + " - 1 Κάδος";
            } else {
              buck = user.toString() + " - " + buckets.toString() + " κάδοι";
            }
            LatLng latLng = LatLng(latitude, longitude);
            if (status == 'true') {
              markerColors[latLng] = const Color.fromARGB(255, 46, 135, 1);
            }
            else {
              markerColors[latLng] = const Color.fromARGB(255, 201, 4, 4);
            }
            markerBuckets[latLng] = buck;
            return buildPin(latLng);
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


