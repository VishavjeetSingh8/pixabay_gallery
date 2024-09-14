class ImageModel {
  final String id;
  final String webFormatUrl;
  final String largeImageUrl;
  final int likes;
  final int views;

  ImageModel({
    required this.id,
    required this.webFormatUrl,
    required this.largeImageUrl,
    required this.likes,
    required this.views,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'].toString(),
      webFormatUrl: json['webformatURL'],
      largeImageUrl: json['largeImageURL'],
      likes: json['likes'],
      views: json['views'],
    );
  }
}
