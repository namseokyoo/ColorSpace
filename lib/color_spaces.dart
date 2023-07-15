Map<String, List<Point>> colorSpaces = {
  'sRGB': [
    Point(0.640, 0.330),
    Point(0.300, 0.600),
    Point(0.150, 0.060),
  ],
  'Adobe RGB': [
    Point(0.640, 0.330),
    Point(0.210, 0.710),
    Point(0.150, 0.060),
  ],
  'BT.2020': [
    Point(0.708, 0.292),
    Point(0.170, 0.797),
    Point(0.131, 0.046),
  ],
  'DCI-P3': [
    Point(0.680, 0.320),
    Point(0.265, 0.690),
    Point(0.150, 0.060),
  ],
};

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}
