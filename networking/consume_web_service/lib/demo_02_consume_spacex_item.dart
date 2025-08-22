// Consume the launch from the Space-X (API) web service.
//
// https://github.com/r-spacex/SpaceX-API/blob/master/docs/launches/v4/latest.md
// 
// Web Service
// https://api.spacexdata.com/v4/launches/latest
// curl --request GET --url 'https://api.spacexdata.com/v4/launches/latest'
// 

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Launch> futureLaunch;

  @override
  void initState() {
    super.initState();
    futureLaunch = fetchLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder(
              future: futureLaunch,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Text('Flight Number: ${snapshot.data!.flightNumber}\nName: ${snapshot.data!.name}');
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                return const CircularProgressIndicator();
              }),
        ),
      ),
    );
  }
}

Future<Launch> fetchLaunch() async {
  final response = await http
      .get(Uri.parse('https://api.spacexdata.com/v4/launches/latest'));

  if (response.statusCode == 200) {
    return Launch.fromJSON(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load launch. Response code is ${response.statusCode}');
  }
}

class Launch {
  final int flightNumber;
  final String name;

  const Launch({required this.flightNumber, required this.name});

  factory Launch.fromJSON(Map<String, dynamic> json) {
    return switch (json) {
      {
        'flight_number': int flightNumber,
        'name': String name,
      } =>
        Launch(
          flightNumber: flightNumber,
          name: name,
        ),
      _ => throw const FormatException('Failed to load launch.'),
    };
  }
}
