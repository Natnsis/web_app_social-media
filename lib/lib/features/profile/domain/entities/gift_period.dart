enum GiftPeriod {
  week,
  month,
  year,
  all;

  String get label {
    switch (this) {
      case GiftPeriod.week:
        return 'Week';
      case GiftPeriod.month:
        return 'Month';
      case GiftPeriod.year:
        return 'Year';
      case GiftPeriod.all:
        return 'All';
    }
  }

  String get totalLabel {
    switch (this) {
      case GiftPeriod.week:
        return 'TOTAL THIS WEEK';
      case GiftPeriod.month:
        return 'TOTAL THIS MONTH';
      case GiftPeriod.year:
        return 'TOTAL THIS YEAR';
      case GiftPeriod.all:
        return 'TOTAL ALL TIME';
    }
  }
}
