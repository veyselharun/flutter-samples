// GridView with static images
// Add Google Fonts package
// https://pub.dev/packages/google_fonts
import 'package:flutter/material.dart';

// To use Google Fonts package
import 'package:google_fonts/google_fonts.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: MainHeader()),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                child: Image.asset(images[index], fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Text(
        'The Images',
        textAlign: .center,
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            color: const Color(0xFF3E2723),
            fontSize: 32,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}
