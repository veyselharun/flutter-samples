// https://www.dhiwise.com/post/infinite-list-in-flutter-scroll-more-load-less

// Consume a list from the web service.
//
// The web service information and the Flutter documentation is given below.
// 
// Web Service
// https://docs.spacexdata.com
// curl --request GET --url 'https://api.spacexdata.com/v3/launches?limit=20&offset=0'
// 
// Flutter Documentation
// https://docs.flutter.dev/cookbook/networking/fetch-data


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const MyListViewWidget(),
    );
  }
}

class MyListViewWidget extends StatefulWidget {
  const MyListViewWidget({super.key});

  @override
  State<MyListViewWidget> createState() => _MyListViewWidgetState();
}

class _MyListViewWidgetState extends State<MyListViewWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _myListItems = <String>[];
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(loadNewPage);
    _fetchData(_offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(int offset) async {
    final response = await http
        .get(Uri.parse('https://api.spacexdata.com/v3/launches?limit=20&offset=$_offset'));
    if (response.statusCode == 200) {
      // After parsing JSON get only one String.
      setState(() {
        _myListItems.addAll(List<String>.from(jsonDecode(response.body)));
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void loadNewPage() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _offset = _offset + 20;
        _fetchData(_offset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _myListItems.length,
      prototypeItem: ListTile(
        leading: const Icon(Icons.cloud_circle),
        title: Text(_myListItems.first),
      ),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading: const Icon(Icons.cloud), title: Text(_myListItems[index]));
      },
    );
  }
}
