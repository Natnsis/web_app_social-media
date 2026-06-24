import 'package:equatable/equatable.dart';

class ChurchEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String dateTimeLabel;
  final String? churchId;
  final String? churchName;
  final String location;
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;

  const ChurchEvent({
    required this.id,
    required this.title,
    this.description = '',
    this.date = '',
    this.time = '',
    this.dateTimeLabel = '',
    this.churchId,
    this.churchName,
    this.location = '',
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
  });

  ChurchEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? dateTimeLabel,
    String? churchId,
    String? churchName,
    String? location,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ChurchEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      dateTimeLabel: dateTimeLabel ?? this.dateTimeLabel,
      churchId: churchId ?? this.churchId,
      churchName: churchName ?? this.churchName,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        time,
        dateTimeLabel,
        churchId,
        churchName,
        location,
        imageUrl,
        isActive,
        createdAt,
      ];
}
