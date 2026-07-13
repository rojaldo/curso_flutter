class ApodData {
  final String title;
  final String date;
  final String explanation;
  final String? imageUrl;
  final String? copyright;
  final String mediaType;
  final String serviceVersion;
  final String? hdUrl;

  ApodData({
    required this.title,
    required this.date,
    required this.explanation,
    required this.mediaType,
    required this.serviceVersion,
    this.imageUrl,
    this.copyright,
    this.hdUrl,
  });

  factory ApodData.fromJson(Map<String, dynamic> json) {
    return ApodData(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      explanation: json['explanation'] ?? '',
      mediaType: json['media_type'] ?? '',
      serviceVersion: json['service_version'] ?? '',
      hdUrl: json['hdurl'],
      imageUrl: json['url'] ?? '',
      copyright: json['copyright'],
    );
  }
}