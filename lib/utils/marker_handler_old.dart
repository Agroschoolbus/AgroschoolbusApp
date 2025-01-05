import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';



class MarkerHandler {

  final BuildContext context;

  MarkerHandler(this.context);

  late final customMarkers = <Marker>[];

  Marker buildPin(LatLng point) => Marker(
    point: point,
    width: 60,
    height: 60,
    child: GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tapped existing marker'),
          duration: Duration(seconds: 1),
          showCloseIcon: true,
        ),
      ),
      child: const Icon(Icons.location_pin, size: 30, color: Colors.black),
    ),
  );

}