class NasaImage {
  final String title;
  final String description;
  final String imageUrl;
  final String date;

  NasaImage({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
  });

  factory NasaImage.fromJson(Map<String, dynamic> json) {
    return NasaImage(
      title: json['title'] ?? 'No title',
      description: json['explanation'] ?? 'No description',
      imageUrl: json['hdurl'] ?? '',
      date: json['date'] ?? 'No date',
    );
  }
}
