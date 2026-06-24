import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:faithconnect/core/core.dart';

class CustomPillTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomPillTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.medium,
      ),
      child: Stack(
        children: [
          // Sliding Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment(
              labels.length > 1 
                  ? (selectedIndex / (labels.length - 1)) * 2 - 1
                  : 0,
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: (1 / labels.length),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(1.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: AppRadius.medium,
                ),
              ),
            ),
          ),
          // Labels
          Row(
            children: List.generate(
              labels.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(index),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: selectedIndex == index
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
