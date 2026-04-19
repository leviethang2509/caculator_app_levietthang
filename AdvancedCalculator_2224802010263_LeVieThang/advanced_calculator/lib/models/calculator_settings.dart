class CalculatorSettings {
  final int decimalPrecision;
  final bool isDegreeMode;
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize;
  final double fontScale;

  const CalculatorSettings({
    required this.decimalPrecision,
    required this.isDegreeMode,
    required this.hapticFeedback,
    required this.soundEffects,
    required this.historySize,
    required this.fontScale,
  });

  factory CalculatorSettings.defaultSettings() {
    return const CalculatorSettings(
      decimalPrecision: 4,
      isDegreeMode: true,
      hapticFeedback: true,
      soundEffects: false,
      historySize: 50,
      fontScale: 1.0,
    );
  }

  CalculatorSettings copyWith({
    int? decimalPrecision,
    bool? isDegreeMode,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
    double? fontScale,
  }) {
    return CalculatorSettings(
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      isDegreeMode: isDegreeMode ?? this.isDegreeMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'decimalPrecision': decimalPrecision,
      'isDegreeMode': isDegreeMode,
      'hapticFeedback': hapticFeedback,
      'soundEffects': soundEffects,
      'historySize': historySize,
      'fontScale': fontScale,
    };
  }

  factory CalculatorSettings.fromMap(Map<String, dynamic> map) {
    return CalculatorSettings(
      decimalPrecision: map['decimalPrecision'] ?? 4,
      isDegreeMode: map['isDegreeMode'] ?? true,
      hapticFeedback: map['hapticFeedback'] ?? true,
      soundEffects: map['soundEffects'] ?? false,
      historySize: map['historySize'] ?? 50,
      fontScale: (map['fontScale'] ?? 1.0).toDouble(),
    );
  }
}