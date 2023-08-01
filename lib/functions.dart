List<List<double>> convertCIExyToCIEuv(List<List<double>> userInputPolygon) {
  List<List<double>> outputPolygon = [];

  for (List<double> coord in userInputPolygon) {
    double u = (4 * coord[0]) / (-2 * coord[0] + 12 * coord[1] + 3);
    double v = (9 * coord[1]) / (-2 * coord[0] + 12 * coord[1] + 3);

    outputPolygon.add([u, v]);
  }

  return outputPolygon;
}
