// Consume the album list from the web service.
//
// The web service information and the Flutter documentation is given below.
// 
// Web Service
// https://jsonplaceholder.typicode.com
// curl --request GET --url 'https://jsonplaceholder.typicode.com/albums'
// 
// Flutter Documentation
// https://docs.flutter.dev/cookbook/networking/fetch-data

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
  late Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAllAlbums();
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
              future: futureAlbum,
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
  final List<Album> myListItems;

  const MyListViewWidget({super.key, required this.myListItems});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: myListItems.length,
      // Prototype item produces incorrect vertical posititioning. Because 
      // album titles have different sizes and some of them wrap to the next
      // line.
      /*
      prototypeItem: ListTile(
        leading: const Icon(Icons.cloud_circle),
        title: Text('Album Title: ${myListItems.first.title}'),
        subtitle: Text('Album Id: ${myListItems.first.id.toString()} - User Id: ${myListItems.first.userId.toString()}'),
      ),*/
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(Icons.cloud),
          title: Text('Album Title: ${myListItems[index].title}'),
          subtitle: Text(
              'Album Id: ${myListItems[index].id.toString()} - User Id: ${myListItems[index].userId.toString()}'),
        );
      },
    );
  }
}

Future<List<Album>> fetchAllAlbums() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

  if (response.statusCode == 200) {
    var albumList = <Album>[];
    List<dynamic> albumJSONList = jsonDecode(response.body);
    for (final item in albumJSONList) {
      albumList.add(Album.fromJSON(item));
    }
    return albumList;
  } else {
    throw Exception('Failed to load album.');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({required this.userId, required this.id, required this.title});

  factory Album.fromJSON(Map<String, dynamic> json) {
    return switch (json) {
      {
        'userId': int userId,
        'id': int id,
        'title': String title,
      } =>
        Album(
          userId: userId,
          id: id,
          title: title,
        ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}
