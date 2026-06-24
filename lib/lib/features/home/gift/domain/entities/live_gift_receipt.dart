import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_catalog.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';

class LiveGiftReceipt extends Equatable {
  final String streamId;
  final GiftItem gift;
  final GiftCatalog updatedCatalog;

  const LiveGiftReceipt({
    required this.streamId,
    required this.gift,
    required this.updatedCatalog,
  });

  @override
  List<Object?> get props => [streamId, gift, updatedCatalog];
}
