import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pciapp/Functions/avg.dart';
import 'get_surface_type.dart';

Map<String, dynamic> toGeoJSON(
  List<Map<String, dynamic>> journey,
  Map<String, dynamic> info,
) {
  if (journey.isEmpty) {
    // show something
    return {};
  }
  List<Map<String, dynamic>> features = [];
  for (var road in journey) {
    String roadName = road["roadName"];
    List<dynamic> lables = road["labels"];
    List<LatLng> points = [];
    int firstPointPCI = 0;
    int secondPointPCI = min(lables[0]["prediction"], lables[0]["prediction"]);
    Map<String, dynamic> currLable = {};
    Map<String, dynamic> nextLable = {};
    double distance = 0.0;
    double time = 0.0;
    double minLat = lables[0]["latitude"];
    double minLon = lables[0]["longitude"];
    double maxLat = lables[0]["latitude"];
    double maxLon = lables[0]["longitude"];

    for (int i = 0; i < lables.length - 1; i++) {
      minLat = min(minLat, lables[i]["latitude"]);
      minLon = min(minLon, lables[i]["longitude"]);
      minLat = max(minLat, lables[i]["latitude"]);
      minLon = max(minLon, lables[i]["longitude"]);

      currLable = lables[i];
      nextLable = lables[i + 1];

      LatLng currPoint = LatLng(currLable["latitude"], currLable["longitude"]);
      LatLng nextPoint = LatLng(nextLable["latitude"], nextLable["longitude"]);

      double d = Geolocator.distanceBetween(
        currPoint.latitude,
        currPoint.longitude,
        nextPoint.latitude,
        nextPoint.longitude,
      );

      double t = d / (avg([currLable["velocity"], nextLable["velocity"]]));

      int currPCI = (currLable["prediction"] as num).toInt();
      int nextPCI = (nextLable["prediction"] as num).toInt();

      firstPointPCI = secondPointPCI;
      secondPointPCI = min(currPCI, nextPCI);

      points.add(currPoint);

      if (firstPointPCI != secondPointPCI) {
        // encountered a polyline segment
        Map<String, dynamic> properties = {
          "roadName": roadName,
          "PCI": firstPointPCI,
          "avgVelocity": (3.6 * (distance / time)).toStringAsFixed(4), // km/hr
          "length": (distance / 1000).toStringAsFixed(4), // km
          "remarks": currLable["remarks"] ?? "-",
          "roadType": getSurfaceType(currLable["road_type"])
        };

        Map<String, dynamic> feature = {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": points
                .map((point) => [point.longitude, point.latitude])
                .toList(),
          },
          "properties": properties,
          "bbox": [minLon, minLat, maxLon, maxLat],
        };

        features.add(feature);

        // reset the variables
        minLat = currLable["latitude"];
        minLon = currLable["longitude"];
        maxLat = currLable["latitude"];
        maxLon = currLable["longitude"];
        points = [currPoint];
        distance = 0;
        time = 0;
      }

      distance += d;
      time += t;
    }

    // once for loop ended, need to add remaining segment if exits

    // add the last point
    points.add(LatLng(lables.last["latitude"], lables.last["longitude"]));

    // the last segment containing last 2 points needs to be added
    if (points.length == 1) {
      Map<String, dynamic> properties = {
        "roadName": roadName,
        "PCI": secondPointPCI, // * got changed
        "avgVelocity": (3.6 * (distance / time)).toStringAsFixed(4), // km/hr
        "length": (distance / 1000).toStringAsFixed(4), // km
        "remarks": currLable["remarks"] ?? "-",
        "roadType": getSurfaceType(currLable["road_type"])
      };

      Map<String, dynamic> feature = {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates":
              points.map((point) => [point.longitude, point.latitude]).toList(),
        },
        "properties": properties,
        "bbox": [minLon, minLat, maxLon, maxLat],
      };

      features.add(feature);
    } else {
      Map<String, dynamic> properties = {
        "roadName": roadName,
        "PCI": firstPointPCI,
        "avgVelocity": (3.6 * (distance / time)).toStringAsFixed(4), // km/hr
        "length": (distance / 1000).toStringAsFixed(4), // km
        "remarks": currLable["remarks"] ?? "-",
        "roadType": getSurfaceType(currLable["road_type"])
      };

      Map<String, dynamic> feature = {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates":
              points.map((point) => [point.longitude, point.latitude]).toList(),
        },
        "properties": properties,
        "bbox": [minLon, minLat, maxLon, maxLat],
      };

      features.add(feature);
    }
  }

  // now create the geojson file
  Map<String, dynamic> metaData = {
    "user": info["user"]["email"],
    "time": info["time"],
    "vehicleType": info["vehicleType"],
  };

  Map<String, dynamic> geoJSON = {
    "type": "FeatureCollection",
    "metadata": metaData,
    "features": features,
  };
  return geoJSON;
}

/// format of road data (it'll be a json encoded string)
/// {
///   "data": // queried data from db (local)
///   "info": // metadata
/// }
/// metadata: {
///   "filename":
///   "vehicleType":
///   "time":
///   "user":
/// }
