// Consume the launch list from the Space-X (API) web service.
//
// https://github.com/r-spacex/SpaceX-API/blob/master/docs/launches/v4/latest.md
// 
// Web Service
// https://api.spacexdata.com/v4/launches/latest
// curl --request GET --url 'https://jsonplaceholder.typicode.com/albums/1'
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
  late Future<List<Launch>> futureLaunch;

  @override
  void initState() {
    super.initState();
    futureLaunch = fetchAllLaunches();
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
                  return MyListViewWidget(myListItems: snapshot.data!);
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

class MyListViewWidget extends StatelessWidget {
  final List<Launch> myListItems;

  const MyListViewWidget({super.key, required this.myListItems});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: myListItems.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(Icons.cloud),
          title: Text('Flight Number: ${myListItems[index].flightNumber}'),
          subtitle: Text(
              'Mission Name: ${myListItems[index].missionName}'),
        );
      },
    );
  }
}

Future<List<Launch>> fetchAllLaunches() async {
  final response =
      await http.get(Uri.parse('https://api.spacexdata.com/v3/launches'));

  if (response.statusCode == 200) {
    var launchList = <Launch>[];
    List<dynamic> launchJSONList = jsonDecode(response.body);
    for (final item in launchJSONList) {
      launchList.add(Launch.fromJSON(item));
    }
    return launchList;
    //return Album.fromJSON(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load launch list. Response code is ${response.statusCode}');
  }
}

class Launch {
  final int flightNumber;
  final String missionName;

  const Launch({required this.flightNumber, required this.missionName});

  factory Launch.fromJSON(Map<String, dynamic> json) {
    return switch (json) {
      {
        'flight_number': int flightNumber,
        'mission_name': String missionName,
      } =>
        Launch(
          flightNumber: flightNumber,
          missionName: missionName,
        ),
      _ => throw const FormatException('Failed to load launch list.'),
    };
  }
}

