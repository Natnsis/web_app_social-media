import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';

class GiftCatalog extends Equatable {
  final List<GiftItem> items;
  final double balanceEtb;

  const GiftCatalog({
    required this.items,
    required this.balanceEtb,
  });

  GiftCatalog copyWith({
    List<GiftItem>? items,
    double? balanceEtb,
  }) {
    return GiftCatalog(
      items: items ?? this.items,
      balanceEtb: balanceEtb ?? this.balanceEtb,
    );
  }

  @override
  List<Object?> get props => [items, balanceEtb];
}
