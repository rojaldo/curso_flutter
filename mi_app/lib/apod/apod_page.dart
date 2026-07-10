import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mi_app/model/apod.dart';
import 'package:video_player/video_player.dart';

class ApodPage extends StatelessWidget {
  const ApodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apod')),
      body: const Center(child: ApodWidget()),
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
    const apiKey = "DEMO_KEY"; // Replace with your actual NASA API key
    final url = Uri.parse(
      'https://api.nasa.gov/planetary/apod?api_key=$apiKey${date != null ? '&date=$date' : ''}',
    );
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
        if (apodData.isImage) Image.network(apodData.url),
        if (apodData.isMp4Video || apodData.isYoutubeVideo)
          MyVideoPlayerWidget(apodData: apodData),
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

class MyVideoPlayerWidget extends StatefulWidget {
  final Apod apodData;

  const MyVideoPlayerWidget({super.key, required this.apodData});

  @override
  State<MyVideoPlayerWidget> createState() => _MyVideoPlayerWidgetState();
}

class _MyVideoPlayerWidgetState extends State<MyVideoPlayerWidget> {
  VideoPlayerController? _controller;

  bool get _supportsInlineVideo {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant MyVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apodData.url != widget.apodData.url) {
      _disposeController();
      _initializeController();
    }
  }

  void _initializeController() {
    if (widget.apodData.isMp4Video && _supportsInlineVideo) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.apodData.url))
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
              }
            });
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.apodData.isYoutubeVideo) {
      return Column(
        children: [
          const Text('This is a YouTube video. Please open it in a browser.'),
        ],
      );
    }

    if (widget.apodData.isMp4Video && !_supportsInlineVideo) {
      return Column(
        children: [
          const Text(
            'This MP4 video cannot be played inline on this platform.',
          ),
          SelectableText(widget.apodData.url),
        ],
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    if (widget.apodData.isMp4Video) {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
    }

    return const SizedBox.shrink();
  }
}
