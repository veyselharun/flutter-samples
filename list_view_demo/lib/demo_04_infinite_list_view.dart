// Useful Resource
// https://www.dhiwise.com/post/infinite-list-in-flutter-scroll-more-load-less

import 'package:flutter/material.dart';

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
  final List<String> _myListItems = List<String>.generate(
      20, (index) => 'Item ${index + 1} - Current Page 1');
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(loadNewPage);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadNewPage() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _currentPage++;
        _myListItems.addAll(List<String>.generate(
            20,
            (index) =>
                'Item ${index + 1 + ((_currentPage - 1) * 20)} - Current Page $_currentPage'));
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
