import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triangle Area',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TriangleAreaScreen(),
    );
  }
}

class TriangleAreaScreen extends StatefulWidget {
  @override
  _TriangleAreaScreenState createState() => _TriangleAreaScreenState();
}

class _TriangleAreaScreenState extends State<TriangleAreaScreen> {
  List<Point> firstTriangle = [
    Point(0.69, 0.31),
    Point(0.21, 0.72),
    Point(0.137, 0.05),
  ];

  List<Point> secondTriangle = [
    Point(0.68, 0.32),
    Point(0.265, 0.69),
    Point(0.15, 0.06),
  ];

  double firstTriangleArea = 0.0;
  double secondTriangleArea = 0.0;
  double overlapArea = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Triangle Area'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '첫 번째 삼각형: (0.690, 0.310), (0.210, 0.720), (0.137, 0.050)',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '면적: $firstTriangleArea',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '두 번째 삼각형: (0.680, 0.320), (0.265, 0.690), (0.150, 0.060)',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '면적: $secondTriangleArea',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  firstTriangleArea = calculateTriangleArea(firstTriangle);
                  secondTriangleArea = calculateTriangleArea(secondTriangle);
                  overlapArea = calculateOverlapArea();
                });

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('오버랩된 영역의 면적'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('면적: $overlapArea'),
                          SizedBox(height: 10),
                          Text(
                            '비율: ${(overlapArea / secondTriangleArea * 100).toStringAsFixed(2)}%',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text('닫기'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('면적 계산하기'),
            ),
            SizedBox(height: 20),
            Text(
              '오버랩된 영역의 면적: $overlapArea',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  double calculateTriangleArea(List<Point> points) {
    double area = 0;

    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += (points[i].x * points[j].y) - (points[j].x * points[i].y);
    }

    area = area.abs() / 2;
    return area;
  }

  double calculateOverlapArea() {
    List<Point> intersectionPoints =
        // findOverlapPoints(firstTriangle, secondTriangle);
        findOverlapPoints(secondTriangle, firstTriangle);

    return calculatePolygonArea(intersectionPoints);
  }

  List<Point> findOverlapPoints(List<Point> triangle1, List<Point> triangle2) {
    List<Point> overlapPoints = [];

    for (int i = 0; i < triangle1.length; i++) {
      for (int j = 0; j < triangle2.length; j++) {
        int nextIndex1 = (i + 1) % triangle1.length;
        int nextIndex2 = (j + 1) % triangle2.length;

        Point? intersectionPoint = getIntersectionPoint(
          triangle1[i],
          triangle1[nextIndex1],
          triangle2[j],
          triangle2[nextIndex2],
        );

        if (intersectionPoint != null) {
          overlapPoints.add(intersectionPoint);
        }
      }
    }

    return overlapPoints;
  }

  Point? getIntersectionPoint(Point p1, Point p2, Point p3, Point p4) {
    double x1 = p1.x;
    double y1 = p1.y;
    double x2 = p2.x;
    double y2 = p2.y;
    double x3 = p3.x;
    double y3 = p3.y;
    double x4 = p4.x;
    double y4 = p4.y;

    double denominator = ((x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4));

    if (denominator == 0) {
      return null;
    }

    double intersectX = (((x1 * y2 - y1 * x2) * (x3 - x4)) -
            ((x1 - x2) * (x3 * y4 - y3 * x4))) /
        denominator;
    double intersectY = (((x1 * y2 - y1 * x2) * (y3 - y4)) -
            ((y1 - y2) * (x3 * y4 - y3 * x4))) /
        denominator;

    if (intersectX < 0 || intersectX > 1 || intersectY < 0 || intersectY > 1) {
      return null;
    }

    return Point(intersectX, intersectY);
  }

  double calculatePolygonArea(List<Point> points) {
    double area = 0;

    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += (points[i].x * points[j].y) - (points[j].x * points[i].y);
    }

    area = area.abs() / 2;
    return area;
  }
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}
