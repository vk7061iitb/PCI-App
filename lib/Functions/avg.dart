double avg(List<double> lst) {
  double res = 0.0;
  for (double i in lst) {
    res += i;
  }
  res = res / lst.length;
  return res;
}
