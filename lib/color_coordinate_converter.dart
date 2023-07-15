import 'package:flutter/material.dart';

class ColorCoordinateConverter extends StatefulWidget {
  @override
  _ColorCoordinateConverterState createState() =>
      _ColorCoordinateConverterState();
}

class _ColorCoordinateConverterState extends State<ColorCoordinateConverter> {
  String _inputColorSpace = 'CIE1931';
  String _outputColorSpace = 'CIE1976';
  String _inputCoordinate1 = '';
  String _inputCoordinate2 = '';
  String _convertedCoordinate1 = '';
  String _convertedCoordinate2 = '';

  void _convertColorCoordinates() {
    double coord1 = double.tryParse(_inputCoordinate1.trim()) ?? 0.0;
    double coord2 = double.tryParse(_inputCoordinate2.trim()) ?? 0.0;

    if (_inputColorSpace == 'CIE1931' && _outputColorSpace == 'CIE1976') {
      double u = (4 * coord1) / (-2 * coord1 + 12 * coord2 + 3);
      double v = (9 * coord2) / (-2 * coord1 + 12 * coord2 + 3);
      _convertedCoordinate1 = u.toStringAsFixed(5);
      _convertedCoordinate2 = v.toStringAsFixed(5);
    } else if (_inputColorSpace == 'CIE1976' &&
        _outputColorSpace == 'CIE1931') {
      double x = (9 * coord1) / (6 * coord1 - 16 * coord2 + 12);
      double y = (4 * coord2) / (6 * coord1 - 16 * coord2 + 12);
      _convertedCoordinate1 = x.toStringAsFixed(5);
      _convertedCoordinate2 = y.toStringAsFixed(5);
    } else {
      _convertedCoordinate1 = 'Invalid';
      _convertedCoordinate2 = 'Invalid';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Input Color Space:',
            style: TextStyle(fontSize: 18),
          ),
          DropdownButton<String>(
            value: _inputColorSpace,
            items: ['CIE1931', 'CIE1976'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _inputColorSpace = newValue!;
              });
            },
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _inputColorSpace == 'CIE1931' ? 'x:' : 'u\':',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    _inputCoordinate1 = text;
                  },
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(width: 16),
              Text(
                _inputColorSpace == 'CIE1931' ? 'y:' : 'v\':',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    _inputCoordinate2 = text;
                  },
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _convertColorCoordinates,
              child: Column(
                children: [
                  Icon(Icons.arrow_downward, size: 32),
                  Text(
                    'Convert',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Output Color Space:',
            style: TextStyle(fontSize: 18),
          ),
          DropdownButton<String>(
            value: _outputColorSpace,
            items: ['CIE1931', 'CIE1976'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _outputColorSpace = newValue!;
              });
            },
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _outputColorSpace == 'CIE1931' ? 'x:' : 'u\':',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _outputColorSpace == 'CIE1931'
                      ? ' $_convertedCoordinate1'
                      : ' $_convertedCoordinate1',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 16),
              Text(
                _outputColorSpace == 'CIE1931' ? 'y:' : 'v\':',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _outputColorSpace == 'CIE1931'
                      ? ' $_convertedCoordinate2'
                      : ' $_convertedCoordinate2',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
