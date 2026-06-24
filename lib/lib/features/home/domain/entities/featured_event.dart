import 'package:equatable/equatable.dart';

class FeaturedEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final String dateTime;
  final String location;
  final String? imageUrl;

  const FeaturedEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.imageUrl,
  });

  @override
  List<Object?> get props =>
      [id, title, description, dateTime, location, imageUrl];
}
