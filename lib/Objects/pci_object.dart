class PciData {
  double latitude;
  double longitude;
  double velocity;
  int label;
  int pci;

  PciData({
    required this.latitude,
    required this.longitude,
    required this.velocity,
    required this.label,
    required this.pci,
  });
}

class PciData2 {
  int outuputDataID;
  double latitude;
  double longitude;
  double velocity;
  double prediction;

  PciData2({
    required this.outuputDataID,
    required this.latitude,
    required this.longitude,
    required this.velocity,
    required this.prediction,
  });
}
