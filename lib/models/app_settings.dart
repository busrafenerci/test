class AppSettings {
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 4;

  final int averageCycleLength;
  final int predictedPeriodLength;

  const AppSettings({
    this.averageCycleLength = defaultCycleLength,
    this.predictedPeriodLength = defaultPeriodLength,
  });

  AppSettings copyWith({
    int? averageCycleLength,
    int? predictedPeriodLength,
  }) {
    return AppSettings(
      averageCycleLength:
          averageCycleLength ?? this.averageCycleLength,
      predictedPeriodLength:
          predictedPeriodLength ?? this.predictedPeriodLength,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageCycleLength': averageCycleLength,
      'predictedPeriodLength': predictedPeriodLength,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      averageCycleLength: _readInt(
        json['averageCycleLength'],
        defaultValue: defaultCycleLength,
      ),
      predictedPeriodLength: _readInt(
        json['predictedPeriodLength'],
        defaultValue: defaultPeriodLength,
      ),
    );
  }

  static int _readInt(
    dynamic value, {
    required int defaultValue,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }
}