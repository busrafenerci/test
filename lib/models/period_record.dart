class PeriodRecord {
  final DateTime startDate;

  /// Null means the period is still ongoing.
  final DateTime? endDate;

  /// Temporary period length used until the user marks the period as finished.
  final int predictedLength;

  const PeriodRecord({
  required this.startDate,
  this.endDate,
  int? periodLength,
  int? predictedLength,
}) : predictedLength = predictedLength ?? periodLength ?? 4;

  /// Returns true when the user has not marked the period as finished yet.
  bool get isOngoing => endDate == null;

  /// Returns the actual end date for completed records,
  /// or the predicted end date for ongoing records.
  DateTime get effectiveEndDate {
    if (endDate != null) {
      return _dateOnly(endDate!);
    }

    return _dateOnly(
      startDate.add(Duration(days: predictedLength - 1)),
    );
  }

  /// Kept for compatibility with the existing calendar and calculator code.
  ///
  /// Completed record:
  /// Returns the actual period length.
  ///
  /// Ongoing record:
  /// Returns the predicted period length.
  int get periodLength {
    if (endDate == null) {
      return predictedLength;
    }

    return _dateOnly(endDate!)
            .difference(_dateOnly(startDate))
            .inDays +
        1;
  }

  /// Returns the actual period length only when the record is completed.
  int? get actualPeriodLength {
    if (endDate == null) {
      return null;
    }

    return _dateOnly(endDate!)
            .difference(_dateOnly(startDate))
            .inDays +
        1;
  }

  bool containsDate(DateTime date) {
    final normalizedDate = _dateOnly(date);
    final normalizedStart = _dateOnly(startDate);

    return !normalizedDate.isBefore(normalizedStart) &&
        !normalizedDate.isAfter(effectiveEndDate);
  }

  /// Completes an ongoing period on the selected date.
  PeriodRecord finish(DateTime selectedEndDate) {
    final normalizedStart = _dateOnly(startDate);
    final normalizedEnd = _dateOnly(selectedEndDate);

    if (normalizedEnd.isBefore(normalizedStart)) {
      throw ArgumentError(
        'Period end date cannot be before the start date.',
      );
    }

    return copyWith(
      endDate: normalizedEnd,
    );
  }

  /// Reopens a completed record.
  PeriodRecord reopen() {
    return PeriodRecord(
      startDate: _dateOnly(startDate),
      endDate: null,
      predictedLength: periodLength,
    );
  }

  PeriodRecord copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? predictedLength,
    bool clearEndDate = false,
  }) {
    return PeriodRecord(
      startDate: _dateOnly(startDate ?? this.startDate),
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      predictedLength: predictedLength ?? this.predictedLength,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': _dateOnly(startDate).toIso8601String(),
      'endDate': endDate == null
          ? null
          : _dateOnly(endDate!).toIso8601String(),
      'predictedLength': predictedLength,
    };
  }

  factory PeriodRecord.fromJson(Map<String, dynamic> json) {
    final startDate = _dateOnly(
      DateTime.parse(json['startDate'] as String),
    );

    /*
     * New record format:
     * {
     *   "startDate": "...",
     *   "endDate": "...",
     *   "predictedLength": 4
     * }
     */
    if (json.containsKey('endDate') ||
        json.containsKey('predictedLength')) {
      final rawEndDate = json['endDate'];

      return PeriodRecord(
        startDate: startDate,
        endDate: rawEndDate == null
            ? null
            : _dateOnly(DateTime.parse(rawEndDate as String)),
        predictedLength:
            (json['predictedLength'] as num?)?.toInt() ?? 4,
      );
    }

    /*
     * Migration from the old record format:
     * {
     *   "startDate": "...",
     *   "periodLength": 5
     * }
     *
     * Old records are considered completed records.
     */
    final oldPeriodLength =
        (json['periodLength'] as num?)?.toInt() ?? 4;

    return PeriodRecord(
      startDate: startDate,
      endDate: startDate.add(
        Duration(days: oldPeriodLength - 1),
      ),
      predictedLength: oldPeriodLength,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }
}