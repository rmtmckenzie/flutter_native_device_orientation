import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool useSensor = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Native Orientation Example'),
            actions: <Widget>[
              Center(child: Text('Sensor:')),
              Switch(
                  value: useSensor,
                  onChanged: (val) => setState(() => useSensor = val)),
            ],
          ),
          body: NativeDeviceOrientedWidget(
            landscape: (context) {
              return Center(
                  child:
                      Text('Native Orientation: Landscape (Unknown Side)\n'));
            },
            landscapeLeft: (context) {
              return Center(
                  child: Text('Native Orientation: Landscape Left\n'));
            },
            landscapeRight: (context) {
              return Center(
                  child: Text('Native Orientation: Landscape Right\n'));
            },
            portrait: (context) {
              return Center(
                  child: Text('Native Orientation: Portrait (Unknown Side)\n'));
            },
            portraitUp: (context) {
              return Center(child: Text('Native Orientation: Portrait Up\n'));
            },
            portraitDown: (context) {
              return Center(child: Text('Native Orientation: Portrait Down\n'));
            },
            fallback: (context) {
              return Center(child: Text('Native Orientation: Unknown\n'));
            },
            useSensor: useSensor,
          ),
          floatingActionButton: Builder(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    child: Text('Sensor'),
                    onPressed: () async {
                      final orientation =
                          await NativeDeviceOrientationCommunicator()
                              .orientation(useSensor: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Native Orientation read: $orientation'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    child: Text('UI'),
                    onPressed: () async {
                      final orientation =
                          await NativeDeviceOrientationCommunicator()
                              .orientation(useSensor: false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Native Orientation read: $orientation'),
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
