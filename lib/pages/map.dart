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

  late Future<List<Marker>> customMarkers;
  Timer? _timer;
  late API _api;
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _api = API(context: context);
    customMarkers = _api.fetchLatLngPoints();
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _fetchAndSetMarkers(); // Fetch markers every minute
    });
  }

  void _fetchAndSetMarkers() {
    setState(() {
      customMarkers = _api.fetchLatLngPoints();
    });
  }

  void _setShowOption(int opt) {
    setState(() {
      _api.setShowOption(opt);
      customMarkers = _api.fetchLatLngPoints();
    });
  }

  void changeQuery() {
    setState(() {
      _fetchAndSetMarkers();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

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
            child: FutureBuilder<List<Marker>>(
              future: customMarkers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No markers found'));
                } else {
                  // Extract the LatLng points from the snapshot
                  final List<Marker> markers = snapshot.data!;

                  return FlutterMap(
                    
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


