enum InsightType {
  info,
  success,
  warning,
  trend,
  prediction,
}

class Insight {
  final InsightType type;

  final String title;

  final String message;

  final int priority;

  const Insight({
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
  });
}