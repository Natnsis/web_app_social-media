import 'package:equatable/equatable.dart';

class DailyVerse extends Equatable {
  final String quote;
  final String reference;
  final String subtitle;

  const DailyVerse({
    required this.quote,
    required this.reference,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [quote, reference, subtitle];
}
