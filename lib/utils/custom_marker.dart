
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


class CustomMarker extends StatefulWidget {
  final LatLng point;
  final Color initialColor;
  final String bucketInfo;
  final Function(Color) onColorChange;

  const CustomMarker({
    Key? key,
    required this.point,
    required this.initialColor,
    required this.bucketInfo,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _CustomMarkerState createState() => _CustomMarkerState();
}

class _CustomMarkerState extends State<CustomMarker> {
  late Color markerColor;

  @override
  void initState() {
    super.initState();
    markerColor = widget.initialColor;
  }

  void toggleColor() {
    setState(() {
      if (markerColor == const Color.fromARGB(255, 201, 4, 4)) {
        markerColor = const Color.fromARGB(255, 21, 13, 253);
      } else if (markerColor == const Color.fromARGB(255, 21, 13, 253)) {
        markerColor = const Color.fromARGB(255, 201, 4, 4);
      }
          
    });
    widget.onColorChange(markerColor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.bucketInfo,
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