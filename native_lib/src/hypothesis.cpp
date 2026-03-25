#include "../include/stat_engine.h"
#include <cmath>
#include <stdexcept>

// C++ Statistical Software Library (kthohr/stats)
#include "stats.hpp"

extern "C" {

    // ============================================================================
    // MÓDULO 1: Valores Críticos (Inverse CDF / Quantiles)
    // ============================================================================
    FFI_EXPORT double stat_critical_z(double alpha, bool two_tailed) {
        if (alpha <= 0.0 || alpha >= 1.0) return NAN;
        double p = two_tailed ? (1.0 - (alpha / 2.0)) : (1.0 - alpha);
        return stats::qnorm(p, 0.0, 1.0);
    }
    
    FFI_EXPORT double stat_critical_t(double alpha, int32_t df, bool two_tailed) {
        if (alpha <= 0.0 || alpha >= 1.0 || df <= 0) return NAN;
        double p = two_tailed ? (1.0 - (alpha / 2.0)) : (1.0 - alpha);
        return stats::qt(p, static_cast<double>(df));
    }
    
    FFI_EXPORT double stat_critical_chi2(double alpha, int32_t df, bool upper_tail) {
        if (alpha <= 0.0 || alpha >= 1.0 || df <= 0) return NAN;
        double p = upper_tail ? (1.0 - alpha) : alpha;
        return stats::qchisq(p, static_cast<double>(df));
    }
    
    FFI_EXPORT double stat_critical_f(double alpha, int32_t df1, int32_t df2, bool upper_tail) {
        if (alpha <= 0.0 || alpha >= 1.0 || df1 <= 0 || df2 <= 0) return NAN;
        double p = upper_tail ? (1.0 - alpha) : alpha;
        return stats::qf(p, static_cast<double>(df1), static_cast<double>(df2));
    }

    // ============================================================================
    // MÓDULO 2: Valores p (CDF / Probabilidades bajo la curva)
    // tail_type: -1 (izquierdo), 1 (derecho), 2 (dos colas)
    // ============================================================================
    FFI_EXPORT double stat_pvalue_z(double z_stat, int32_t tail_type) {
        double cdf = stats::pnorm(std::abs(z_stat), 0.0, 1.0);
        if (tail_type == -1) return (z_stat <= 0) ? cdf : (1.0 - cdf);
        if (tail_type == 1) return (z_stat > 0) ? (1.0 - cdf) : cdf;
        if (tail_type == 2) return 2.0 * (1.0 - cdf);
        return NAN;
    }

    FFI_EXPORT double stat_pvalue_t(double t_stat, int32_t df, int32_t tail_type) {
        if (df <= 0) return NAN;
        double cdf = stats::pt(std::abs(t_stat), static_cast<double>(df));
        if (tail_type == -1) return (t_stat <= 0) ? cdf : (1.0 - cdf);
        if (tail_type == 1) return (t_stat > 0) ? (1.0 - cdf) : cdf;
        if (tail_type == 2) return 2.0 * (1.0 - cdf);
        return NAN;
    }

    FFI_EXPORT double stat_pvalue_chi2(double chi2_stat, int32_t df, int32_t tail_type) {
        if (df <= 0 || chi2_stat < 0) return NAN;
        double cdf = stats::pchisq(chi2_stat, static_cast<double>(df));
        if (tail_type == -1) return cdf;
        if (tail_type == 1) return 1.0 - cdf;
        if (tail_type == 2) return 2.0 * (1.0 - cdf); // En chi2 usualmente es 1 cola superior, pero se expone por completez
        return NAN;
    }

    FFI_EXPORT double stat_pvalue_f(double f_stat, int32_t df1, int32_t df2, int32_t tail_type) {
        if (df1 <= 0 || df2 <= 0 || f_stat < 0) return NAN;
        double cdf = stats::pf(f_stat, static_cast<double>(df1), static_cast<double>(df2));
        if (tail_type == -1) return cdf;
        if (tail_type == 1) return 1.0 - cdf;
        if (tail_type == 2) return 2.0 * (1.0 - cdf);
        return NAN;
    }

    // ============================================================================
    // MÓDULO 3: Estadísticos de Prueba
    // ============================================================================
    FFI_EXPORT double stat_test_z(double mean1, double mean2, double var1, double var2, int32_t n1, int32_t n2, double delta) {
        double se = std::sqrt((var1 / n1) + (var2 / n2));
        if (se == 0.0) return NAN;
        return ((mean1 - mean2) - delta) / se;
    }

    FFI_EXPORT double stat_test_t(double mean1, double mean2, double var1, double var2, int32_t n1, int32_t n2, double delta, bool pooled_variance) {
        if (pooled_variance) {
            double sp2 = ((n1 - 1) * var1 + (n2 - 1) * var2) / (n1 + n2 - 2);
            double se = std::sqrt(sp2 * (1.0 / n1 + 1.0 / n2));
            if (se == 0.0) return NAN;
            return ((mean1 - mean2) - delta) / se;
        } else {
            double se = std::sqrt((var1 / n1) + (var2 / n2));
            if (se == 0.0) return NAN;
            return ((mean1 - mean2) - delta) / se;
        }
    }

    // ============================================================================
    // MÓDULO 4: Tamaño de Muestra
    // ============================================================================
    FFI_EXPORT int32_t stat_sample_size_mean(double alpha, double power, double delta, double variance, bool two_tailed) {
        if (alpha <= 0.0 || alpha >= 1.0 || power <= 0.0 || power >= 1.0 || delta == 0.0 || variance <= 0.0) return -1;
        double z_alpha = stat_critical_z(alpha, two_tailed);
        double z_beta = stat_critical_z(1.0 - power, false); // qnorm(1 - power)
        // stats::qnorm(power) is the critical value for tail. Usually power = 1 - beta
        
        double numerator = std::pow(z_alpha + z_beta, 2) * variance;
        double denominator = std::pow(delta, 2);
        
        double n_exact = numerator / denominator;
        return static_cast<int32_t>(std::ceil(n_exact));
    }

    // ============================================================================
    // MÓDULO 5: Intervalos de Confianza
    // ============================================================================
    FFI_EXPORT void stat_ci_mean_z(double mean, double variance, int32_t n, double confidence_level, double* out_lower, double* out_upper) {
        if (!out_lower || !out_upper || n <= 0) return;
        double alpha = 1.0 - confidence_level;
        double z_crit = stat_critical_z(alpha, true);
        double margin = z_crit * std::sqrt(variance / n);
        *out_lower = mean - margin;
        *out_upper = mean + margin;
    }

    FFI_EXPORT void stat_ci_mean_t(double mean, double variance, int32_t n, double confidence_level, double* out_lower, double* out_upper) {
        if (!out_lower || !out_upper || n <= 1) return;
        double alpha = 1.0 - confidence_level;
        double t_crit = stat_critical_t(alpha, n - 1, true);
        double margin = t_crit * std::sqrt(variance / n);
        *out_lower = mean - margin;
        *out_upper = mean + margin;
    }

}
