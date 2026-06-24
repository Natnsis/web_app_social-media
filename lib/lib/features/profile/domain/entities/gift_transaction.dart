import 'package:equatable/equatable.dart';

class GiftTransaction extends Equatable {
  final String id;
  final String donorName;
  final String donorInitials;
  final String fundName;
  final DateTime createdAt;
  final double amount;

  const GiftTransaction({
    required this.id,
    required this.donorName,
    required this.donorInitials,
    required this.fundName,
    required this.createdAt,
    required this.amount,
  });

  @override
  List<Object?> get props => [
        id,
        donorName,
        donorInitials,
        fundName,
        createdAt,
        amount,
      ];
}
