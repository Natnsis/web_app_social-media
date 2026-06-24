enum LiveViewersRange {
  oneHour,
  sixHours,
  twelveHours,
  twentyFourHours;

  String get label {
    switch (this) {
      case LiveViewersRange.oneHour:
        return '1H';
      case LiveViewersRange.sixHours:
        return '6H';
      case LiveViewersRange.twelveHours:
        return '12H';
      case LiveViewersRange.twentyFourHours:
        return '24H';
    }
  }
}
