// Get the address of the current location.
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _location;
  Placemark? _placemark;

  Future<void> _getlocation() async {
    Position location = await getCurrentLocation();
    Placemark placemark = await _getAddressFromLatLng(location.latitude, location.longitude);
    setState(() {
      _location = location;
      _placemark = placemark;
    });
  }

  String _formatLocation() {
    final loc = _location;
    if (loc == null) return '-';
    return 'Latitude: ${loc.latitude} - Longitude: ${loc.longitude}';
  }

  String _formatPlacemark() {
    final place = _placemark;
    if (place == null) return '-';
    return 'Street: ${place.street}, Locality: ${place.locality}, Country: ${place.country}';
  }

  Future<Placemark> _getAddressFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks[0];
  
    //print('${place.street}, ${place.locality}, ${place.country}');
    return place;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('Location'),
            Text(_formatLocation()),
            Text(_formatPlacemark()),
            ElevatedButton(onPressed: _getlocation, child: Text('Get Location')),
          ],
        ),
      ),
    );
  }
}

Future<Position> getCurrentLocation() async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Check and request permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  // Use LocationSettings instead of desiredAccuracy
  Position position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );

  // print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');

  return position;
}
