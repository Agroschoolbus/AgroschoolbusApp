
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../services/api.dart';
import '../services/gps.dart';

import 'package:agroschoolbus/utils/ui_controller.dart';
import 'package:agroschoolbus/utils/marker_controller.dart';

// 729D37

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title, required this.userId});

  final String title;
  final String userId;

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
  
  Position? _currentPosition;
  late LatLng cur = LatLng(37.4835, 21.6479);

  late UiController ui_ctrl;
  LatLng mapCenter = LatLng(37.4835, 21.6479);
  bool isGPSOn = false;
  bool isAddOn = false;


  Position? _position;
  LatLng? apiPosition;
  
  final GPS _gps = GPS();

  Timer? _refreshTimer; 
  

  
  // Timer? _timer;
  late API _api;


  final List<IconData> menuIcons = [
    Icons.menu,
    Icons.map,
    Icons.location_pin,
    Icons.add_location_alt_rounded,
  ];

  final List<Text> menuLabels = [
    const Text('Επιλογές'),
    const Text('Εργαλεία χάρτη'),
    const Text('Φίλτρα σημείων'),
    const Text('Προσθήκη σημείου'),
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
    markerController = MarkerController(onMarkersUpdated: () {
      setState(() {});
    }, api: _api, context: context);
    _setMapCenter();
    _api.setShowOption(1, widget.userId);
    markerController.fetchMarkers();
    _startRefreshTimer();
  }


  Future<void> _setMapCenter() async {
    Map<String, dynamic> data = await _api.fetchAreaInfo();
    LatLng center = LatLng(double.parse(data['center_lat']), double.parse(data['center_lon']));
    LatLng millCenter = LatLng(double.parse(data['mill_lat']), double.parse(data['mill_lon']));
    setState(() {
      mapCenter = center;
      markerController.factoryLocation = millCenter;
    });
    mapController.move(center, 12.0); // update map
  }

  


  void _setShowOption(int opt) {
    filterPins = opt;
    _api.setShowOption(opt, widget.userId);

    markerController.fetchMarkers();
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


  void addSinglePin(LatLng point) {
    if (!isAddOn || markerController.pinAlreadyExists) {
      return;
    }
    setState(() {
      markerController.buildPinForProducer(point);
      markerController.pinAlreadyExists = true;
    });
  }

  

  void _enableAddLocation() {
    if (isAddOn) {
      setState(() {
        markerController.pinAlreadyExists = false;
        isAddOn = false;
        print(isAddOn);
        markerController.addedMarkers = [];
        markerController.fetchMarkers();
        _startRefreshTimer();
      });
    } else {
      setState(() {
        dynamic obj = {
          "title": "Προσθήκη σημείου",
          "message": "Προσθέστε νέο σημείο είτε χειροκίνητα είτε με χρήση GPS.", 
        };
        ui_ctrl.showDialogBox(obj);
        isAddOn = true;
        print(isAddOn);
        markerController.customMarkers = [];
        _refreshTimer?.cancel();
      });
    }
  }


  void _getCurrentLocation() async {
    Position position = await _gps.determinePosition();
    setState(() {
      _position = position;
      apiPosition = LatLng(_position!.latitude, _position!.longitude);
      if (_position != null) {
        addSinglePin(LatLng(_position!.latitude.toDouble(), _position!.longitude.toDouble()));
      }
    });
  }


  void _getPinInfo() {
    dynamic obj = {
      "title": "Λεπτομέρειες σημείου",
      "bucketsLabel": "Αριθμός κάδων",
      "bagsLabel": "Αριθμός σάκων",
      "dropdownOptions": ["Ελαιουργείο 1", "Ελαιουργείο 2", "Ελαιουργείο 3"],
      "confirmText": "Αποστολή",
      "cancelText": "Ακύρωση",
      "onConfirm": (dynamic obj) {
        sendPinDetails(obj);
      }
    };
    ui_ctrl.showInputDialog(obj);
  }

  
  void sendPinDetails(dynamic obj) async {
    dynamic pinDetails = {
      "latitude": markerController.addedMarkers[0].point.latitude,
      "longitude": markerController.addedMarkers[0].point.longitude,
      "buckets": obj['buckets'],
      "bags": obj['bags'],
      "mill": "mill_1",
      "userId": widget.userId
    };
    int res = await _api.sendLocation(pinDetails);
    showDialogOnSend(res);
    _enableAddLocation();
  }

  void showDialogOnSend(int res) {
    dynamic obj;
    if (res == 0) {
      obj = {
        "title": "Επιτυχία",
        "message": "Το νεό σημείο αποθηκεύτηκε στον διακομιστή", 
      };
    } else if (res == 1) {
      obj = {
        "title": "Παρουσιάστηκε πρόβλημα",
        "message": "Ο διακομιστής απάντησε με μη αποδεκτό κωδικό.", 
      };
    } else {
      obj = {
        "title": "Παρουσιάστηκε πρόβλημα",
        "message": "Αδυναμία σύνδεσης στον διακομιστή", 
      };
    }
    ui_ctrl.showDialogBox(obj);
  }


  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      setState(() {
        markerController.fetchMarkers();
      });
    });
  }

  List<Marker> getFactoryMarker() {
    return [
      Marker(
        point: markerController.factoryLocation, 
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

  @override
  void dispose() {
    _refreshTimer?.cancel(); 
    super.dispose();
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
              options: MapOptions(
                initialCenter: mapCenter, //LatLng(37.4835, 21.6479),
                initialZoom: 12.0,
                onTap: (_, p) => addSinglePin(p),
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
                    ...markerController.addedMarkers
                  ]
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
            FloatingActionButton(
              onPressed: () {
                // Center map action
                _enableAddLocation();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "directions",
              tooltip: 'Προσθήκη νέου σημείου',
              child: Icon(
                Icons.add_location_alt_outlined,
                color: isAddOn ? Color.fromARGB(255, 250, 148, 6): Color.fromARGB(255, 255, 255, 255),
                ),
            ),
            const SizedBox(height: 10.0),
            if (isAddOn)
            FloatingActionButton(
              onPressed: () {
                // Center map action
                // _fetchDirections();
                // _togglePositionSubscription();
                _getCurrentLocation();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "navigation",
              tooltip: 'Ενεργοποίηση GPS',
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

      if (markerController.pinAlreadyExists)
      Positioned(
        bottom: 30.0,
        right: 10.0,
        child: Column(
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                // Center map action
                // _enableOrDisableRoute(1);
                _getPinInfo();
              },
              backgroundColor: const Color.fromARGB(255, 114, 157, 55),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              heroTag: "input",
              tooltip: 'Εισαγωγή',
              label: const Text('Προσθήκη'),
              icon: Icon(
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
                // cancelRouteRequest();
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


