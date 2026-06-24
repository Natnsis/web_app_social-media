import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';

class GiftItemDto {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category;
  final num priceEtb;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const GiftItemDto({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.priceEtb,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GiftItemDto.fromJson(Map<String, dynamic> json) {
    return GiftItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      priceEtb: json['priceEtb'] as num? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  GiftItem toEntity() {
    return GiftItem(
      id: id,
      name: name,
      description: description,
      iconUrl: iconUrl,
      category: category,
      priceEtb: priceEtb.toDouble(),
      isActive: isActive,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}
