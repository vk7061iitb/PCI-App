/* 
  This file contains the model for the PCI data
  The model is used to store the data from the database
  and to pass the data to the UI
*/

class RoadPCIdata {
  final double latitude;
  final double longitude;
  final double velocity;
  final double prediction;
  RoadPCIdata({
    required this.latitude,
    required this.longitude,
    required this.velocity,
    required this.prediction,
  });
}
