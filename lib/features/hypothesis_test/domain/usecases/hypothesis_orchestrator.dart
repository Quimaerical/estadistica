import 'dart:math';
import '../../../../core/ffi/stat_bindings.dart';
import '../../../../core/utils/number_formatter.dart';
import '../entities/test_result.dart';

class HypothesisOrchestrator {
  final StatEngine _engine = StatEngine();

  /// Prueba de Hipótesis para la Media (1 Muestra)
  HypothesisTestResult evaluateOneSampleMean({
    required double sampleMean,
    required double popMeanH0,
    required int n,
    required double sampleStdDev,
    required bool isPopStdDevKnown,
    required double alpha,
    required TailType tail,
  }) {
    const step1 = "Media Poblacional (μ)";
    final step2 = "H0: μ = ${NumberFormatter.format(popMeanH0)}";
    String step3;
    switch (tail) {
      case TailType.left: step3 = "H1: μ < ${NumberFormatter.format(popMeanH0)}"; break;
      case TailType.right: step3 = "H1: μ > ${NumberFormatter.format(popMeanH0)}"; break;
      case TailType.twoSided: step3 = "H1: μ ≠ ${NumberFormatter.format(popMeanH0)}"; break;
    }

    final statType = (isPopStdDevKnown || n >= 30) ? StatisticType.z : StatisticType.t;
    final standardError = sampleStdDev / sqrt(n);
    final statValue = (sampleMean - popMeanH0) / standardError;

    double criticalValue = 0.0;
    double pValue = 0.0;
    bool rejectH0 = false;
    String step6Rule = "";

    if (statType == StatisticType.z) {
      criticalValue = _engine.calculateZCritical(alpha, tail == TailType.twoSided);
      double cdf = _engine.calculateZCdf(statValue);
      if (tail == TailType.left) pValue = cdf;
      else if (tail == TailType.right) pValue = 1.0 - cdf;
      else pValue = 2.0 * min(cdf, 1.0 - cdf);

      switch (tail) {
        case TailType.left:
          criticalValue = -criticalValue;
          step6Rule = "Rechazar H0 si Z < ${NumberFormatter.format(criticalValue)}";
          rejectH0 = statValue <= criticalValue;
          break;
        case TailType.right:
          step6Rule = "Rechazar H0 si Z > ${NumberFormatter.format(criticalValue)}";
          rejectH0 = statValue >= criticalValue;
          break;
        case TailType.twoSided:
          step6Rule = "Rechazar H0 si |Z| > ${NumberFormatter.format(criticalValue)}";
          rejectH0 = statValue.abs() >= criticalValue;
          break;
      }
    } else {
      step6Rule = "[Motor C++] Pendiente implementar T-Student CDF/Inverse";
    }

    final String conclusionText = rejectH0
        ? "Existe evidencia estadística para rechazar H0. Efecto significativo (p = ${NumberFormatter.format(pValue)} < α)."
        : "NO hay evidencia para rechazar H0. Efecto no significativo (p = ${NumberFormatter.format(pValue)} > α).";

    return HypothesisTestResult(
      step1Parameter: step1, step2H0: step2, step3H1: step3, step4Alpha: alpha,
      step5StatisticType: statType, step6DecisionRule: step6Rule, step7StatisticValue: statValue,
      step7CriticalValue: criticalValue, step7PValue: pValue, step8RejectH0: rejectH0, step8Conclusion: conclusionText,
    );
  }

