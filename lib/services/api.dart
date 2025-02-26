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
  String server = "http://147.102.160.160:8000";
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
      query['status'] = 'pending';
      query['created_at__gte'] = queryToday;
      query['created_at__lte'] = queryTomorrow;
    }
    
  }


  Future<int> sendRouteDetails(Map<String, dynamic> routeDetails) async {
    String baseUrl = server + '/route/1/';

    try {
      final uri = Uri.parse(baseUrl);

      

      final response = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(routeDetails),
      );

      if (response.statusCode == 200) {
        return 0;
      } else {
        return 1; // Got an error status code
      }
    } catch (error) {
      return 3; // Failed to connect to the API
    }
  }


  Future<int> updatePinStatus(Map<String, dynamic> pinDetails, int pinId) async {
    String baseUrl = server + '/locations/locations/' + pinId.toString() + '/update/';

    try {
      final uri = Uri.parse(baseUrl);

      

      final response = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(pinDetails),
      );

      if (response.statusCode == 200) {
        return 0;
      } else {
        return 1; // Got an error status code
      }
    } catch (error) {
      return 3; // Failed to connect to the API
    }
  }
  

  Future<List<dynamic>> fetchLatLngPoints() async {
    String baseUrl = server + '/locations/locations/';

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

        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
  }
}