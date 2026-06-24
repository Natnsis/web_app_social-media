import 'package:equatable/equatable.dart';

class DiscoverySuggestedChurch extends Equatable {
  final String id;
  final String name;
  final String location;
  final String imageUrl;

  const DiscoverySuggestedChurch({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, location, imageUrl];
}