  HypothesisTestResult evaluateTwoSampleMeans({
    required double mean1, required double mean2,
    required double sd1, required double sd2,
    required int n1, required int n2,
    required double deltaH0,
    required bool isPopStdDevKnown,
    required bool assumeEqualVariances,
    required double alpha,
    required TailType tail,
  }) {
    const step1 = "Diferencia de Medias (μ1 - μ2)";
    final step2 = "H0: μ1 - μ2 = ${NumberFormatter.format(deltaH0)}";
    String step3;
    switch (tail) {
      case TailType.left: step3 = "H1: μ1 - μ2 < ${NumberFormatter.format(deltaH0)}"; break;
      case TailType.right: step3 = "H1: μ1 - μ2 > ${NumberFormatter.format(deltaH0)}"; break;
      case TailType.twoSided: step3 = "H1: μ1 - μ2 ≠ ${NumberFormatter.format(deltaH0)}"; break;
    }

    final statType = (isPopStdDevKnown || (n1 >= 30 && n2 >= 30)) ? StatisticType.z : StatisticType.t;
    double criticalValue = 0.0;
    double pValue = 0.0;
    bool rejectH0 = false;
    String step6Rule = "";
    double se = 0.0;

    if (statType == StatisticType.z) {
      se = sqrt((sd1*sd1)/n1 + (sd2*sd2)/n2);
      double statValue = (mean1 - mean2 - deltaH0) / se;
      criticalValue = _engine.calculateZCritical(alpha, tail == TailType.twoSided);
      double cdf = _engine.calculateZCdf(statValue);
      if (tail == TailType.left) pValue = cdf;
      else if (tail == TailType.right) pValue = 1.0 - cdf;
      else pValue = 2.0 * min(cdf, 1.0 - cdf);

      switch (tail) {
        case TailType.left:
          criticalValue = -criticalValue;
          step6Rule = "Rechazar H0 si Z_calc < ${NumberFormatter.format(criticalValue)}";
          rejectH0 = statValue <= criticalValue;
          break;
        case TailType.right:
          step6Rule = "Rechazar H0 si Z_calc > ${NumberFormatter.format(criticalValue)}";
          rejectH0 = statValue >= criticalValue;
          break;
        case TailType.twoSided:
          step6Rule = "Rechazar H0 si |Z_calc| > ${NumberFormatter.format(criticalValue)}";
          rejectH0 = statValue.abs() >= criticalValue;
          break;
      }
      
      final String conclusionText = rejectH0
        ? "Diferencia entre grupos es SIGNIFICATIVA (p = ${NumberFormatter.format(pValue)}). Se demuestra H1 fuertemente."
        : "TEST A/B NO CONCLUYENTE: La diferencia es estadísticamente imperceptible (p = ${NumberFormatter.format(pValue)}).";

      return HypothesisTestResult(
        step1Parameter: step1, step2H0: step2, step3H1: step3, step4Alpha: alpha,
        step5StatisticType: statType, step6DecisionRule: step6Rule, step7StatisticValue: statValue,
        step7CriticalValue: criticalValue, step7PValue: pValue, step8RejectH0: rejectH0, step8Conclusion: conclusionText,
      );
    } else {
      se = sqrt((sd1*sd1)/n1 + (sd2*sd2)/n2);
      double statValue = (mean1 - mean2 - deltaH0) / se;
      return HypothesisTestResult(
        step1Parameter: step1, step2H0: step2, step3H1: step3, step4Alpha: alpha,
        step5StatisticType: statType, step6DecisionRule: "[Motor C++] Pendiente Inversa T-Student", step7StatisticValue: statValue,
        step7CriticalValue: 0, step7PValue: null, step8RejectH0: false, step8Conclusion: "Requiere motor FFI de T-Student Multivariable",
      );
    }
  }

  /// Prueba de Hipótesis para la Varianza (1 Muestra)
  HypothesisTestResult evaluateOneSampleVariance({
    required double sampleVariance,
    required double popVarianceH0,
    required int n,
    required double alpha,
    required TailType tail,
  }) {
    const step1 = "Varianza Poblacional (σ²)";
    final step2 = "H0: σ² = ${NumberFormatter.format(popVarianceH0)}";
    String step3;
    switch (tail) {
      case TailType.left: step3 = "H1: σ² < ${NumberFormatter.format(popVarianceH0)}"; break;
      case TailType.right: step3 = "H1: σ² > ${NumberFormatter.format(popVarianceH0)}"; break;
      case TailType.twoSided: step3 = "H1: σ² ≠ ${NumberFormatter.format(popVarianceH0)}"; break;
    }

    final statType = StatisticType.chiSquare;
    final degreesOfFreedom = n - 1;
    final statValue = (degreesOfFreedom * sampleVariance) / popVarianceH0;

    return HypothesisTestResult(
      step1Parameter: step1,
      step2H0: step2,
      step3H1: step3,
      step4Alpha: alpha,
      step5StatisticType: statType,
      step6DecisionRule: "[Motor C++] Necesita Chi-Square Inversa con df=$degreesOfFreedom",
      step7StatisticValue: statValue,
      step7CriticalValue: 0.0,
      step8RejectH0: false,
      step8Conclusion: "Implementación FFI de Chi-Cuadrado requerida.",
    );
  }
}
