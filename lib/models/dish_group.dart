class DishGroup {
  DishGroup({
    required this.id,
    required this.name,
    required this.dishIds,
    this.isDeletable = true,
  });

  final String id;
  final String name;
  final List<String> dishIds; // IDs der Gerichte in dieser Gruppe
  final bool isDeletable;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dishIds': dishIds,
      'isDeletable': isDeletable,
    };
  }

  factory DishGroup.fromJson(Map<String, dynamic> json) {
    return DishGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      dishIds: List<String>.from(json['dishIds'] as List),
      isDeletable: json['isDeletable'] as bool? ?? true,
    );
  }

  DishGroup copyWith({
    String? id,
    String? name,
    List<String>? dishIds,
    bool? isDeletable,
  }) {
    return DishGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      dishIds: dishIds ?? this.dishIds,
      isDeletable: isDeletable ?? this.isDeletable,
    );
  }
}