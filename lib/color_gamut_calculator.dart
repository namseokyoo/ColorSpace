import 'dart:convert';
import 'package:color_gamut/color_spaces.dart';
import 'package:color_gamut/functions.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ColorSpacePage extends StatefulWidget {
  @override
  _ColorSpacePageState createState() => _ColorSpacePageState();
}

class _ColorSpacePageState extends State<ColorSpacePage> {
  RangeValues xAxisValues = const RangeValues(0, 0.8); // 가로축 범위
  RangeValues yAxisValues = const RangeValues(0, 0.9); // 세로축 범위

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? selectedColorSpace;

  TextEditingController _rxController = TextEditingController();
  TextEditingController _ryController = TextEditingController();
  TextEditingController _gxController = TextEditingController();
  TextEditingController _gyController = TextEditingController();
  TextEditingController _bxController = TextEditingController();
  TextEditingController _byController = TextEditingController();

  Map<String, dynamic> colorSpaceOverlapAreaXY = {};
  Map<String, dynamic> colorSpaceOverlapAreaUV = {};

  final String lambdaUrl =
      "https://nr0o1d5a45.execute-api.ap-northeast-2.amazonaws.com/color_space_v2";

  Future<void> callLambdaFunction(
      List<List<double>> polygon, List<List<double>> polygonuv) async {
    http.Response response = await http.post(
      Uri.parse(lambdaUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'polygon1_coords': polygon,
        'polygon2_coords': polygonuv
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> lambdaResponseXY =
          jsonDecode(response.body)['ratiosXY'];
      Map<String, dynamic> lambdaResponseUV =
          jsonDecode(response.body)['ratiosUV'];

      if (response.statusCode == 200) {
        // Map<String, dynamic> bodyResponse = jsonDecode(lambdaResponseXY['body']);
        setState(() {
          colorSpaceOverlapAreaXY = lambdaResponseXY;
          colorSpaceOverlapAreaUV = lambdaResponseUV;
        });
      } else {
        // print('Lambda function returned error: ${lambdaResponseXY['statusCode']}');
      }
    } else {
      print('Failed to call Lambda function: ${response.statusCode}');
    }
  }

  // colorSpaceOverlapArea를 저장하는 함수
  Future<void> _saveOverlapArea() async {
    final SharedPreferences prefs = await _prefs;
    String jsonString = jsonEncode(colorSpaceOverlapAreaXY);
    prefs.setString('colorSpaceOverlapArea', jsonString);
  }

// colorSpaceOverlapArea를 불러오는 함수
  Future<void> _loadOverlapArea() async {
    final SharedPreferences prefs = await _prefs;
    String? jsonString = prefs.getString('colorSpaceOverlapArea');
    if (jsonString != null) {
      Map<String, dynamic> loadedMap = jsonDecode(jsonString);
      setState(() {
        colorSpaceOverlapAreaXY = loadedMap;
      });
    }
  }

  // colorSpaceOverlapAreaUV를 저장하는 함수
  Future<void> _saveOverlapAreaUV() async {
    final SharedPreferences prefs = await _prefs;
    String jsonString = jsonEncode(colorSpaceOverlapAreaUV);
    prefs.setString('colorSpaceOverlapAreaUV', jsonString);
  }

  // colorSpaceOverlapAreaUV를 불러오는 함수
  Future<void> _loadOverlapAreaUV() async {
    final SharedPreferences prefs = await _prefs;
    String? jsonString = prefs.getString('colorSpaceOverlapAreaUV');
    if (jsonString != null) {
      Map<String, dynamic> loadedMap = jsonDecode(jsonString);
      setState(() {
        colorSpaceOverlapAreaUV = loadedMap;
      });
    }
  }

  // selectedColorSpace 값을 SharedPreferences에 저장하는 함수
  Future<void> _saveColorSpace() async {
    final SharedPreferences prefs = await _prefs;
    if (selectedColorSpace != null) {
      prefs.setString('selectedColorSpace', selectedColorSpace!);
    }
  }

  // selectedColorSpace 값을 SharedPreferences에서 로드하는 함수
  Future<void> _loadColorSpace() async {
    final SharedPreferences prefs = await _prefs;
    selectedColorSpace = prefs.getString('selectedColorSpace');
  }

  Future<void> _saveInputs() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('rx', _rxController.text);
    prefs.setString('ry', _ryController.text);
    prefs.setString('gx', _gxController.text);
    prefs.setString('gy', _gyController.text);
    prefs.setString('bx', _bxController.text);
    prefs.setString('by', _byController.text);
  }

