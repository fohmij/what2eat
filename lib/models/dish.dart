class Dish {
  Dish({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.localImagePath,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? localImagePath;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'tags': tags,
    };
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      localImagePath: json['localImagePath'] as String?,
      tags: List<String>.from(json['tags'] ?? [])
    );
  }
}