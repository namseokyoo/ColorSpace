import 'package:flutter/material.dart';

class Informations extends StatelessWidget {
  final Map<String, List<ColorPoint>> colorSpaces = {
    'sRGB': [
      ColorPoint('Red', 0.640, 0.330),
      ColorPoint('Green', 0.300, 0.600),
      ColorPoint('Blue', 0.150, 0.060),
    ],
    'Adobe RGB': [
      ColorPoint('Red', 0.640, 0.330),
      ColorPoint('Green', 0.210, 0.710),
      ColorPoint('Blue', 0.150, 0.060),
    ],
    'BT.2020': [
      ColorPoint('Red', 0.708, 0.292),
      ColorPoint('Green', 0.170, 0.797),
      ColorPoint('Blue', 0.131, 0.046),
    ],
    'DCI-P3': [
      ColorPoint('Red', 0.680, 0.320),
      ColorPoint('Green', 0.265, 0.690),
      ColorPoint('Blue', 0.150, 0.060),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: colorSpaces.keys.length,
        itemBuilder: (context, index) {
          String key = colorSpaces.keys.elementAt(index);
          return Card(
            child: Column(
              children: [
                Text(key, style: const TextStyle(fontSize: 20)),
                DataTable(
                  columnSpacing: 25, // Column 간격을 조정합니다.
                  columns: const [
                    DataColumn(label: Text('Color')),
                    DataColumn(label: Text('CIEx')),
                    DataColumn(label: Text('CIEy')),
                  ],
                  rows: colorSpaces[key]!
                      .map((colorPoint) => DataRow(cells: [
                            DataCell(Text(colorPoint.color)),
                            DataCell(Text(colorPoint.x.toStringAsFixed(
                                3))), // toStringAsFixed 메서드로 소수점 아래 3자리까지 출력하도록 수정하였습니다.
                            DataCell(Text(colorPoint.y.toStringAsFixed(
                                3))), // toStringAsFixed 메서드로 소수점 아래 3자리까지 출력하도록 수정하였습니다.
                          ]))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ColorPoint {
  final String color;
  final double x;
  final double y;

  ColorPoint(this.color, this.x, this.y);
}
