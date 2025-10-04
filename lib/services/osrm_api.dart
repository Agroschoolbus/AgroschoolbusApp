import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';



class OsrmApi {
  List<LatLng> selectedPoints = [];
  List<LatLng> directions = [];
  String route = "";



  void clearSelectedPoints() {
    selectedPoints.clear();
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
    const osrm = 'https://pressoil.agroschoolbus.eu/osrm/trip/v1/driving/';

    
    String points = addPointsToString();
    String url = osrm + points;
    print(url);

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
        route = encodedPolyline;
        return decodePolyline(encodedPolyline);
        // parseOSRMResponse(data);
      }
      
      // return directions;
      return [];
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
  }

}