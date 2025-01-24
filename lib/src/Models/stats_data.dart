import 'package:pciapp/src/Models/pci_data.dart';

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

class SegmentStats {
  final String name;
  final String roadNo;
  final String segmentNo;
  final String from;
  final String to;
  final String distance;
  final int pci;
  final int velocityPCI;
  final String remarks;

  SegmentStats({
    required this.name,
    required this.roadNo,
    required this.segmentNo,
    required this.from,
    required this.to,
    required this.distance,
    required this.pci,
    required this.velocityPCI,
    required this.remarks,
  });
}

class SegStats {
  final List<SegmentStats> predictedStats;
  final List<SegmentStats> velocityStats;

  SegStats({
    required this.predictedStats,
    required this.velocityStats,
  });
}
