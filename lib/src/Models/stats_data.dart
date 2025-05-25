/// this is the format how server send the prossed data for a road (a joueny may contains multiple roads)
/// NOTE : (do not it change without cosulting with backend developer)
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

/// representation of a road covered in a journey
class RoadOutputData {
  final int outputDataID; // a key to map the a road's data to a given journey or trip
  final RoadData roadData;

  RoadOutputData({
    required this.outputDataID,
    required this.roadData,
  });
}


// represents overall stats representation of a road
class RoadPCIStatistics {
  final String pci;
  final String avgVelocity;
  final String distanceTravelled;
  final String numberOfSegments;

  RoadPCIStatistics({
    required this.pci,
    required this.avgVelocity,
    required this.distanceTravelled,
    required this.numberOfSegments,
  });
}

/// represent oveall stats of a journey
class RoadStatsOverall {
  final String roadName;
  final List<RoadPCIStatistics> overallStatsPredictionBased;
  final List<RoadPCIStatistics> overallStatsVelocityBased;

  RoadStatsOverall({
    required this.roadName,
    required this.overallStatsPredictionBased,
    required this.overallStatsVelocityBased,
  });
}

/// repreresents chainage/segment-wise stats of a road
class RoadChainageStatistics {
  final String name;
  final String roadNo;
  final String segmentNo;
  final String from;
  final String to;
  final String distance;
  final int pci;
  final int velocityPCI;
  final String remarks;
  final String surfaceType;

  RoadChainageStatistics(
      {required this.name,
      required this.roadNo,
      required this.segmentNo,
      required this.from,
      required this.to,
      required this.distance,
      required this.pci,
      required this.velocityPCI,
      required this.remarks,
      required this.surfaceType});
}

/// repreresents chainage/segment-wise stats of a journey
class RoadStatsChainage {
  final List<RoadChainageStatistics> chainageStatsPredictionBased;
  final List<RoadChainageStatistics> chainageStatsVelocityBased;

  RoadStatsChainage({
    required this.chainageStatsPredictionBased,
    required this.chainageStatsVelocityBased,
  });
}
