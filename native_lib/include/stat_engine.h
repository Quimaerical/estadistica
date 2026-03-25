#ifndef STAT_ENGINE_H
#define STAT_ENGINE_H

#include <stdint.h>
#include <stdbool.h>

#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

// ============================================================================
// ARQUITECTURA DEL MOTOR ESTADÍSTICO (C++ Nativo)
// Se garantiza la máxima precisión empleando 'double' de 64-bits del estándar 
// IEEE 754. Intercalable 1:1 con 'Double' de Dart-FFI sin truncamientos.
// ============================================================================

#ifdef __cplusplus
extern "C" {
#endif

    // ------------------------------------------------------------------------
    // MÓDULO 1: Valores Críticos (Inverse CDF)
    // ------------------------------------------------------------------------
    FFI_EXPORT double stat_critical_z(double alpha, bool two_tailed);
    FFI_EXPORT double stat_critical_t(double alpha, int32_t df, bool two_tailed);
    FFI_EXPORT double stat_critical_chi2(double alpha, int32_t df, bool upper_tail);
    FFI_EXPORT double stat_critical_f(double alpha, int32_t df1, int32_t df2, bool upper_tail);

    // ------------------------------------------------------------------------
    // MÓDULO 2: Valores p (CDF e integrales bajo la curva)
    // ------------------------------------------------------------------------
    // tail_type: -1 (izquierdo), 1 (derecho), 2 (dos colas)
    FFI_EXPORT double stat_pvalue_z(double z_stat, int32_t tail_type); 
    FFI_EXPORT double stat_pvalue_t(double t_stat, int32_t df, int32_t tail_type);
    FFI_EXPORT double stat_pvalue_chi2(double chi2_stat, int32_t df, int32_t tail_type);
    FFI_EXPORT double stat_pvalue_f(double f_stat, int32_t df1, int32_t df2, int32_t tail_type);

    // ------------------------------------------------------------------------
    // MÓDULO 3: Estadísticos de Prueba (Empíricos)
    // ------------------------------------------------------------------------
    FFI_EXPORT double stat_test_z(double mean1, double mean2, double var1, double var2, int32_t n1, int32_t n2, double delta);
    FFI_EXPORT double stat_test_t(double mean1, double mean2, double var1, double var2, int32_t n1, int32_t n2, double delta, bool pooled_variance);

    // ------------------------------------------------------------------------
    // MÓDULO 4: Tamaño de Muestra
    // ------------------------------------------------------------------------
    FFI_EXPORT int32_t stat_sample_size_mean(double alpha, double power, double delta, double variance, bool two_tailed);

    // ------------------------------------------------------------------------
    // MÓDULO 5: Intervalos de Confianza 
    // Debido a FFI, retornamos mediante punteros a memoria provista por Dart
    // ------------------------------------------------------------------------
    FFI_EXPORT void stat_ci_mean_z(double mean, double variance, int32_t n, double confidence_level, double* out_lower, double* out_upper);
    FFI_EXPORT void stat_ci_mean_t(double mean, double variance, int32_t n, double confidence_level, double* out_lower, double* out_upper);

#ifdef __cplusplus
}
#endif

#endif // STAT_ENGINE_H
