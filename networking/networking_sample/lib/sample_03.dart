// Consume a list from a web service.
//
// The web service information and the Flutter documentation is given below.
//
// Web Service
// curl --request GET --url 'https://api.github.com/users/flutter/followers'
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
  late Future<List<GitHubFollower>> futureGitHubFollowers;

  @override
  void initState() {
    super.initState();
    futureGitHubFollowers = fetchGitHubFollowers();
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
        child: FutureBuilder<List<GitHubFollower>>(
          // Provide the Future that fetches the data
          future: futureGitHubFollowers,
          // Define the builder function to build the UI based on the snapshot
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<GitHubFollower>> snapshot,
              ) {
                // Check if the data has been successfully fetched
                if (snapshot.hasData) {
                  // Data is available, create and return the list widget
                  // Pass the relevant data from the snapshot.data object to UserCard
                  return SizedBox(
                    width: double.infinity, // Use available width
                    child: FollowerList(myListItems: snapshot.data!),
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

class FollowerList extends StatelessWidget {
  const FollowerList({super.key, required this.myListItems});

  final List<GitHubFollower> myListItems;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: myListItems.length,
      /*
      prototypeItem: ListTile(
          leading: const Icon(Icons.cloud),
          title: Text('Follower Login: ${myListItems[index].login}'),
          subtitle: Text('Login: ${myListItems[index].login}'),
      ),*/
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(Icons.cloud),
          title: Text('Follower Login: ${myListItems[index].login}'),
          subtitle: Text('Login: ${myListItems[index].login}'),
        );
      },
    );
  }
}

Future<List<GitHubFollower>> fetchGitHubFollowers() async {
  // Ensure the URL is correctly formatted (trim whitespace)
  final url = Uri.parse('https://api.github.com/users/flutter/followers');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the JSON body
      var followerList = <GitHubFollower>[];
      List<dynamic> followerJSONList = jsonDecode(response.body);

      // Iterate through each item and convert to Map<String, dynamic>
      for (final item in followerJSONList) {
        if (item is Map<String, dynamic>) {
          followerList.add(GitHubFollower.fromJSON(item));
        } else {
          print('Unexpected item type: ${item.runtimeType}');
          throw Exception('Invalid item format in JSON response');
        }
      }

      return followerList;
    } else {
      // Log details for debugging
      print(
        'Failed to fetch GitHub follower. HTTP Status Code: ${response.statusCode}',
      );
      print('Response body: ${response.body}');

      // Throw a more informative exception
      // You could create a custom Exception class if needed
      throw Exception(
        'Failed to fetch GitHub follower. Status code: ${response.statusCode}',
      );
    }
  } on http.ClientException catch (e) {
    // Catch network related errors from the http package
    print('Network error occurred while fetching GitHub follower: $e');
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

class GitHubFollower {
  const GitHubFollower({required this.login});

  final String login;

  factory GitHubFollower.fromJSON(Map<String, dynamic> json) {
    return switch (json) {
      {'login': String login} => GitHubFollower(login: login),
      _ => throw const FormatException(
        'Failed to create GitHubFollower object.',
      ),
    };
  }
}
