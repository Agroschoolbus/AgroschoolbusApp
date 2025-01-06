import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import './marker_data.dart';
import '../services/api.dart';


class MarkerContoller {

    List<Marker> customMarkers = [];
    Map<LatLng, MarkerData> markersDataList = {};
    API api;

    final VoidCallback onMarkersUpdated;

    MarkerContoller({required this.onMarkersUpdated, required this.api});

    void fetchMarkers() async {
      await api.fetchLatLngPoints().then((markers) {
          customMarkers = markers.map((item) {

            final latitude = double.parse(item['latitude']);
            final longitude = double.parse(item['longitude']);
            final status = item['status'].toString();
            final int buckets = item['buckets'];
            final int user = item['user'];

            // print(status);

            LatLng latLng = LatLng(latitude, longitude);
            MarkerData marker_data = MarkerData(point: latLng, buckets: buckets, userId: user, status: status);
            markersDataList[latLng] = marker_data;

            return buildPin(marker_data);
          }).toList();
      });
      onMarkersUpdated();
    }


    void tapOnMarker(LatLng point) {
        // Update marker color
        for (int i = 0; i < customMarkers.length; i++) {
          if (customMarkers[i].point == point) {
            print(markersDataList[point]!.getStatus());
            markersDataList[point]!.markerColor = const Color.fromARGB(255, 201, 4, 4);
            customMarkers[i] = buildPin(markersDataList[point]!);
          }
        }

        onMarkersUpdated();
    }


    Marker buildPin(MarkerData markerData) {
    
        // markerColors[point] =  Color.fromARGB(255, 46, 135, 1);
        return Marker(
            point: markerData.point,
            width: 60,
            height: 60,
            child: GestureDetector(
                onTap: () {
                tapOnMarker(markerData.point);
                },
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text(
                    "test",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.white.withOpacity(0.7),
                    ),
                    ),
                    Icon(
                    Icons.location_pin,
                    size: 30,
                    color: markerData.markerColor,
                    ),
                ],
                ),
            ),
        );
    }

    

}