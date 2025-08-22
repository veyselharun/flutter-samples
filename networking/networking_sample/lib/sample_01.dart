// Consume a single item from a web service.
//
// Consume the item and just show it. 
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

  // Root of the application.
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
      body: Center(
        child: FutureBuilder<GitHubUser>(
          // Provide the Future that fetches the data
          future: futureGitHubUser,
          // Define the builder function to build the UI based on the snapshot
          builder: (BuildContext context, AsyncSnapshot<GitHubUser> snapshot) {
            // Check if the data has been successfully fetched
            if (snapshot.hasData) {
              // Data is available, create and return the UserCard widget
              // Pass the relevant data from the snapshot.data object to UserCard
              return Text(
                'GitHub User: ${snapshot.data!.name} ${snapshot.data!.login}',
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

/// Fetches the GitHub user data for the 'flutter' user.
///
/// Returns a [Future] that completes with a [GitHubUser] object
/// if the request is successful. Throws an exception otherwise.
Future<GitHubUser> fetchGitHubUser() async {
  final url = Uri.parse('https://api.github.com/users/flutter');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return GitHubUser.fromJSON(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to fetch GitHub user.');
  }
}

class GitHubUser {
  const GitHubUser({required this.name, required this.login});

  final String name;
  final String login;

  factory GitHubUser.fromJSON(Map<String, dynamic> json) {
    return switch (json) {
      {'name': String name, 'login': String login} => GitHubUser(
        name: name,
        login: login,
      ),
      _ => throw const FormatException('Failed to create GitHubUser object.'),
    };
  }
}
