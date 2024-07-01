/* 
The function convertToGeoJsonFormat takes a list of PciData objects and converts it into 
a GeoJSON format for map visualization. It iterates through the list, calculates the average 
velocity and maximum PCI value between consecutive data points, and creates GeoJSON features 
with these properties and coordinates for each pair of points.
*/

import '../src/Models/pci_data.dart';

Map<String, dynamic> convertToGeoJsonFormat(List<PciData> pciDataPoints) {
  List<Map<String, dynamic>> geoJsonFeatures = [];
  for (int i = 0; i < pciDataPoints.length - 1; i++) {
    PciData currentPCIdata = pciDataPoints[i];
    PciData nextPCIdata = pciDataPoints[i + 1];
    double avgerageVelocity =
        (currentPCIdata.velocity + nextPCIdata.velocity) / 2;
    int maxumumPCI = currentPCIdata.pci > nextPCIdata.pci
        ? currentPCIdata.pci
        : nextPCIdata.pci;

    Map<String, dynamic> polylineProperties = {
      'Avg. Speed': 3.6 * avgerageVelocity,
      'PCI': maxumumPCI,
    };

    List<List<double>> polylineCoordinates = [
      [
        currentPCIdata.longitude,
        currentPCIdata.latitude,
      ],
      [
        nextPCIdata.longitude,
        nextPCIdata.latitude,
      ],
    ];

    Map<String, dynamic> geometry = {
      'type': 'LineString',
      'polylineCoordinates': polylineCoordinates,
    };

    Map<String, dynamic> feature = {
      'type': 'Feature',
      'polylineProperties': polylineProperties,
      'geometry': geometry,
    };

    geoJsonFeatures.add(feature);
  }

  Map<String, dynamic> featureCollection = {
    'type': 'FeatureCollection',
    'geoJsonFeatures': geoJsonFeatures,
  };

  return featureCollection;
}

Map<String, dynamic> outputDataToGeoJson(List<PciData2> pciDataPoints) {
  List<Map<String, dynamic>> geoJsonFeatures = [];
  for (int i = 0; i < pciDataPoints.length - 1; i++) {
    PciData2 currentPCIdata = pciDataPoints[i];
    PciData2 nextPCIdata = pciDataPoints[i + 1];
    double avgerageVelocity =
        (currentPCIdata.velocity + nextPCIdata.velocity) / 2;
    double maxumumPCI = currentPCIdata.prediction > nextPCIdata.prediction
        ? currentPCIdata.prediction
        : nextPCIdata.prediction;

    Map<String, dynamic> polylineProperties = {
      'Avg. Speed': 3.6 * avgerageVelocity,
      'PCI': maxumumPCI,
    };

    List<List<double>> polylineCoordinates = [
      [
        currentPCIdata.longitude,
        currentPCIdata.latitude,
      ],
      [
        nextPCIdata.longitude,
        nextPCIdata.latitude,
      ],
    ];

    Map<String, dynamic> geometry = {
      'type': 'LineString',
      'polylineCoordinates': polylineCoordinates,
    };

    Map<String, dynamic> feature = {
      'type': 'Feature',
      'polylineProperties': polylineProperties,
      'geometry': geometry,
    };
    geoJsonFeatures.add(feature);
  }

  Map<String, dynamic> featureCollection = {
    'type': 'FeatureCollection',
    'geoJsonFeatures': geoJsonFeatures,
  };

  return featureCollection;
}
