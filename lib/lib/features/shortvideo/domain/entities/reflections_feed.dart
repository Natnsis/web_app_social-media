import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/quick_reaction.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';

class ReflectionsFeed extends Equatable {
  final int totalReflecting;
  final List<Reflection> reflections;
  final List<QuickReaction> quickReactions;

  const ReflectionsFeed({
    required this.totalReflecting,
    required this.reflections,
    required this.quickReactions,
  });

  ReflectionsFeed copyWith({
    int? totalReflecting,
    List<Reflection>? reflections,
    List<QuickReaction>? quickReactions,
  }) {
    return ReflectionsFeed(
      totalReflecting: totalReflecting ?? this.totalReflecting,
      reflections: reflections ?? this.reflections,
      quickReactions: quickReactions ?? this.quickReactions,
    );
  }

  @override
  List<Object?> get props => [totalReflecting, reflections, quickReactions];
}
