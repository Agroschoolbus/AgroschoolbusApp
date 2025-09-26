import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:agroschoolbus/utils/enum_types.dart';

class MarkerData {
  int id;
  LatLng point;
  int buckets;
  int bags;
  String userId;
  Color markerColor = const Color.fromARGB(255, 46, 135, 1);
  String status;
  String mill;
  late MarkerState state;
  

  MarkerData({
    required this.id,
    required this.point,
    required this.buckets,
    required this.bags,
    required this.mill,
    required this.userId,
    required this.status,
  }) { initMarkerColor(); }

  void initMarkerColor() {
    if (status == "pending") {
      state = MarkerState.pending;
      markerColor = const Color.fromARGB(255, 201, 4, 4);
    } else if (status == "delivered") {
      state = MarkerState.delivered;
      markerColor =const Color.fromARGB(255, 46, 135, 1);
    } else if (status == "collected") {
      state = MarkerState.collected;
      markerColor =const Color.fromARGB(255, 153, 153, 204);
    } else {
      markerColor = const Color.fromARGB(255, 21, 13, 253);
    }
  }

  void setPoint(LatLng point) {
    this.point = point;
  }

  void setBucketInfo(int buckets) {
    this.buckets = buckets;
  }

  String getUserId() {
    return userId;
  }

  LatLng getPoint() {
    return point;
  }

  void setStatus(String status) {
    this.status = status;
  }

  String getStatus() {
    return status;
  }

  String getBucketsInfo() {
    String bucketInfo;
    if (buckets < 2) {
      bucketInfo = '${userId.toString()} - 1 Κάδος';
    } else {
      bucketInfo = '${userId.toString()} - ${buckets.toString()} κάδοι';
    }
    return bucketInfo;
  }
}