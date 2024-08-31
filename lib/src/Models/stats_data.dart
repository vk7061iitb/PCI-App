/* This file contains the model class for the stats data. 
   It contains the model class for the road's statistics.

* OutputStats class is created to store the output data from the model.
* It contains the outputDataID, pci, avgVelocity, distanceTravelled, and numberOfSegments.
* The data is used to display the statistics of the road.
 */

class OutputStats {
  final int outputDataID;
  final String pci;
  final String avgVelocity;
  final String distanceTravelled;
  final String numberOfSegments;

  OutputStats(
      {required this.outputDataID,
      required this.pci,
      required this.avgVelocity,
      required this.distanceTravelled,
      required this.numberOfSegments});
}
