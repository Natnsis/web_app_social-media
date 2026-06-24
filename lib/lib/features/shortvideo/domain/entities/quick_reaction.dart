import 'package:equatable/equatable.dart';

class QuickReaction extends Equatable {
  final String emoji;
  final String label;

  const QuickReaction({required this.emoji, required this.label});

  @override
  List<Object?> get props => [emoji, label];
}
