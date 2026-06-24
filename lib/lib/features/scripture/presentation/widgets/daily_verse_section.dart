import 'package:faithconnect/features/home/domain/entities/daily_verse.dart';
import 'package:faithconnect/features/scripture/presentation/widgets/daily_verse_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal scryper row for the home feed.
class DailyVerseSection extends StatelessWidget {
  static const double cardWidth = 300;
  static const double listHeight = 196;
  static const double cardGap = 12;

  final List<DailyVerse> verses;

  const DailyVerseSection({super.key, required this.verses});

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return const SizedBox.shrink();

    if (verses.length == 1) {
      return DailyVerseCard(verse: verses.first);
    }

    return SizedBox(
      height: listHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: verses.length,
        separatorBuilder: (_, _) => SizedBox(width: cardGap.w),
        itemBuilder: (context, index) => DailyVerseCard(
          verse: verses[index],
          width: cardWidth.w,
        ),
      ),
    );
  }
}
