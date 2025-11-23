class CategoryModel {
  final String name;
  final int count;

  CategoryModel({
    required this.name,
    required this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
    };
  }

  @override
  String toString() {
    return 'CategoryModel(name: $name, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.name == name &&
        other.count == count;
  }

  @override
  int get hashCode => name.hashCode ^ count.hashCode;
}