import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../services/api.dart';

// 729D37

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapPage> {

  List<Marker> customMarkers = [];
  List<LatLng> selectedPoints = [];
  int showButtons = 0;
  int tileIndex = 0;
  bool directionsOn = false;
  final MapController mapController = MapController();
  
  // Timer? _timer;
  late API _api;


  final List<IconData> menuIcons = [
    Icons.menu,
    Icons.map,
    Icons.location_pin,
    Icons.route,
  ];

  final List<Text> menuLabels = [
    const Text('Επιλογές'),
    const Text('Εργαλεία χάρτη'),
    const Text('Φίλτρα σημείων'),
    const Text('Διαδρομή'),
  ];

  List<String> tileUrls = [
    'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
    'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  ];
  

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
  }

  void _fetchDirections() {
    if (directionsOn) {
      setState(() {
        selectedPoints.clear();
        _api.clearSelectedPoints();
      });
      directionsOn = false;
    } else {
      _api.fetchDirections().then((directions) {
        setState(() {
          selectedPoints = directions;
          
        });
      });
      directionsOn = true;
    }
  }

  void _toggleButtons() {
    setState(() {
      if (showButtons == 3) {
        showButtons = 0;
      } else {
        showButtons ++;
      }
    });
  }

  void _changeTiles() {
    setState(() {
      if (tileIndex == 2) {
        tileIndex = 0;
      } else {
        tileIndex ++;
      }
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
      body: Stack(
        children:[Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Row(
          //   children: [
          //     Expanded(child: Text(_api.pageText)),
          //   ],
          // ),
          
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                initialCenter: LatLng(37.4835, 21.6479),
                initialZoom: 12.0,
                interactionOptions: InteractionOptions(
                  flags: ~InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                    
                    // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // userAgentPackageName: 'com.example.app',
                    urlTemplate: tileUrls[tileIndex],
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                    userAgentPackageName: 'com.example.app',
                    // attribution: '© Google Maps',
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
          
        ],
      ),
      if (showButtons == 1)
      Positioned(
        bottom: 200.0,
        left: 20.0,
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                // Zoom in action
                mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom + 1,
                );
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "zoomIn",
              tooltip: 'Μεγέθυνση',
              child: const Icon(Icons.zoom_in),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Zoom out action
                mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom - 1,
                );
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "zoomOut",
              tooltip: 'Σμίκρυνση',
              child: const Icon(Icons.zoom_out),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                mapController.move(
                  const LatLng(37.4835, 21.6479),
                  12.0,
                );
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "centerMap",
              tooltip: 'Εστίαση',
              child: const Icon(Icons.my_location),
            ),
            
            
          ],
        ),
      ),
      if (showButtons == 2)
      Positioned(
        bottom: 200.0,
        left: 20.0,
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _setShowOption(1);
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "yesterday",
              tooltip: 'Όλα τα δοχεία',
              child: const Icon(Icons.calendar_month),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _setShowOption(2);
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "today",
              tooltip: 'Σημερινά δοχεία',
              child: const Icon(Icons.today),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _setShowOption(3);
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "today1",
              tooltip: 'Μη συλλεχθέντα, σημερινά δοχεία',
              child: const Icon(Icons.calendar_view_week),
            ),
          ])
      ),
      if (showButtons == 3)
      Positioned(
        bottom: 200.0,
        left: 20.0,
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _fetchDirections();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "directions",
              tooltip: 'Δημιουργία διαδρομής',
              child: const Icon(Icons.directions),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                // _fetchDirections();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "navigation",
              tooltip: 'Πλοήγηση',
              child: const Icon(Icons.navigation),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _changeTiles();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "terrain",
              tooltip: 'Αλλαγή χάρτη',
              child: const Icon(Icons.terrain),
            ),
          ]
        )
      ),

      Positioned(
        bottom: 30.0,
        left: 20.0,
        child: Column(
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                // Center map action
                _toggleButtons();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "menu",
              tooltip: 'Επιλογές',
              label: menuLabels[showButtons],
              icon: Icon(menuIcons[showButtons]),
            ),
          ]
        )
      ),
      
      ])
      
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


