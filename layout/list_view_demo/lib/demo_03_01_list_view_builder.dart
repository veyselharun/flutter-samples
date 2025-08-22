// https://docs.flutter.dev/cookbook/lists/long-lists

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

  List<String> createListItems() {
    List<String> myListItems =
        List<String>.generate(20000, (index) => 'Item ${index + 1}');
    return myListItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: MyListViewWidget(myListItems: createListItems()),
    );
  }
}

class MyListViewWidget extends StatelessWidget {
  final List<String> myListItems;

  const MyListViewWidget({super.key, required this.myListItems});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: myListItems.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            leading: const Icon(Icons.cloud),
            title: Text(myListItems[index]));
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
