import 'package:faithconnect/features/home/gift/domain/entities/gift_catalog.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_hub_content.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';
import 'package:faithconnect/features/home/gift/domain/entities/live_gift_receipt.dart';

abstract final class GiftMockData {
  GiftMockData._();

  static final _items = [
    GiftItem(id: 'amen', name: 'Amen', iconUrl: 'https://placehold.co/100x100/png', priceEtb: 25, description: '', category: 'normal', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    GiftItem(id: 'bible', name: 'Bible', iconUrl: 'https://placehold.co/100x100/png', priceEtb: 50, description: '', category: 'normal', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    GiftItem(id: 'candle', name: 'Candle', iconUrl: 'https://placehold.co/100x100/png', priceEtb: 75, description: '', category: 'normal', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    GiftItem(id: 'cross', name: 'Cross', iconUrl: 'https://placehold.co/100x100/png', priceEtb: 100, description: '', category: 'normal', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    GiftItem(id: 'dove', name: 'Dove', iconUrl: 'https://placehold.co/100x100/png', priceEtb: 150, description: '', category: 'normal', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    GiftItem(id: 'church', name: 'Church', iconUrl: 'https://placehold.co/100x100/png', priceEtb: 500, description: '', category: 'normal', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
  ];

  static double _balanceEtb = 1250.0;

  static GiftHubContent hubContent() {
    return GiftHubContent(title: 'Gift', catalog: catalog());
  }

  static GiftCatalog catalog() {
    return GiftCatalog(items: _items, balanceEtb: _balanceEtb);
  }

  static LiveGiftReceipt sendLiveGift({
    required String streamId,
    required String giftItemId,
  }) {
    final gift = _items.firstWhere(
      (item) => item.id == giftItemId,
      orElse: () => throw StateError('Unknown gift'),
    );

    if (_balanceEtb < gift.priceEtb) {
      throw InsufficientGiftCoinsException();
    }

    _balanceEtb -= gift.priceEtb;

    return LiveGiftReceipt(
      streamId: streamId,
      gift: gift,
      updatedCatalog: catalog(),
    );
  }
}

class InsufficientGiftCoinsException implements Exception {}
