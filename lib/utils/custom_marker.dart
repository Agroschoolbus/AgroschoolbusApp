
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


class CustomMarker extends StatefulWidget {
  final LatLng point;
  final int buckets;
  final int userId;
  final String status;
  final Function(Color, int) onColorChange;

  const CustomMarker({
    Key? key,
    required this.point,
    required this.buckets,
    required this.userId,
    required this.status,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _CustomMarkerState createState() => _CustomMarkerState();
}

class _CustomMarkerState extends State<CustomMarker> {
  late Color markerColor;
  late String bucketInfo = "";
  late int state = 0;

  @override
  void initState() {
    super.initState();
    setBucketInfo();
    setInitialColor();
  }


  void setInitialColor() {
    if (widget.status == 'true') {
      markerColor = const Color.fromARGB(255, 46, 135, 1);
      state = 2;
    }
    else {
      markerColor = const Color.fromARGB(255, 201, 4, 4);
      state = 0;
    } 
  }

  void setBucketInfo() {
    if (widget.buckets < 2) {
      bucketInfo = widget.userId.toString() + " - 1 Κάδος";
    } else {
      bucketInfo = widget.userId.toString() + " - " + widget.buckets.toString() + " κάδοι";
    }
  }


  void toggleColor() {
    setState(() {
      if (markerColor == const Color.fromARGB(255, 201, 4, 4)) {
        markerColor = const Color.fromARGB(255, 21, 13, 253);
        state = 1;
      } else if (markerColor == const Color.fromARGB(255, 21, 13, 253)) {
        markerColor = const Color.fromARGB(255, 201, 4, 4);
        state = 0;
      }
          
    });
    widget.onColorChange(markerColor, state);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            bucketInfo,
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
            color: markerColor,
          ),
        ],
      ),
    );
  }
}