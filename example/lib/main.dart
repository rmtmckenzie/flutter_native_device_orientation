import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool useSensor = false;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Native Orientation example app'),
          actions: <Widget>[Switch(value: useSensor, onChanged: (val) => setState(() => useSensor = val))],
        ),
        body: NativeDeviceOrientationReader(
          builder: (context) {
            NativeDeviceOrientation orientation = NativeDeviceOrientationReader.orientation(context);
            return Center(child: Text('Native Orientation: ${orientation.toString()}\n'));
          },
          useSensor: useSensor,
        ),
      ),
    );
  }
}
