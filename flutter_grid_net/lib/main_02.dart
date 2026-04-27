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
    'assets/images/india_chennai_flower_market.png',
    'assets/images/india_chennai_highway.png',
    'assets/images/india_chettinad_produce.png',
    'assets/images/india_chettinad_silk_maker.png',
    'assets/images/india_pondicherry_beach.png',
    'assets/images/india_pondicherry_fisherman.png',
    'assets/images/india_pondicherry_salt_farm.png',
    'assets/images/india_tanjore_bronze_works.png',
    'assets/images/india_tanjore_market_merchant.png',
    'assets/images/india_tanjore_thanjavur_temple_carvings.png',
    'assets/images/india_tanjore_thanjavur_temple.png',
    'assets/images/india_thanjavur_market.png',
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
