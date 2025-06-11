String getSurfaceType(int roadType) {
  String res;
  switch (roadType) {
    case -1:
      res = "Measurement";
      break;
    case -2:
      res = "Pause";
    case 0:
      res = "Paved";
      break;
    case 1:
      res = "Un-Paved";
      break;
    case 2:
      res = "Pedestrian";
      break;
    default:
      res = "-";
  }
  return res;
}
