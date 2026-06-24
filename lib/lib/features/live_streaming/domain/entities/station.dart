import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Station({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, description, type, createdAt, updatedAt];
}