  Future<void> _loadInputs() async {
    final SharedPreferences prefs = await _prefs;
    _rxController.text = prefs.getString('rx') ?? '';
    _ryController.text = prefs.getString('ry') ?? '';
    _gxController.text = prefs.getString('gx') ?? '';
    _gyController.text = prefs.getString('gy') ?? '';
    _bxController.text = prefs.getString('bx') ?? '';
    _byController.text = prefs.getString('by') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadInputs();
    _loadColorSpace().then((_) {
      setState(() {});
    });
    _loadOverlapArea().then((_) {
      setState(() {});
    });
    _loadOverlapAreaUV().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              '색재현율(중첩비)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '<Sample Color>',
                  style: TextStyle(fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('R(x, y):'),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                            controller: _rxController,
                            textAlign: TextAlign.center,
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                            controller: _ryController,
                            textAlign: TextAlign.center,
                          )),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('G(x, y):'),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                            controller: _gxController,
                            textAlign: TextAlign.center,
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                            controller: _gyController,
                            textAlign: TextAlign.center,
                          )),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('B(x, y):'),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                            controller: _bxController,
                            textAlign: TextAlign.center,
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                            controller: _byController,
                            textAlign: TextAlign.center,
                          )),
                        ],
                      ),
                    ],
                  ),
                )
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

                List<List<double>> userInputPolygonXY = [
                  [rx, ry],
                  [gx, gy],
                  [bx, by],
                  [rx, ry] // Close the polygon
                ];

                List<List<double>> userInputPolygonUV =
                    convertCIExyToCIEuv(userInputPolygonXY);
                await callLambdaFunction(
                    userInputPolygonXY, userInputPolygonUV);
                await _saveInputs();
                await _saveOverlapArea();
                await _saveOverlapAreaUV();
              },
              child: const Text(
                '색재현율 계산',
                style: TextStyle(fontSize: 15),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '<Result>',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 8,
                ),
                FutureBuilder(
                    future: _loadOverlapArea(),
                    builder: (context, snapshot) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Space',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'CIE1931(xy)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'CIE1976(u\'v\')',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  10), // Add some spacing between column headers and data rows
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: colorSpaceOverlapAreaXY.length,
                            itemBuilder: (context, index) {
                              String colorSpace =
                                  colorSpaceOverlapAreaXY.keys.elementAt(index);
                              double? overlapAreaXY =
                                  colorSpaceOverlapAreaXY[colorSpace]
                                      ?.toDouble();
                              double? overlapAreaUV =
                                  colorSpaceOverlapAreaUV[colorSpace]
                                      ?.toDouble();

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        colorSpace,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (overlapAreaXY?.toStringAsFixed(2) ??
                                                'N/A') +
                                            ' %',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (overlapAreaUV?.toStringAsFixed(2) ??
                                                'N/A') +
                                            ' %',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }),
              ],
            ),
            const Divider(
              color: Colors.black,
            ),
            const Text(
              'Color Space Graph',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: selectedColorSpace,
                  hint: const Text('Select Color Space'),
                  items: colorSpaces.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedColorSpace = newValue;
                      _saveColorSpace();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              child: Stack(
                children: [
                  if (selectedColorSpace != null)
                    Positioned.fill(
                      child: ClipRect(
                        child: buildLineChart(),
                      ),
                    )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: Colors.red,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                const Text('User Input'),
                Container(
                  width: 16,
                  height: 16,
                  color: Colors.black,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                Text(selectedColorSpace.toString()),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("X-axis range"),
            RangeSlider(
              values: xAxisValues,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              labels: RangeLabels(xAxisValues.start.toStringAsFixed(1),
                  xAxisValues.end.toStringAsFixed(1)),
              onChanged: (RangeValues newValues) {
                setState(() {
                  xAxisValues = newValues;
                });
              },
            ),
            const Text("Y-axis range"),
            RangeSlider(
              values: yAxisValues,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              labels: RangeLabels(yAxisValues.start.toStringAsFixed(1),
                  yAxisValues.end.toStringAsFixed(1)),
              onChanged: (RangeValues newValues) {
                setState(() {
                  yAxisValues = newValues;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  LineChart buildLineChart() {
    return LineChart(
      LineChartData(
          minX: xAxisValues.start, // 가로축 최소값
          maxX: xAxisValues.end, // 가로축 최대값
          minY: yAxisValues.start, // 세로축 최소값
          maxY: yAxisValues.end, // 세로축 최대값
          lineBarsData: [
            // 사용자 입력 값에 대한 LineChartBarData
            LineChartBarData(
              spots: _buildUserInputLineChartSpots(),
              isCurved: false,
              dotData: const FlDotData(show: true),
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
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
                barWidth: 2,
                isStrokeCapRound: true,
                color: Colors.black,
                dashArray: [5, 10],
                // Dashed line
              ),
          ],
          borderData: FlBorderData(show: true),
          titlesData: const FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                showTitles: true,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                showTitles: false,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                showTitles: false,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                showTitles: true,
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          lineTouchData: const LineTouchData(enabled: true)),
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
