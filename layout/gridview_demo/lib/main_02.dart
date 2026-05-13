// GridView with static images
import 'package:flutter/material.dart';

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
      home: const HomePage(),
    );
  }
}

// Currently GridView is not scrollable with the content above.
// CustomScrollView with SliverGrid will be better.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<String> images = const [
    'assets/images/image_01.jpg',
    'assets/images/image_02.jpg',
    'assets/images/image_03.jpg',
    'assets/images/image_04.jpg',
    'assets/images/image_05.jpg',
    'assets/images/image_06.jpg',
    'assets/images/image_07.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Home Page'),
      ),
      // GridView.builder() doesn't create all items at once.
      // It only builds items that are visible on screen (lazy loading).
      // As the user scrolls, it builds more items on demand.
      // It builds until itemCount number.
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // Will be implemented later.
            },
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }
}
