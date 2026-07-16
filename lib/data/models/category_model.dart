import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;
  final String? emoji;
  final int order;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    this.emoji,
    this.order = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      iconUrl: map['iconUrl'],
      emoji: map['emoji'],
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'iconUrl': iconUrl,
        'emoji': emoji,
        'order': order,
      };

  @override
  List<Object?> get props => [id, name, iconUrl, emoji, order];
}
