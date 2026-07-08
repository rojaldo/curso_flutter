import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApodPage extends StatelessWidget {
  const ApodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apod'),
      ),
      body: const Center(
        child: ApodWidget(),
      ),
    );
  }
}

class ApodWidget extends StatefulWidget {
  const ApodWidget({super.key});

  @override
  State<ApodWidget> createState() => _ApodWidgetState();
}

class _ApodWidgetState extends State<ApodWidget> {

  Map<String, dynamic>? _apodData;


  @override
  void initState() {
    super.initState();
    // Here you can initiate the API call to fetch the APOD data
    _fetchApodData();
  }

  @override
  Widget build(BuildContext context) {
    if (_apodData == null) {
      return const CircularProgressIndicator();
    }

//scroll with column and image, title and explanation
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        if (_apodData!['media_type'] == 'image')
          Image.network(_apodData!['url']),
        const SizedBox(height: 16),
        Text(
          _apodData!['title'] ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(_apodData!['explanation'] ?? ''),
      ],
      ),
    );
  }

  Future<void> _fetchApodData() async {
    final url = Uri.parse('https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date=2026-06-07');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Successfully fetched data
      setState(() {
        _apodData = Map<String, dynamic>.from(jsonDecode(response.body));
      });
    } else {
      // Handle error
      setState(() {
        _apodData = {'title': 'Error', 'explanation': 'Failed to fetch data'};
      });
    }
  }
}