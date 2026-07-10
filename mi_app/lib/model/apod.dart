class Apod {
  final String title;
  final String explanation;
  final String url;
  final String date;
  final String mediaType;
  final String serviceVersion;
  final String? hdUrl;
  final String? copyright;

  bool isMp4Video = false; // This will be set based on the mediaType
  bool isYoutubeVideo = false; // This will be set based on the mediaType
  bool isImage = false; // This will be set based on the mediaType

  Apod({
    required this.title,
    required this.explanation,
    required this.url,
    required this.date,
    required this.mediaType,
    required this.serviceVersion,
    this.hdUrl,
    this.copyright,
  });

  factory Apod.fromJson(Map<String, dynamic> json) {
    var result = Apod(
      title: json['title'],
      explanation: json['explanation'],
      url: json['url'],
      date: json['date'],
      mediaType: json['media_type'],
      serviceVersion: json['service_version'],
      hdUrl: json['hdurl'],
      copyright: json['copyright'],
    );
    result.isMp4Video =
        result.mediaType == 'video' && result.url.endsWith('.mp4');
    result.isYoutubeVideo =
        result.mediaType == 'video' && result.url.contains('youtube.com');
    result.isImage = result.mediaType == 'image';
    return result;
  }
}
