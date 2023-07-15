import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class ColorSpacePage extends StatefulWidget {
  @override
  _ColorSpacePageState createState() => _ColorSpacePageState();
}

class _ColorSpacePageState extends State<ColorSpacePage> {
  String? selectedColorSpace;
  final String lambdaUrl =
      "https://95sn67gfzb.execute-api.ap-northeast-2.amazonaws.com";

  TextEditingController _rxController = TextEditingController();
  TextEditingController _ryController = TextEditingController();
  TextEditingController _gxController = TextEditingController();
  TextEditingController _gyController = TextEditingController();
  TextEditingController _bxController = TextEditingController();
  TextEditingController _byController = TextEditingController();

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

  Map<String, double> colorSpaceOverlapArea = {};

  Future<void> callLambdaFunction(List<List<double>> polygon) async {
    http.Response response = await http.post(
      Uri.parse(lambdaUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'polygon1_coords': polygon,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> lambdaResponse = jsonDecode(response.body);

      if (lambdaResponse['statusCode'] == 200) {
        Map<String, dynamic> bodyResponse = jsonDecode(lambdaResponse['body']);
        setState(() {
          colorSpaceOverlapArea = bodyResponse.cast<String, double>();
        });
      } else {
        // print('Lambda function returned error: ${lambdaResponse['statusCode']}');
      }
    } else {
      print('Failed to call Lambda function: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text('R(x, y):'),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: _rxController)),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: _ryController)),
              ],
            ),
            Row(
              children: [
                Text('G(x, y):'),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: _gxController)),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: _gyController)),
              ],
            ),
            Row(
              children: [
                Text('B(x, y):'),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: _bxController)),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: _byController)),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                double rx = double.parse(_rxController.text);
                double ry = double.parse(_ryController.text);
                double gx = double.parse(_gxController.text);
                double gy = double.parse(_gyController.text);
                double bx = double.parse(_bxController.text);
                double by = double.parse(_byController.text);

                List<List<double>> userInputPolygon = [
                  [rx, ry],
                  [gx, gy],
                  [bx, by],
                  [rx, ry] // Close the polygon
                ];

                await callLambdaFunction(userInputPolygon);
                setState(() {});
              },
              child: Text('Calculate'),
            ),
            SizedBox(height: 20), // Provide some spacing
            Text(
              '색재현율(중첩비)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap:
                  true, // To avoid unbounded height issues in the ListView
              itemCount: colorSpaceOverlapArea.length,
              itemBuilder: (context, index) {
                String colorSpace = colorSpaceOverlapArea.keys.elementAt(index);
                print(colorSpace);
                double? overlapArea = colorSpaceOverlapArea[colorSpace];
                return ListTile(
                  title: Text(colorSpace),
                  trailing: Text(overlapArea!.toStringAsFixed(
                      2)), // Display area with 2 decimal places
                );
              },
            ),

            DropdownButton<String>(
              value: selectedColorSpace,
              hint: Text('Select Color Space'),
              items: colorSpaces.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedColorSpace = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Color Space Graph',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              child: Stack(
                children: [
                  if (selectedColorSpace != null)
                    Positioned.fill(
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            // 사용자 입력 값에 대한 LineChartBarData
                            LineChartBarData(
                              spots: _buildUserInputLineChartSpots(),
                              isCurved: false,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                              barWidth: 2,
                              isStrokeCapRound: true,
                              color: Colors.red,
                              dashArray: [5, 10], // Dashed line
                            ),
                            // 색 공간에 대한 LineChartBarData
                            if (selectedColorSpace != null)
                              LineChartBarData(
                                spots: _buildColorSpaceLineChartSpots(),
                                isCurved: false,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                                barWidth: 2,
                                isStrokeCapRound: true,
                                color: Colors.black,
                                dashArray: [5, 10], // Dashed line
                              ),
                          ],
                          borderData: FlBorderData(show: true),
                          titlesData: FlTitlesData(show: true),
                          gridData: FlGridData(show: false),
                          lineTouchData: LineTouchData(enabled: false),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildUserInputLineChartSpots() {
    List<FlSpot> spots = [];

    double rx = double.tryParse(_rxController.text) ?? 0;
    double ry = double.tryParse(_ryController.text) ?? 0;
    double gx = double.tryParse(_gxController.text) ?? 0;
    double gy = double.tryParse(_gyController.text) ?? 0;
    double bx = double.tryParse(_bxController.text) ?? 0;
    double by = double.tryParse(_byController.text) ?? 0;

    spots.add(FlSpot(rx, ry));
    spots.add(FlSpot(gx, gy));
    spots.add(FlSpot(bx, by));
    spots.add(FlSpot(rx, ry)); // 다시 처음 점으로 돌아가 삼각형을 완성합니다.

    return spots;
  }

  List<FlSpot> _buildColorSpaceLineChartSpots() {
    List<FlSpot> spots = [];

    if (selectedColorSpace != null) {
      for (var point in colorSpaces[selectedColorSpace]!) {
        spots.add(FlSpot(point.x, point.y));
      }

      var firstPoint = colorSpaces[selectedColorSpace]!.first;
      spots.add(
          FlSpot(firstPoint.x, firstPoint.y)); //// 다시 처음 점으로 돌아가 삼각형을 완성합니다.
    }

    return spots;
  }
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}
