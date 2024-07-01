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
