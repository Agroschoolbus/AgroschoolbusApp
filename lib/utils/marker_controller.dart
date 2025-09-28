import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agroschoolbus/utils/enum_types.dart';
import './marker_data.dart';
import '../services/api.dart';


class MarkerController {

    BuildContext context;
    List<LatLng> selectedPoints = [];
    List<Marker> customMarkers = [];
    Map<LatLng, MarkerData> markersDataList = {};
    API api;
    bool isDirectionsOn = false;
    bool allCollected = false;
    LatLng factoryLocation = LatLng(37.423586, 21.667088);

    final VoidCallback onMarkersUpdated;

    MarkerController({
      required this.onMarkersUpdated, 
      required this.api,
      required this.context
    }) {
      selectedPoints.add(factoryLocation); // factory coordinates
    }

    void fetchMarkers() async {
      await api.fetchLatLngPoints().then((markers) {
          customMarkers = markers.map((item) {
            // print(item);
            final int id = item['id'];
            final latitude = double.parse(item['latitude']);
            final longitude = double.parse(item['longitude']);
            final status = item['status'].toString();
            final int buckets = item['buckets'];
            final String user = item['user'];
            final int bags = item['bags'];
            final String mill = item['mill'];

            // print(status);

            LatLng latLng = LatLng(latitude, longitude);
            MarkerData markerData = MarkerData(id: id, point: latLng, buckets: buckets, userId: user, status: status, mill: mill, bags:bags);
            markersDataList[latLng] = markerData;

            return buildPin(markerData);
          }).toList();
      });
      onMarkersUpdated();
    }


    void tapOnMarker(LatLng point) {
        if (isDirectionsOn) {
          for (int i = 0; i < customMarkers.length; i++) {
            if (customMarkers[i].point == point) {
              // showDialogBox(markersDataList[point]!);
              if (markersDataList[point]!.state == MarkerState.selected) {
                updateMarkerDetailsOnServer(markersDataList[point]!.id, "collected");
                markersDataList[point]!.state = MarkerState.collected;
                markersDataList[point]!.markerColor = const Color.fromARGB(255, 153, 153, 204);
              }
              else if (markersDataList[point]!.state == MarkerState.collected) {
                updateMarkerDetailsOnServer(markersDataList[point]!.id, "selected");
                markersDataList[point]!.state = MarkerState.selected;
                markersDataList[point]!.markerColor = const Color.fromARGB(255, 21, 13, 253);
              }

              customMarkers[i] = buildPin(markersDataList[point]!);
            }
          }
        } else {
          for (int i = 0; i < customMarkers.length; i++) {
            if (customMarkers[i].point == point) {
              // showDialogBox(markersDataList[point]!);
              if (markersDataList[point]!.state == MarkerState.pending) {
                selectedPoints.add(point);
                updateMarkerDetailsOnServer(markersDataList[point]!.id, "selected");
                markersDataList[point]!.state = MarkerState.selected;
                markersDataList[point]!.markerColor = const Color.fromARGB(255, 21, 13, 253);
              }
              else if (markersDataList[point]!.state == MarkerState.selected) {
                updateMarkerDetailsOnServer(markersDataList[point]!.id, "pending");
                selectedPoints.remove(point);
                markersDataList[point]!.state = MarkerState.pending;
                markersDataList[point]!.markerColor = const Color.fromARGB(255, 201, 4, 4);
              }
              // const Color.fromARGB(255, 46, 135, 1);

              customMarkers[i] = buildPin(markersDataList[point]!);
            }
          }
        }

        onMarkersUpdated();
    }


    void cancelRoute() {
      for (int i = 0; i < customMarkers.length; i++) {
        if (markersDataList[customMarkers[i].point]!.state == MarkerState.selected || markersDataList[customMarkers[i].point]!.state == MarkerState.collected) {
          updateMarkerDetailsOnServer(markersDataList[customMarkers[i].point]!.id, "pending");
          markersDataList[customMarkers[i].point]!.state = MarkerState.pending;
          markersDataList[customMarkers[i].point]!.markerColor = const Color.fromARGB(255, 201, 4, 4);
          customMarkers[i] = buildPin(markersDataList[customMarkers[i].point]!);
        }
      }

      selectedPoints = [];
      selectedPoints.add(factoryLocation);
      onMarkersUpdated();
    }


    void checkIfAllCollected() {
      allCollected = true;
      for (int i = 0; i < customMarkers.length; i++) {
        if (markersDataList[customMarkers[i].point]!.state == MarkerState.selected) {
          allCollected = false;
        }
      }
    }


    void completeRoute() {
        
        for (int i = 0; i < customMarkers.length; i++) {
          if (markersDataList[customMarkers[i].point]!.state == MarkerState.collected) {
            updateMarkerDetailsOnServer(markersDataList[customMarkers[i].point]!.id, "delivered");
            markersDataList[customMarkers[i].point]!.state = MarkerState.delivered;
            markersDataList[customMarkers[i].point]!.markerColor = const Color.fromARGB(255, 46, 135, 1);
            customMarkers[i] = buildPin(markersDataList[customMarkers[i].point]!);
          }
          if (markersDataList[customMarkers[i].point]!.state == MarkerState.selected) {
            updateMarkerDetailsOnServer(markersDataList[customMarkers[i].point]!.id, "pending");
            markersDataList[customMarkers[i].point]!.state = MarkerState.pending;
            markersDataList[customMarkers[i].point]!.markerColor = const Color.fromARGB(255, 201, 4, 4);
            customMarkers[i] = buildPin(markersDataList[customMarkers[i].point]!);
          }
        }

        selectedPoints = [];
        selectedPoints.add(factoryLocation);
        onMarkersUpdated();
    }


    void updateMarkerDetailsOnServer(int id, String status) {
      dynamic pinDetails = {
        "status": status
      };
      api.updatePinStatus(pinDetails, id);
    }



    Marker buildPin(MarkerData markerData) {
    
        // markerColors[point] =  Color.fromARGB(255, 46, 135, 1);
        return Marker(
            point: markerData.point,
            width: 60,
            height: 60,
            child: GestureDetector(
                onTap: () {
                // tapOnMarker(markerData.point);
                },
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text(
                    "UID: " + markerData.userId.toString() + " - B#: " + markerData.buckets.toString(),
                    style: TextStyle(
                        fontSize: 7,
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


    void showDialogBox(MarkerData marker) {
      showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Λεπτομέρειες"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Χρήστης: ${marker.userId}"),
              Text("Κατάσταση: ${marker.state}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Κλείσιμο"),
            ),
          ],
        );
      },
    );
    }
    

}