import 'package:equatable/equatable.dart';

class GiftItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category;
  final double priceEtb;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GiftItem({
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

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        category,
        priceEtb,
        isActive,
        createdAt,
        updatedAt,
      ];
}
