import 'package:pci_app/src/Models/pci_data.dart';

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

class RoadData {
  final String roadName;
  final List<Map<String, dynamic>> labels;
  final Map<String, dynamic> stats;

  RoadData({
    required this.roadName,
    required this.labels,
    required this.stats,
  });
}

class RoadOutputData {
  final int outputDataID;
  final RoadData roadData;

  RoadOutputData({
    required this.outputDataID,
    required this.roadData,
  });
}

class Road {
  final String roadName;
  final List<RoadPCIdata> roadPciData;
  final List<RoadStats> roadStats;

  Road({
    required this.roadName,
    required this.roadPciData,
    required this.roadStats,
  });
}

class RoadStatsData {
  final String pci;
  final String avgVelocity;
  final String distanceTravelled;
  final String numberOfSegments;

  RoadStatsData({
    required this.pci,
    required this.avgVelocity,
    required this.distanceTravelled,
    required this.numberOfSegments,
  });
}

class RoadStats {
  final String roadName;
  final List<RoadStatsData> predStats;
  final List<RoadStatsData> velStats;

  RoadStats({
    required this.roadName,
    required this.predStats,
    required this.velStats,
  });
}
