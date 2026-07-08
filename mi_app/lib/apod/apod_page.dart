import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mi_app/model/apod.dart';

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

  Apod? _apodData;


  @override
  void initState() {
    super.initState();
    // Here you can initiate the API call to fetch the APOD data
    _fetchApodData();
  }



  Future<void> _fetchApodData([String? date]) async {
    const apiKey = "tqz634Z1x0LiJzjbhSyUoExrZaGKLM0MG1VnROR6";
    final url = Uri.parse('https://api.nasa.gov/planetary/apod?api_key=$apiKey${date != null ? '&date=$date' : ''}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Successfully fetched data
      setState(() {
        _apodData = Apod.fromJson(json.decode(response.body));
      });
    } else {
      // Handle error
      setState(() {
        _apodData = Apod(
          title: 'Error',
          explanation: 'Failed to fetch data',
          url: '',
          date: '',
          mediaType: '',
          serviceVersion: '',
        );
      });
    }
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
          ApodPicker(onDateSelected: _fetchApodData),
        ApodInfo(apodData: _apodData!),
        ],
      ),
    );
  }

}

class ApodPicker extends StatelessWidget {
  final ValueChanged<String?> onDateSelected;

  const ApodPicker({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1995, 6, 16),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate.toIso8601String().split('T').first);
        }
      },
      child: const Text('Select Date'),
    );
  }
}

class ApodInfo extends StatelessWidget {
  final Apod apodData;

  const ApodInfo({super.key, required this.apodData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (apodData.isImage)
          Image.network(apodData.url),
        const SizedBox(height: 16),
        Text(
          apodData.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(apodData.explanation),
      ],
    );
  }
}