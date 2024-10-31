import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


class API {
  final BuildContext context;
  String pageText='';
  Map<String, String> query = {
    'user': '',
    'status': '',
    'created_at__gte': '',
    'created_at__lte': ''
  };

  API({required this.context});

  Marker buildPin(LatLng point, Color pinColor, String buckets) => Marker(
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
      child: 
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              buckets,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white.withOpacity(0.7),
              ),
            ),
            Icon(
              Icons.location_pin,
              size: 30,
              color: pinColor,
            ),
          ],
        ),
      // Icon(Icons.location_pin, size: 30, color: pinColor),
    ),
  );


  Future<List<Marker>> fetchLatLngPoints() async {
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
        
        List<Marker> markers = data.map((item) {
          Color pinColor;

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
          
          if (status == 'true') {
            pinColor = const Color.fromARGB(255, 46, 135, 1);
          }
          else {
            pinColor = const Color.fromARGB(255, 201, 4, 4);
          }
          LatLng latLng = LatLng(latitude, longitude);
          return buildPin(latLng, pinColor, buck);
        }).toList();

        return markers;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
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
}