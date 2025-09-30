import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasPermissions = false;

  @override
  void initState() {
    super.initState();
    fetchPermissionStatus();
  }

  void fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          hasPermissions = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.brown,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.brown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Compass"),
        ),
        body: hasPermissions ? buildCompass() : buildPermissionSheet(),
      ),
    );
  }

  Widget buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error reading heading ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        double? direction = snapshot.data!.heading;
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors", style: TextStyle(color: Colors.white)),
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,
              child: Image.asset(
                "lib/compass.png",
                color: Colors.brown.shade100,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await Permission.locationWhenInUse.request();
          fetchPermissionStatus();
        },
        child: const Text("Request Permission"),
      ),
    );
  }
}
