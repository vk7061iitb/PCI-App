import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Functions/load_geo_json.dart';
import '../../Objects/data.dart';
import '../../Objects/polyline_obj.dart';
import '../Widget/path_feature.dart';
import '../Widget/maptype_dropdown.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController? mapController;

  // Function to get road color based on quality
  Color getRoadColor(String quality) {
    switch (quality) {
      case '1':
        return const Color(0xFF388E3C); // Best quality
      case '2':
        return const Color(0xFFCDDC39);
      case '3':
        return const Color(0xFF1A237E);
      case '4':
        return const Color(0xFF795548);
      case '5':
        return const Color(0xFFF44336);
      case '6':
        return const Color(0xFF448AFF); // Worst quality
      default:
        return Colors.black; // Default color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SizedBox(
              child: SizedBox(
                child: GoogleMap(
                  mapType: googleMapType,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        devicePosition.latitude, devicePosition.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  polylines: polylines,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 10,
            child: MapTypeDropdown(
              onChanged: (p0) => setState(() {}),
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
                      await loadGeoJsonFromFile();
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
                    plotMap();
                    Future.delayed(const Duration(milliseconds: 500)).then(
                      (value) => animateToLocation(),
                    );
                    setState(() {});
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
                ElevatedButton(
                  onPressed: () async {
                    polylines.clear();
                    polylineObj.clear();
                    setState(() {});
                  },
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to plot the map with polylines
  void plotMap() {
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

      Polyline temporaryPolyline = Polyline(
        consumeTapEvents: true,
        polylineId: PolylineId('polyline$i'),
        color: getRoadColor(feature['properties']['PCI'].toString()),
        width: 10,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
        points: points,
        onTap: () {
          if (kDebugMode) {
            print('Polyline$i tapped!');
          }
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return PolylineFeature(
                polylineIndex: i,
              );
            },
          );
          setState(() {});
        },
      );

      Properties featureProperties = Properties(
        keyList: myMap.keys.toList(),
        valuesList: myMap.values.toList(),
      );

      polylineObj.add(
        PolylinObj(
          polyline: temporaryPolyline,
          polylineIndex: i,
          properties: featureProperties,
        ),
      );
      polylines.add(temporaryPolyline);
    }
    jsonData.clear;
    setState(() {});
  }

  // Function to animate the camera to the location of the polylines
  void animateToLocation() async {
    double minLat = features[0]['geometry']['coordinates'][0][1];
    double minLng = features[0]['geometry']['coordinates'][0][0];
    double maxLat =
        features[features.length - 1]['geometry']['coordinates'][0][1];
    double maxLng =
        features[features.length - 1]['geometry']['coordinates'][0][0];

    if (minLat > maxLat) {
      double temp = minLat;
      minLat = maxLat;
      maxLat = temp;
    }

    if (minLng > maxLng) {
      double temp = minLng;
      minLng = maxLng;
      maxLng = temp;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 11));
  }
}
