import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../services/api.dart';


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
  

  void fetch() async {
    await _api.fetchLatLngPoints();
  }


  @override
  void initState() {
    super.initState();

    _api = API(context: context);
    _api.fetchLatLngPoints().then((markers) {
      setState(() {
        customMarkers = markers;
      });
    });
  }


  void _setShowOption(int opt) {
    _api.setShowOption(opt);

    _api.fetchLatLngPoints().then((markers) {
      setState(() {
        customMarkers = markers;
      });
    });

    _api.fetchDirections().then((directions) {
      setState(() {
        selectedPoints = directions;
        
      });
    });

    
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


