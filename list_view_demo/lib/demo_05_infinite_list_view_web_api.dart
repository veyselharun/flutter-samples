// https://www.dhiwise.com/post/infinite-list-in-flutter-scroll-more-load-less

// Consume a list from the web service using pagination.
//
// The web service information and the Flutter documentation is given below.
// 
// Web Service
// https://jsonplaceholder.typicode.com
// curl --request GET --url 'https://jsonplaceholder.typicode.com/posts?_page=1&_limit=2'
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
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(loadNewPage);
    _fetchData(_page);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(int offset) async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_page=$_page&_limit=10'));
    if (response.statusCode == 200) {
      // After parsing JSON get only one String.
      setState(() {
        //final headers = jsonDecode(response.headers) as Map<String, String>;
        final List<dynamic> posts = jsonDecode(response.body);
        if (posts.isNotEmpty) {
          final postTitles = posts.map((post) => post['body'] as String);
          _myListItems.addAll(List<String>.from(postTitles));
        }        
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void loadNewPage() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _page++;
        _fetchData(_page);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _myListItems.length,
      /*
      prototypeItem: ListTile(
        leading: const Icon(Icons.cloud_circle),
        title: Text(_myListItems.first),
      ),*/
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading: const Icon(Icons.cloud), title: Text(_myListItems[index]));
      },
    );
  }
}
