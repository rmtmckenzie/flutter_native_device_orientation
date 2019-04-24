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
              print("Received new orientation: $orientation");
              return Center(child: Text('Native Orientation: $orientation\n'));
            },
            useSensor: useSensor,
          ),
          floatingActionButton: Builder(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    child: Text("Sensor"),
                    onPressed: () async {
                      NativeDeviceOrientation orientation =
                      await NativeDeviceOrientationCommunicator().orientation(useSensor: true);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Native Orientation read: $orientation"),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    child: Text("UI"),
                    onPressed: () async {
                      NativeDeviceOrientation orientation =
                          await NativeDeviceOrientationCommunicator().orientation(useSensor: false);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Native Orientation read: $orientation"),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          )),
    );
  }
}
