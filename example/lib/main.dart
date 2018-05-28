import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Native Orientation example app'),
        ),
        body: new DeviceOrientationListener(
          builder: (context) {
            NativeDeviceOrientation orientation =
                DeviceOrientationListener.orientation(context);
            return new Center(
                child: Text('Native Orientation: ${orientation.toString()}\n'));
          },
        ),
      ),
    );
  }
}
