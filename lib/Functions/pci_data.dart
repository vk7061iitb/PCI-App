import 'dart:convert';

String convertToFirstJsonFormat2(String fileContent) {
  // Parse the JSON data
  dynamic inputData = jsonDecode(fileContent);

  // Initialize an empty list to store features
  List<Map<String, dynamic>> features = [];

  // Iterate through the provided data
  for (int i = 0; i < inputData.length - 1; i++) {
    // Extract data for current and next points
    var currentData = inputData[i];
    var nextData = inputData[i + 1];

    // Calculate average velocity and max pci
    double avgVelocity = (currentData['Velocity'] + nextData['Velocity']) / 2;
    int maxPci = currentData['Prediction'] > nextData['Prediction']
        ? currentData['Prediction']
        : nextData['Prediction'];

    // Create properties for LineString
    Map<String, dynamic> properties = {
      'Avg. Speed': 3.6*avgVelocity,
      'PCI': maxPci,
    };

    // Create coordinates for LineString
    List<List<double>> coordinates = [
      [
        double.parse(currentData['Longitude']),
        double.parse(currentData['Latitude']),
      ],
      [
        double.parse(nextData['Longitude']),
        double.parse(nextData['Latitude']),
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

  // Convert the FeatureCollection dictionary to JSON format
  String jsonString = jsonEncode(featureCollection);

  return jsonString;
}
