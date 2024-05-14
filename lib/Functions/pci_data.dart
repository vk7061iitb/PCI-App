import '../Objects/pci_object.dart';

Map<String, dynamic> convertToGeoJsonFormat(List<PciData> pciDataList) {
  List<Map<String, dynamic>> features = [];
  for (int i = 0; i < pciDataList.length - 1; i++) {
    PciData currentData = pciDataList[i];
    PciData nextData = pciDataList[i + 1];
    double avgVelocity = (currentData.velocity + nextData.velocity) / 2;
    int maxPci =
        currentData.pci > nextData.pci ? currentData.pci : nextData.pci;

    // Create properties for LineString
    Map<String, dynamic> properties = {
      'Avg. Speed': 3.6 * avgVelocity,
      'PCI': maxPci,
    };

    List<List<double>> coordinates = [
      [
        currentData.longitude,
        currentData.latitude,
      ],
      [
        nextData.longitude,
        nextData.latitude,
      ],
    ];

    // Create geometry for LineString
    Map<String, dynamic> geometry = {
      'type': 'LineString',
      'coordinates': coordinates,
    };

    // Create feature for LineString
    Map<String, dynamic> feature = {
      'type': 'Feature',
      'properties': properties,
      'geometry': geometry,
    };

    // Add feature to features list
    features.add(feature);
  }

  // Create the FeatureCollection dictionary
  Map<String, dynamic> featureCollection = {
    'type': 'FeatureCollection',
    'features': features,
  };

  return featureCollection;
}
