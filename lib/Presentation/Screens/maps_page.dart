import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Functions/load_geo_json.dart';
import '../../Objects/data.dart';
import '../../Objects/polyline_obj.dart';
import '../Widget/feature_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController? mapController;
  Color polylineColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SizedBox(
              child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(19.133623, 72.911895),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  polylines: polylines),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      geoJsonData = await loadGeoJsonFromFile();
                      decodeJsonFile();
                      setState(() {});
                    } catch (error) {
                      if (kDebugMode) {
                        print('Error loading GeoJSON file: $error');
                      }
                    }
                  },
                  child: Text(
                    'Open File',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (geoJsonData.isNotEmpty) {
                      plotMap();
                      setState(() {
                        animateToLocation();
                      });
                    } else {
                      if (kDebugMode) {
                        print('Please load GeoJSON data first.');
                      }
                    }
                  },
                  child: Text(
                    'Plot Map',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void plotMap() {
    polylines.clear();
    polylineObj.clear();
    features = jsonData['features'];
    for (int i = 0; i < features.length; i++) {
      List<LatLng> points = [];
      Map<String, dynamic> feature = features[i];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      Map<String, dynamic> myMap = feature['properties'];
      for (var data in coordinates) {
        points.add(
          LatLng(data[1], data[0]),
        );
      }

      Polyline tempPolyline = Polyline(
          consumeTapEvents: true,
          polylineId: PolylineId('polyline$i'),
          color: polylineColor,
          width: 2,
          points: points,
          onTap: () {
            if (kDebugMode) {
              print('Polyline tapped!');
              print('$i');
              
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return bottomSheetContent(context, i);
                  });
                setState(() {});
            }
          });

      Properties featureProperties = Properties(
          keyList: myMap.keys.toList(), valuesList: myMap.values.toList());

      polylineObj.add(
        PolylinObj(
            polyline: tempPolyline,
            polylineIndex: i,
            properties: featureProperties),
      );
      polylines.add(tempPolyline);
    }
    jsonData.clear;

    setState(() {});
  }

  void animateToLocation() async {
    jsonData = jsonDecode(geoJsonData);
    features = jsonData['features'];
    LatLng point = LatLng(
        features[features.length ~/ 2]['geometry']['coordinates'][0][1],
        features[features.length ~/ 2]['geometry']['coordinates'][0][0]);

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(point, 12),
    );
  }

  void decodeJsonFile() async {
    try {
      jsonData = await jsonDecode(geoJsonData);
    } on FormatException catch (error) {
      if (kDebugMode) {
        print('Error parsing GeoJSON data: $error');
      }
      return;
    }
  }
}
