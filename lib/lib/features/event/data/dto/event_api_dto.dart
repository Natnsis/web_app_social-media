import 'package:faithconnect/core/utils/media_url_resolver.dart';

class EventApiDto {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String? imageUrl;
  final String? churchId;
  final String? churchName;
  final String? location;
  final bool isActive;
  final DateTime? createdAt;

  const EventApiDto({
    required this.id,
    required this.title,
    this.description = '',
    this.date = '',
    this.time = '',
    this.imageUrl,
    this.churchId,
    this.churchName,
    this.location,
    this.isActive = true,
    this.createdAt,
  });

  factory EventApiDto.fromJson(Map<String, dynamic> json) {
    final church = json['church'];
    final churchMap =
        church is Map ? Map<String, dynamic>.from(church) : null;

    return EventApiDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      imageUrl: MediaUrlResolver.normalize(
        json['imageUrl'] as String? ??
            json['coverImageUrl'] as String? ??
            json['image'] as String?,
        imageOnly: true,
      ),
      churchId: churchMap?['id']?.toString() ?? json['churchId']?.toString(),
      churchName: churchMap?['name'] as String? ??
          json['churchName'] as String?,
      location: json['location'] as String? ??
          churchMap?['city'] as String? ??
          churchMap?['address'] as String?,
      isActive: json['isActive'] != false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
