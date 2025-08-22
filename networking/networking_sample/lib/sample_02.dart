// Consume a single item from a web service.
//
// Consume the item and show it in a widget.
//
// The web service information and the Flutter documentation is given below.
//
// Web Service
// curl --request GET --url 'https://api.github.com/users/flutter'
//
// Flutter and Dart Documentation
// https://docs.flutter.dev/cookbook/networking/fetch-data
// https://dart.dev/tutorials/server/fetch-data

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  late Future<GitHubUser> futureGitHubUser;

  @override
  void initState() {
    super.initState();
    futureGitHubUser = fetchGitHubUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        // Optional: Add some padding around the card if desired
        padding: const EdgeInsets.all(16.0),
        // Use FutureBuilder to handle the asynchronous data fetching
        child: FutureBuilder<GitHubUser>(
          // Provide the Future that fetches the data
          future: futureGitHubUser,
          // Define the builder function to build the UI based on the snapshot
          builder: (BuildContext context, AsyncSnapshot<GitHubUser> snapshot) {
            // Check if the data has been successfully fetched
            if (snapshot.hasData) {
              // Data is available, create and return the UserCard widget
              // Pass the relevant data from the snapshot.data object to UserCard
              return SizedBox(
                width: double.infinity, // Use available width
                child: UserCard(
                  login: snapshot.data!.login,
                  htmlUrl: snapshot.data!.htmlUrl,
                  followers: snapshot.data!.followers,
                ),
              );
            } else if (snapshot.hasError) {
              // An error occurred during fetching, display the error message
              return Text('${snapshot.error}');
            }

            // Data is still loading, show a progress indicator
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.login,
    required this.htmlUrl,
    required this.followers,
  });

  final String login;
  final String htmlUrl;
  final int followers;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Use decoration for more styling options (like rounded corners, borders)
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer, // Background color
        borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
      ),
      padding: const EdgeInsets.all(16.0), // Padding inside the card
      // Use Column with MainAxisSize.min
      child: Column(
        mainAxisSize: MainAxisSize.min, // Don't take all available height
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
        children: [
          Text('User name: $login'),
          Text('URL: $htmlUrl'),
          Text('Number of followers: ${followers.toString()}'),
        ],
      ),
    );
  }
}

/// Fetches the GitHub user data for the 'flutter' user.
///
/// Returns a [Future] that completes with a [GitHubUser] object
/// if the request is successful. Throws an exception otherwise.
Future<GitHubUser> fetchGitHubUser() async {
  // Ensure the URL is correctly formatted (trim whitespace)
  final url = Uri.parse('https://api.github.com/users/flutter');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the JSON body
      final dynamic jsonData = jsonDecode(response.body);

      // Ensure the decoded data is a Map before casting
      if (jsonData is Map<String, dynamic>) {
        return GitHubUser.fromJSON(jsonData);
      } else {
        // Handle unexpected JSON structure (e.g., if the API returned an array or null)
        print('Error: Unexpected JSON structure received.');
        print('Expected Map<String, dynamic>, got ${jsonData.runtimeType}');
        throw Exception(
          'Failed to parse GitHub user data: Invalid JSON structure.',
        );
      }
    } else {
      // Log details for debugging
      print(
        'Failed to fetch GitHub user. HTTP Status Code: ${response.statusCode}',
      );
      print('Response body: ${response.body}');

      // Throw a more informative exception
      // You could create a custom Exception class if needed
      throw Exception(
        'Failed to fetch GitHub user. Status code: ${response.statusCode}',
      );
    }
  } on http.ClientException catch (e) {
    // Catch network related errors from the http package
    print('Network error occurred while fetching GitHub user: $e');
    throw Exception('Network error: Failed to reach GitHub API.');
  } on FormatException catch (e) {
    // Catch JSON decoding errors
    print('Error decoding JSON response: $e');
    throw Exception('Failed to parse response from GitHub API.');
  } on Exception {
    // Re-throw any other exceptions that might occur
    rethrow;
  }
}

class GitHubUser {
  const GitHubUser({
    required this.login,
    required this.htmlUrl,
    required this.followers,
  });

  final String login;
  final String htmlUrl;
  final int followers;

  factory GitHubUser.fromJSON(Map<String, dynamic> json) {
    return switch (json) {
      {
        'login': String login,
        'html_url': String htmlUrl,
        'followers': int followers,
      } =>
        GitHubUser(login: login, htmlUrl: htmlUrl, followers: followers),
      _ => throw const FormatException('Failed to create GitHubUser object.'),
    };
  }
}
