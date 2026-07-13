// thjis page shows an example of how to fetch data from Apod API forom NASA and display it in a Flutter app. It uses the http package to make a GET request to the API, and then parses the JSON response to extract the relevant data. The page displays the title, date, explanation, and image of the Astronomy Picture of the Day (APOD). It also includes error handling for network issues and API errors.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/model/apod_data.dart';

class ApodPage extends StatefulWidget {
  const ApodPage({super.key, this.client});

  final http.Client? client;

  @override
  State<ApodPage> createState() => _ApodPageState();


}

class _ApodPageState extends State<ApodPage> {

  late Future<ApodData> _futureApodData;
  DateTime? selectedDate;


  // fetch data from nasa with opcional parameter date, if date is null, it will fetch the data for today
  Future<ApodData> fetchApodData({DateTime? date}) async {
    var formattedDate = '';
    if (date != null) {
      formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    else {
      formattedDate = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    }
    const apiKey = 'DEMO_KEY'; // Replace with your actual NASA API key
    final url = Uri.parse('https://api.nasa.gov/planetary/apod?api_key=$apiKey&date=$formattedDate');
    final response = await (widget.client ?? http.Client()).get(url);
    if (response.statusCode == 200) {
      return ApodData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load APOD data');
    }


  }


// initial state
@override
  void initState() {
    super.initState();
    // fetch data from API
    _futureApodData = fetchApodData();

  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      // today's date get from system
      initialDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      // june 15th 1995
      firstDate: DateTime(1995, 6, 16),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    setState(() {
      selectedDate = pickedDate;
      _futureApodData = fetchApodData(date: selectedDate);
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Astronomy Picture of the Day')),
      body: FutureBuilder<ApodData>(
        future: _futureApodData,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final apodData = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton(
                    onPressed: _selectDate,
                    child: const Text('Select Date'),
                  ),
                  if (apodData.imageUrl != null && apodData.imageUrl!.isNotEmpty)
                    Image.network(apodData.imageUrl!),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      apodData.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(apodData.date),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(apodData.explanation),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}