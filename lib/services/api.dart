import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/custom_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';



class API {
  final BuildContext context;
  String pageText='';
  List<Marker> customMarkers = [];
  List<LatLng> selectedPoints = [];
  List<LatLng> directions = [];
  Map<String, String> query = {
    'user': '',
    'status': '',
    'created_at__gte': '',
    'created_at__lte': ''
  };

  API({required this.context});

  String getToday(DateTime today) {
    DateTime yesterday = today.subtract(Duration(days: 1));
    String todayYear = yesterday.year.toString();
    String todayMonth = yesterday.month.toString().padLeft(2, '0');
    String todayDay = yesterday.day.toString().padLeft(2, '0');
    String queryToday = "$todayYear-$todayMonth-$todayDay";

    return queryToday;
  }

  String getTomorrow(DateTime today) {
    DateTime tomorrow = DateTime(today.year, today.month, today.day + 1);
    String tomorrowYear = tomorrow.year.toString();
    String tomorrowMonth = tomorrow.month.toString().padLeft(2, '0');
    String tomorrowDay = tomorrow.day.toString().padLeft(2, '0');
    String queryTomorrow = "$tomorrowYear-$tomorrowMonth-$tomorrowDay";

    return queryTomorrow;
  }

  void setShowOption(int opt) {
    if (opt == 1) {
      pageText = "Στον χάρτη παρουσιάζονται όλα τα δοχεία συλλογής";
      query['user'] = '';
      query['status'] = '';
      query['created_at__gte'] = '';
      query['created_at__lte'] = '';
    }
    if (opt == 2) {
      pageText = "Στον χάρτη παρουσιάζονται όλα τα σημερινά δοχεία συλλογής";
      DateTime today = DateTime.now();
      String queryToday = getToday(today);
      String queryTomorrow = getTomorrow(today);
      query['user'] = '';
      query['status'] = '';
      query['created_at__gte'] = queryToday;
      query['created_at__lte'] = queryTomorrow;
    }
    if (opt == 3) {
      pageText = "Στον χάρτη παρουσιάζονται όλα τα σημερινά, μη συλλεχθέντα δοχεία συλλογής";
      DateTime today = DateTime.now();
      String queryToday = getToday(today);
      String queryTomorrow = getTomorrow(today); 
      query['user'] = '';
      query['status'] = 'False';
      query['created_at__gte'] = queryToday;
      query['created_at__lte'] = queryTomorrow;
    }
    
  }

  void clearSelectedPoints() {
    selectedPoints.clear();
  }

  void tapHandler(LatLng markerPoint, int state ) {
    if (state == 1) {
      selectedPoints.add(markerPoint);
    }
    if (state == 0) {
      selectedPoints.remove(markerPoint);
    }
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
          
            tapHandler(point, state);
          
        },
      ),
    );
  }


  String addPointsToString() {
    String points = "";
    for (var elem in selectedPoints) {
      points += elem.longitude.toString();
      points += ',';
      points += elem.latitude.toString();
      points += ';';
    }
    points = removeLastCharacter(points);
    // points += '?steps=true';
    return points;
  }


  String removeLastCharacter(String input) {
    if (input.isNotEmpty) {
      return input.substring(0, input.length - 1);
    } else {
      return input; 
    }
  }



  void parseOSRMResponse(Map<String, dynamic> decoded) {
    final List<dynamic> routes = decoded['routes'];

    var route = routes[0];

    final List<dynamic> legs = route['legs'];
    for (var leg in legs) {
      final List<dynamic> steps = leg['steps'];

      for (var step in steps) {
        

        final List<dynamic> intersections = step['intersections'];
        for (var inter in intersections) {
          final List<dynamic> ll = inter['location'];
          directions.add(LatLng(ll[1], ll[0]));
        }
        
      }
    }
  }


  List<List<double>> decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> points = polylinePoints.decodePolyline(encodedPolyline);

    return points.map((point) => [point.latitude, point.longitude]).toList();
  }

  Future<List<List<double>>> fetchDirections() async {
    const osrm = 'http://147.102.160.160:5000/trip/v1/driving/';

    
    String points = addPointsToString();
    String url = osrm + points;

    try {
      final uri = Uri.parse(url).replace(
        queryParameters: {
          'overview': "full",
          'geometries': "polyline",
          // 'steps': "true",
          'roundtrip': "true"
        },
      );
      // print(uri);
      final response = await http.get(uri);

      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final encodedPolyline = data['trips'][0]['geometry'];
        return decodePolyline(encodedPolyline);
        // parseOSRMResponse(data);
      }
      
      // return directions;
      return [];
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
  }
  

  Future<List<dynamic>> fetchLatLngPoints() async {
    const String baseUrl = 'http://147.102.160.160:8000/locations/locations/';

    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'status': query['status'],
          'user': query['user'],
          'created_at__gte': query['created_at__gte'],
          'created_at__lte': query['created_at__lte']
        },
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        
          
        
        // customMarkers = data.map((item) {

        //     final latitude = double.parse(item['latitude']);
        //     final longitude = double.parse(item['longitude']);
        //     final status = item['status'].toString();
        //     final int buckets = item['buckets'];
        //     final int user = item['user'];

        //     LatLng latLng = LatLng(latitude, longitude);
            
        //     return buildPin(latLng, buckets, user, status);
        //   }).toList();
        
        // return customMarkers;
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
  }
}