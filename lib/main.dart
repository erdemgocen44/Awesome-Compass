import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const Compass());

class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  bool _hasPermissions = false;
  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      setState(() {
        _hasPermissions == (status == PermissionStatus.granted);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Commpass App',
      home: Scaffold(
        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

  //compass widget commerce

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
//add error message

        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        //add loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        //if direction is null==then device does not support the sensor

        if (direction == null) {
          return const Center(
            child: Text('Device does not have sensors!'),
          );
        }
        //return compass

        return Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Image.asset(
                'assets/images/compass.png',
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  //permission sheet widget commerce
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text('Request Permission'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }
}
