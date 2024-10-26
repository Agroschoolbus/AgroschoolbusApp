import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';


class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapPage> {

  late Future<List<Marker>> customMarkers;
  Timer? _timer;
  final String baseUrl = 'http://147.102.160.160:8000/locations/locations/';

  int option = 1;
  Map<String, String> query = {
    'user': '',
    'status': '',
    'created_at__gte': '',
    'created_at__lte': ''
  };


  Marker buildPin(LatLng point, Color pinColor) => Marker(
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
          child: Icon(Icons.location_pin, size: 30, color: pinColor),
        ),
      );

  Future<List<Marker>> fetchLatLngPoints() async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'status': query['status'],
          'user': query['user'],
          'created_at__gte': query['created_at__gte'],
          'created_at__lte': query['created_at__lte']
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
          Color pinColor;

          final latitude = double.parse(item['latitude']);
          final longitude = double.parse(item['longitude']);
          final status = item['status'].toString();  // Assuming 'id' is in the JSON
          
          if (status == 'true') {
            pinColor = const Color.fromARGB(255, 46, 135, 1);
          }
          else {
            pinColor = const Color.fromARGB(255, 201, 4, 4);
          }
          LatLng latLng = LatLng(latitude, longitude);
          return buildPin(latLng, pinColor);
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
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _fetchAndSetMarkers(); // Fetch markers every minute
    });
  }

  void _fetchAndSetMarkers() {
    setState(() {
      customMarkers = fetchLatLngPoints();
    });
  }
  
  String getToday(DateTime today) {
    String todayYear = today.year.toString();
    String todayMonth = today.month.toString();
    String todayDay = (today.day - 1).toString();
    String queryToday = "$todayYear-$todayMonth-$todayDay";

    return queryToday;
  }

  String getTomorrow(DateTime today) {
    String tomorrowYear = today.year.toString();
    String tomorrowMonth = today.month.toString();
    String tomorrowDay = (today.day + 1).toString();
    String queryTomorrow = "$tomorrowYear-$tomorrowMonth-$tomorrowDay";

    return queryTomorrow;
  }

  void setShowOption(int opt) {
    option = opt;
    if (opt == 1) {
      query['user'] = '';
      query['status'] = '';
      query['created_at__gte'] = '';
      query['created_at__lte'] = '';
    }
    if (opt == 2) {
      DateTime today = DateTime.now();
      String queryToday = getToday(today);
      String queryTomorrow = getTomorrow(today);
      query['user'] = '';
      query['status'] = '';
      query['created_at__gte'] = queryToday;
      query['created_at__lte'] = queryTomorrow;
    }
    if (opt == 3) {
      DateTime today = DateTime.now();
      String queryToday = getToday(today);
      String queryTomorrow = getTomorrow(today); 
      query['user'] = '';
      query['status'] = 'False';
      query['created_at__gte'] = queryToday;
      query['created_at__lte'] = queryTomorrow;
    }
    _fetchAndSetMarkers();
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
                  onPressed: () => setShowOption(1),
                  child: const Text('Όλα τα δοχεία'),
                ),
              ),
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  onPressed: () => setShowOption(2),
                  child: const Text('Σημερινά δοχεία'),
                ),
              ),
              Expanded(
                flex: 6,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                  onPressed: () => setShowOption(3),
                  child: const Text('Μη συλλεχθέντα σημερινά δοχεία'),
                ),
              ),
              
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


