import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet to pick search radius for nearby churches.
class NearbyFilterSheet extends StatelessWidget {
  final NearbyChurchesFilter current;
  final ValueChanged<NearbyChurchesFilter> onApply;

  const NearbyFilterSheet({
    super.key,
    required this.current,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required NearbyChurchesFilter current,
    required ValueChanged<NearbyChurchesFilter> onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: DarkTheme.feedCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => NearbyFilterSheet(
        current: current,
        onApply: (filter) {
          Navigator.of(context).pop();
          onApply(filter);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _NearbyFilterSheetBody(
      initial: current,
      onApply: onApply,
    );
  }
}

class _NearbyFilterSheetBody extends StatefulWidget {
  final NearbyChurchesFilter initial;
  final ValueChanged<NearbyChurchesFilter> onApply;

  const _NearbyFilterSheetBody({
    required this.initial,
    required this.onApply,
  });

  @override
  State<_NearbyFilterSheetBody> createState() => _NearbyFilterSheetBodyState();
}

class _NearbyFilterSheetBodyState extends State<_NearbyFilterSheetBody> {
  late int _radiusKm;

  @override
  void initState() {
    super.initState();
    _radiusKm = widget.initial.clampedRadiusKm;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: DarkTheme.feedMutedText.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Search radius',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Find churches within your selected distance (max ${NearbyChurchesFilter.maxRadiusKm} km).',
              style: GoogleFonts.inter(
                color: DarkTheme.feedMutedText,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: NearbyChurchesFilter.radiusPresets.map((km) {
                final selected = _radiusKm == km;
                return ChoiceChip(
                  label: Text('$km km'),
                  selected: selected,
                  onSelected: (_) => setState(() => _radiusKm = km),
                  selectedColor: DarkTheme.brandBlue.withValues(alpha: 0.35),
                  backgroundColor: DarkTheme.feedTagBackground,
                  labelStyle: GoogleFonts.inter(
                    color: selected ? Colors.white : DarkTheme.feedMutedText,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                  side: BorderSide(
                    color: selected
                        ? DarkTheme.brandBlue
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            Text(
              'Custom: $_radiusKm km',
              style: GoogleFonts.inter(
                color: DarkTheme.feedMutedText,
                fontSize: 13.sp,
              ),
            ),
            Slider(
              value: _radiusKm.toDouble(),
              min: NearbyChurchesFilter.minRadiusKm.toDouble(),
              max: NearbyChurchesFilter.maxRadiusKm.toDouble(),
              divisions: 49,
              activeColor: DarkTheme.brandBlue,
              inactiveColor: DarkTheme.feedTagBackground,
              label: '$_radiusKm km',
              onChanged: (v) => setState(() => _radiusKm = v.round()),
            ),
            SizedBox(height: 8.h),
            PrimaryButton.feedAction(
              text: 'Apply',
              onPressed: () {
                widget.onApply(
                  widget.initial.copyWith(
                    radiusKm: _radiusKm,
                    page: 1,
                  ),
                );
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
