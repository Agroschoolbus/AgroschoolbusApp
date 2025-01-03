import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


class MarkerData {
  LatLng point;
  int buckets;
  int userId;
  Color markerColor = Color.fromARGB(255, 46, 135, 1);
  String status;
  

  MarkerData({
    required this.point,
    required this.buckets,
    required this.userId,
    required this.status,
  });

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