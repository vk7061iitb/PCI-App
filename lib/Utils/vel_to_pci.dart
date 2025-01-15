/// calculates the corresponding PCI for a given velocity
double velocityToPCI({
  required double velocityKmph,
}) {
  if (velocityKmph >= 39) {
    return 5;
  } else if (velocityKmph > 30) {
    return 4;
  } else if (velocityKmph > 20) {
    return 3;
  } else if (velocityKmph > 10) {
    return 2;
  } else {
    return 1;
  }
}
