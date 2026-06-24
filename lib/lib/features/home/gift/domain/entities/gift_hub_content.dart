import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_catalog.dart';

/// Hub payload for the community Gift flow screen.
class GiftHubContent extends Equatable {
  final String title;
  final GiftCatalog catalog;

  const GiftHubContent({
    required this.title,
    required this.catalog,
  });

  @override
  List<Object?> get props => [title, catalog];
}
