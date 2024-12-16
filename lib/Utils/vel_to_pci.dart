double velocityToPCI(double velocity) {
  if (velocity >= 30) {
    return 5;
  } else if (velocity > 20) {
    return 4;
  } else if (velocity > 10) {
    return 3;
  } else if (velocity > 5) {
    return 2;
  } else {
    return 1;
  }
}
