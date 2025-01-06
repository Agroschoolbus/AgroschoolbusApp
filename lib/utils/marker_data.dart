import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:agroschoolbus/utils/enum_types.dart';

class MarkerData {
  LatLng point;
  int buckets;
  int userId;
  Color markerColor = const Color.fromARGB(255, 46, 135, 1);
  String status;
  late MarkerState state;
  

  MarkerData({
    required this.point,
    required this.buckets,
    required this.userId,
    required this.status,
  }) { initMarkerColor(); }

  void initMarkerColor() {
    if (status == "false") {
      state = MarkerState.pending;
      markerColor = const Color.fromARGB(255, 201, 4, 4);
    } else {
      state = MarkerState.collected;
      markerColor =const Color.fromARGB(255, 46, 135, 1);
    }
  }

  void setPoint(LatLng point) {
    this.point = point;
  }

  void setBucketInfo(int buckets) {
    this.buckets = buckets;
  }

  int getUserId() {
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