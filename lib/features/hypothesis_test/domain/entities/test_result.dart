enum TailType { left, right, twoSided }
enum StatisticType { z, t, chiSquare, f }

/// Modelo inmutable que representa de forma estricta los 8 Pasos
/// de la Metodología de Pruebas de Hipótesis.
class HypothesisTestResult {
  final String step1Parameter;
  final String step2H0;
  final String step3H1;
  final double step4Alpha;
  final StatisticType step5StatisticType;
  final String step6DecisionRule;
  final double step7StatisticValue;
  final double step7CriticalValue;
  final double? step7PValue; 
  final bool step8RejectH0;
  final String step8Conclusion;

  HypothesisTestResult({
    required this.step1Parameter,
    required this.step2H0,
    required this.step3H1,
    required this.step4Alpha,
    required this.step5StatisticType,
    required this.step6DecisionRule,
    required this.step7StatisticValue,
    required this.step7CriticalValue,
    this.step7PValue,
    required this.step8RejectH0,
    required this.step8Conclusion,
  });
}
