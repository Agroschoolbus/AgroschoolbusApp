
import 'package:agroschoolbus/services/osrm_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../services/api.dart';
import '../services/gps.dart';

import '../utils/marker_data.dart';
import 'package:agroschoolbus/utils/ui_controller.dart';
import 'package:agroschoolbus/utils/marker_controller.dart';

import 'dart:math';
// 729D37

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapPage> {

  late MarkerController markerController;
  List<LatLng> selectedPoints = [];
  int showButtons = 0;
  int tileIndex = 0;
  int filterPins = 1;
  final MapController mapController = MapController();
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  late LatLng cur = LatLng(37.4835, 21.6479);

  late UiController ui_ctrl;
  bool isGPSOn = false;
  Timer? _locationTimer;
  Timer? _gpsSimulatorTimer;
  Position? currentSimulatedPosition;
  bool _isProcessingLocationUpdate = false; // to avoid overlapping calls when sending GPS point during navigation

  int routePartIndex = 0;
  double randomDouble = 0.0;
  int tempIndex = 0;

  bool mapZoomedForNavigation = false;
  
  // Timer? _timer;
  late API _api;
  late OsrmApi osrm_api;


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


  final List<IconData> routeButton = [
    Icons.play_arrow,
    Icons.stop,
  ];

  int routeStatus = 0; 
  

  void fetch() async {
    await _api.fetchLatLngPoints();
  }

  @override
  void initState() {
    super.initState();

    ui_ctrl = UiController(context: context);
    _api = API(context: context);
    osrm_api = OsrmApi();
    markerController = MarkerController(onMarkersUpdated: () {
      setState(() {});
    }, api: _api, context: context);
    markerController.fetchMarkers();
    _startLocationTimer();
    
  }

  bool _dialogShown = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getTruckCapacity();
      });
    }
    
  }

  
  void getTruckCapacity() {
    dynamic obj = {
      "title": "Χωρητικότητα φορτηγού",
      "message": "Παρακαλώ, εισάγετε τη χωρητικότητα του φορτηγού σε μονάδες. Ένας κάδος αντιστοιχεί σε 1 μονάδα ενώ ένας σάκος σε 2.",
      "capacityLabel": "Θετικός, ακέραιος αριθμός",
      "cancelText": "Ακύρωση",
      "onConfirm": (capacity) {
        markerController.truckCapacity = int.parse(capacity);        
      },
      "ConfirmText": "Συνέχεια"
    };
    ui_ctrl.showInputDialog(obj);
    
  }


  void _setShowOption(int opt) {
    filterPins = opt;
    _api.setShowOption(opt);

    markerController.fetchMarkers();
  }


  Future<void> _sendRouteInfo() async {
    Map<String, dynamic> routeDetails;
    if (_currentPosition != null) {
      routeDetails = {
        "data": osrm_api.route,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude
      };
    }
    else {
      routeDetails = {
        "data": osrm_api.route,
      };
    }
    int res = await _api.sendRouteDetails(routeDetails);
    
    dynamic obj;
    if (res == 0) {
      obj = {
        "title": "Επιτυχία",
        "message": "Η διαδρομή αρχικοποιήθηκε επιτυχώς. Οι λεπτομέρειες έφτασαν στον διακομιστή.", 
      };
      
    }
    if (res == 1) {
      
      obj = {
        "title": "Παρουσιάστηκε πρόβλημα!",
        "message": "Η αρχικοποίηση της διαδρομής απέτυχε. Η απάντηση του διακομιστή δεν ήταν η αναμενόμενη.", 
        "onConfirm": () {
          _enableOrDisableRoute(0);
        },
        "confirmText": "Κατάλαβα",
      };
    }
    if (res == 2) {
      obj = {
        "title": "Παρουσιάστηκε πρόβλημα!",
        "message": "Η αρχικοποίηση της διαδρομής απέτυχε. Αδυναμία σύνδεσης στον διακομιστή.", 
        "onConfirm": () {
          _enableOrDisableRoute(0);
        },
        "confirmText": "Κατάλαβα",
      };
    }
    
    ui_ctrl.showDialogBox(obj);
  }


  Future<void> _fetchRoute() async {
    
    if (markerController.selectedPoints.length < 1) {
      dynamic obj = {
        "title": "Ελάχιστα σημεία",
        "message": "Πρέπει να επιλέξετε περισσότερα σημεία ενδιαφέροντος", 
      };
      ui_ctrl.showDialogBox(obj);
      return;
    }
    if (selectedPoints.isEmpty) {
      osrm_api.selectedPoints = markerController.selectedPoints;
      List<List<double>> coordinates = await osrm_api.fetchDirections();
      setState(() {
        markerController.isDirectionsOn = true;
        selectedPoints = coordinates
            .map((coord) => LatLng(coord[0], coord[1]))
            .toList();
      });
    } else {
      setState(() {
        markerController.isDirectionsOn = false;
        selectedPoints = [];
        
        //_api.selectedPoints = [];
      });
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


  void _startLocationTimer() {
    _locationTimer = Timer.periodic(Duration(minutes: 1), (timer) async {

      if (_isProcessingLocationUpdate || _currentPosition == null) return;
      
      _isProcessingLocationUpdate = true;

      Map<String, dynamic> routeDetails = {
        "data": osrm_api.route,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude
      };
      await _api.sendRouteDetails(routeDetails);

      try {
        // throw Exception('Forced failure'); // Test catch block
        await _api.sendRouteDetails(routeDetails);
      } catch (e) {
        dynamic obj = {
          "title": "Παρουσιάστηκε πρόβλημα",
          "message": "Η τρέχουσα θέση δεν είναι δυνατό να ανανεωθεί στον διακομιστή.", 
        };
        ui_ctrl.showDialogBox(obj);
      } finally {
        _isProcessingLocationUpdate = false; 
      }
      
    });
  }

  Future<void> _setupLocationStream() async {
    try {
      // Await the stream initialization
      _positionStream = await initializeLocationStream();
      _positionSubscription = _positionStream!.listen((Position position) {
        setState(() {
          _currentPosition = position;
          if (!mapZoomedForNavigation) {
            mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 15);
            mapZoomedForNavigation = true;
          } else {
            mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), mapController.camera.zoom);
          }
        });
      });
      setState(() {
        isGPSOn = true;
      });
    } catch (e) {
      print("Error initializing location stream: $e");
    }
  }

  void _stopListening() {
    if (_positionSubscription != null) {
      setState(() {
        isGPSOn = false;
      });
      
      _positionSubscription!.cancel();
      _positionSubscription = null;
      
      _currentPosition = null;
      centerMap();
    }
  }

  // void _togglePositionSubscription() {
  //   if (_positionSubscription == null) {
  //     _setupLocationStream();
  //   } else {
  //     _stopListening();
  //   }
  // }


  void _enableRoute() {
    
    dynamic obj = {
      "title": "Εκκίνηση διαδρομής",
      "message": "Πρόκειται να ξεκινήσετε μία νέα διαδρομή.",
      "icon": Icons.warning, 
      "confirmText": "Συνέχεια",
      "cancelText": "Όχι",
      "onCancel": () {
        return;
      },
      "onConfirm": () async {
        setState(() {
          routeStatus = 1;
        });
        await _setupLocationStream();
        _sendRouteInfo();
        // startGPSSimulatorTimer();
      },
    };
    ui_ctrl.showDialogBox(obj);
  }


  void _completeRoute() {
    _stopListening();
    setState(() {
      routeStatus = 0;
      selectedPoints = [];
      markerController.isDirectionsOn = false;
      markerController.completeRoute();
    });
    _locationTimer?.cancel();
    routePartIndex = 0;
  }

  void cancelRoute() {
    _stopListening();
    setState(() {
      routeStatus = 0;
      selectedPoints = [];
      markerController.isDirectionsOn = false;
      markerController.cancelRoute();
    });
    _locationTimer?.cancel();
    routePartIndex = 0;
  }

  void cancelRouteRequest() {
    dynamic obj = {
      "title": "Ακύρωση διαδρομής",
      "message": "Τα σημεία που συλλέχθηκαν θα θεωρηθούν ως μη συλλεχθέντα.", 
      "onConfirm": () {
        cancelRoute();
      },
      "confirmText": "Συνέχεια",
      "onCancel": () {},
      "onCancelText": "Άκυρο",
    };
    ui_ctrl.showDialogBox(obj);
  }

  void completeRouteRequest() {
    markerController.checkIfAllCollected();
    String message;
    if (!markerController.allCollected) {
      message = "Δεν έχουν συλλεχθεί όλα τα σημεία. Θέλετε να ολοκληρώσετε τη διαδρομή παρ' όλα αυτά;";
    } else {
      message = "Πρόκειται να ολοκληρώσετε τη διαδρομή.";
    }
    dynamic obj = {
      "title": "Ολοκλήρωση διαδρομής",
      "message": message, 
      "onConfirm": () {
        _completeRoute();
      },
      "confirmText": "Συνέχεια",
      "onCancel": () {},
      "onCancelText": "Άκυρο",
    };
    ui_ctrl.showDialogBox(obj);
  }


  void _enableOrDisableRoute(int status) {
    
      if ((routeStatus == 1 && status == 1) || status == 0) {
        completeRouteRequest();
      }
      else {
        _enableRoute();
      }
  }


  List<LatLng> getPartOfRoute() {
    if (selectedPoints.length == 0) {
      return [];
    }
    double temp = selectedPoints.length / 10;
    int partSize = temp.toInt();

    int start = routePartIndex * partSize;
    int end = start + partSize;
    
    if (end > selectedPoints.length) {
      return selectedPoints.sublist(start, selectedPoints.length);
    }
    return selectedPoints.sublist(start, end);
  }

  void _loadNextRoutePart() {
    setState(() {
      
      routePartIndex += 1;
      if (routePartIndex > 10) {
        routePartIndex = 10;
      }
    });
  }

  void _loadPreviousRoutePart() {
    setState(() {
      
      routePartIndex -= 1;
      if (routePartIndex < 0) {
        routePartIndex = 0;
      }
    });
  }
  
    

  List<Marker> getCarMarker() {
    if (_currentPosition == null) return [];
    return [
      Marker(
        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 
        width: 50,
        height: 50,
        child: Transform.rotate(
                angle: _currentPosition!.heading, // Rotation in radians
                child: Image.asset(
                  'assets/icons/car.png',
                  width: 40.0,
                  height: 40.0,
                ),
              ),
      ),
    ];
  }

  List<Marker> getFactoryMarker() {
    return [
      Marker(
        point: LatLng(37.457002, 21.647583), 
        width: 50,
        height: 50,
        child: Transform.rotate(
                angle: 0,
                child: Image.asset(
                  'assets/icons/factory.png',
                  width: 40.0,
                  height: 40.0,
                ),
              ),
      ),
    ];
  }


  void centerMap() {
    mapController.move(const LatLng(37.4835, 21.6479), 12.0);
    mapZoomedForNavigation = false;
  }
  
  
  void startGPSSimulatorTimer() {
    _gpsSimulatorTimer = Timer.periodic(Duration(seconds: 2), (timer) async {

      LatLng p = selectedPoints[tempIndex];
      if (!mapZoomedForNavigation) {
        mapController.move(p, 15);
        mapZoomedForNavigation = true;
      } else {
        mapController.move(p, mapController.camera.zoom);
      }
      tempIndex += 1;
      if (tempIndex > selectedPoints.length) {
        tempIndex = selectedPoints.length - 1;
      }
    });
  }

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
                  markers: [
                    ...getFactoryMarker(),
                    ...markerController.customMarkers,
                    ...getCarMarker(),
                  ]
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: getPartOfRoute(),
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                    if (routeStatus != 1)
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
                centerMap();
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
              child: Icon(
                Icons.calendar_month,
                color: filterPins == 1 ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
              ),
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
              child: Icon(
                Icons.today,
                color: filterPins == 2 ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
              ),
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
              child: Icon(
                Icons.calendar_view_week,
                color: filterPins == 3 ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ])
      ),
      if (showButtons == 3)
      Positioned(
        bottom: 200.0,
        left: 20.0,
        child: Column(
          children: [
            if (routeStatus == 1)
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _loadPreviousRoutePart();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "previousRoutePart",
              tooltip: 'Προηγούμενο μέρος διαδρομής',
              child: const Icon(Icons.skip_previous),
            ),
            if (routeStatus == 1)
            const SizedBox(height: 10.0),
            if (routeStatus == 1)
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _loadNextRoutePart();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "routePart",
              tooltip: 'Επόμενο μέρος διαδρομής',
              child: const Icon(Icons.skip_next),
            ),
            if (routeStatus == 1)
            const SizedBox(height: 20.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                getTruckCapacity();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "points",
              tooltip: 'Αυτόματη επιλογή σημείων',
              child: const Icon(
                Icons.display_settings_outlined,
                color: Color.fromARGB(255, 255, 255, 255),
                ),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                markerController.chooseMarkersToCollect();
                _fetchRoute();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "points",
              tooltip: 'Αυτόματη επιλογή σημείων',
              child: const Icon(
                Icons.perm_data_setting_outlined,
                color: Color.fromARGB(255, 255, 255, 255),
                ),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _fetchRoute();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "directions",
              tooltip: 'Δημιουργία διαδρομής',
              child: Icon(
                Icons.directions,
                color: markerController.isDirectionsOn ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
                ),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                // Center map action
                // _fetchDirections();
                // _togglePositionSubscription();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "navigation",
              tooltip: 'Πλοήγηση',
              child: Icon(
                Icons.navigation,
                color: isGPSOn ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
              ),
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

      if (markerController.isDirectionsOn)
      Positioned(
        bottom: 30.0,
        right: 80.0,
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _enableOrDisableRoute(1);
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "start",
              tooltip: 'Εκκίνηση',
              child: Icon(
                routeButton[routeStatus],
                color: filterPins == 2 ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            
          ]
        )
      ),

      if (markerController.isDirectionsOn)
      Positioned(
        bottom: 30.0,
        right: 20.0,
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                // Center map action
                cancelRouteRequest();
                // _enableOrDisableRoute(0);
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "stop",
              tooltip: 'Ακύρωση',
              child: Icon(
                Icons.cancel,
                color: filterPins == 2 ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            
          ]
        )
      ),
      
      ])
      
    );
  }
}


