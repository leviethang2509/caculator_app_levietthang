class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    return CalculationHistory(
      expression: map['expression'] ?? '',
      result: map['result'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() => '$expression = $result';
}