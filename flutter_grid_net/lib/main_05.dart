// GridView with dynamic images gathered from NASA Open API.
// https://api.nasa.gov
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// For API connection
import 'package:http/http.dart' as http;

// For JSON
import 'dart:convert';

// To show the image gathered from netwok
import 'package:cached_network_image/cached_network_image.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ApodImage> _apodImages = [];
  bool _isLoading = true;
  String? _error;

  // We use DEMO_KEY for testing.
  // You can replace with your own API key from api.nasa.gov
  static const String _apiKey = 'DEMO_KEY';
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  @override
  void initState() {
    super.initState();
    _fetchApodImages();
  }

  Future<void> _fetchApodImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch 12 random images using the count parameter
      final uri = Uri.parse('$_baseUrl?api_key=$_apiKey&count=12');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // Filter to only include image-type entries (skip videos)
        final images = jsonList
            .map((json) => ApodImage.fromJson(json))
            .where((image) => image.mediaType == 'image')
            .toList();

        setState(() {
          _apodImages = images;
          _isLoading = false;
        });
      } else if (response.statusCode == 429) {
        throw Exception(
          'Rate limit exceeded. Please wait a moment and try again.',
        );
      } else {
        throw Exception('Failed to load images: HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Home Page'),
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching images from NASA...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Text('Error while fetching images from NASA!'),
          ],
        ),
      );
    }

    if (_apodImages.isEmpty) {
      return const Center(child: Text('No images found. Try refreshing.'));
    }

    // RefreshIndicator is a Flutter widget that adds pull-to-refresh 
    // functionality to a scrollable widget.
    // When the user pulls down past a certain threshold, it shows a 
    // circular loading spinner and triggers a callback (_fetchApodImages()) 
    // to reload the data.
    return RefreshIndicator(
      onRefresh: _fetchApodImages, // called when user pulls down
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: MainHeader()),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: _apodImages.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                child: CachedNetworkImage(
                  imageUrl: _apodImages[index].url,
                  fit: BoxFit.cover,
                ),
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
        'Astronomy Picture of the Day',
        textAlign: .center,
        style: GoogleFonts.spaceGrotesk(
          textStyle: TextStyle(
            color: const Color(0xFF3E2723),
            fontSize: 26,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Model for APOD image
class ApodImage {
  final String date;
  final String title;
  final String explanation;
  final String url;
  final String? hdurl;
  final String mediaType;
  final String? copyright;

  ApodImage({
    required this.date,
    required this.title,
    required this.explanation,
    required this.url,
    this.hdurl,
    required this.mediaType,
    this.copyright,
  });

  factory ApodImage.fromJson(Map<String, dynamic> json) {
    return ApodImage(
      date: json['date'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      hdurl: json['hdurl'],
      mediaType: json['media_type'] ?? 'image',
      copyright: json['copyright'],
    );
  }
}
