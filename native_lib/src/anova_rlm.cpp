#include "../include/stat_engine.h"
#include <cmath>
#include <vector>
#include <algorithm>
#include <numeric>
#include <stdexcept>

// Opcional para p-values en caso de ANOVA
#include "stats.hpp"

extern "C" {

    // ============================================================================
    // MÓDULO: ANOVA - PRUEBA 1 (DUNCAN, LILLIEFORS, RACHAS, COCHRAN)
    // ============================================================================

    // Devuelve los resultados del Anova en un array de 4 doubles [F, p_value, MSA, MSE]
    FFI_EXPORT void stat_anova_1way(const double* data1, int n1, const double* data2, int n2, const double* data3, int n3, double* out_results) {
        if (!data1 || !data2 || !data3 || !out_results) return;

        double mean1 = 0, mean2 = 0, mean3 = 0;
        for (int i=0; i<n1; ++i) mean1 += data1[i];
        for (int i=0; i<n2; ++i) mean2 += data2[i];
        for (int i=0; i<n3; ++i) mean3 += data3[i];
        
        mean1 /= n1; mean2 /= n2; mean3 /= n3;

        double sum_sq_err1 = 0, sum_sq_err2 = 0, sum_sq_err3 = 0;
        for (int i=0; i<n1; ++i) sum_sq_err1 += (data1[i] - mean1)*(data1[i] - mean1);
        for (int i=0; i<n2; ++i) sum_sq_err2 += (data2[i] - mean2)*(data2[i] - mean2);
        for (int i=0; i<n3; ++i) sum_sq_err3 += (data3[i] - mean3)*(data3[i] - mean3);

        double G = (n1 * mean1) + (n2 * mean2) + (n3 * mean3);
        int N = n1 + n2 + n3;
        double GM = G / N; // Grand Mean

        double SST = 0;
        for(int i=0; i<n1; ++i) SST += (data1[i] - GM)*(data1[i] - GM);
        for(int i=0; i<n2; ++i) SST += (data2[i] - GM)*(data2[i] - GM);
        for(int i=0; i<n3; ++i) SST += (data3[i] - GM)*(data3[i] - GM);

        double SSA = n1*(mean1 - GM)*(mean1 - GM) + n2*(mean2 - GM)*(mean2 - GM) + n3*(mean3 - GM)*(mean3 - GM);
        double SSE = sum_sq_err1 + sum_sq_err2 + sum_sq_err3;

        int dfA = 3 - 1; // 3 tratamientos
        int dfE = N - 3;

        double MSA = SSA / dfA;
        double MSE = SSE / dfE;

        double F = MSA / MSE;
        
        // P-value de la F(2, N-3)
        double p_value = 1.0 - stats::pf(F, static_cast<double>(dfA), static_cast<double>(dfE));

        // Export answers for question 1 as well
        out_results[0] = F;
        out_results[1] = p_value;
        out_results[2] = MSA;
        out_results[3] = MSE;
        out_results[4] = GM; // Estimator for mu
        out_results[5] = mean1;
        out_results[6] = mean2;
        out_results[7] = mean3;
        // SSA and SSE
        out_results[8] = SSA;
        out_results[9] = SSE;
    }

    // Runs Test (Rachas) para independencia en una serie de valores
    FFI_EXPORT double stat_runs_test(const double* sequence, int n) {
        if (!sequence || n <= 0) return NAN;
        
        // Calcular la mediana
        std::vector<double> sorted_data(sequence, sequence + n);
        std::sort(sorted_data.begin(), sorted_data.end());
        double median = (n % 2 == 0) ? (sorted_data[n/2 - 1] + sorted_data[n/2]) / 2.0 : sorted_data[n/2];

        int runs = 1;
        int n1 = 0, n2 = 0;

        // ignorar valores iguales a la mediana en el test de rachas general
        std::vector<int> signs;
        for (int i=0; i<n; ++i) {
            if (sequence[i] > median) {
                signs.push_back(1);
                n1++;
            } else if (sequence[i] < median) {
                signs.push_back(-1);
                n2++;
            }
        }

        for (size_t i = 1; i < signs.size(); ++i) {
            if (signs[i] != signs[i-1]) runs++;
        }

        if (n1 == 0 || n2 == 0) return NAN;

        double expected_runs = ((2.0 * n1 * n2) / (n1 + n2)) + 1.0;
        double var_runs = (2.0 * n1 * n2 * (2.0 * n1 * n2 - n1 - n2)) / (std::pow(n1 + n2, 2) * (n1 + n2 - 1.0));
        
        double Z = (runs - expected_runs) / std::sqrt(var_runs);
        
        // Retornar el P-valor
        return 2.0 * (1.0 - stats::pnorm(std::abs(Z), 0.0, 1.0));
    }

    // Cochran's C test para homogeneidad de varianzas
    FFI_EXPORT double stat_cochran_test(const double* data1, int n1, const double* data2, int n2, const double* data3, int n3) {
        if(n1<=1 || n2<=1 || n3<=1) return NAN;
        auto calc_var = [](const double* d, int n) {
            double m = 0;
            for(int i=0; i<n; ++i) m += d[i];
            m /= n;
            double var = 0;
            for(int i=0; i<n; ++i) var += (d[i] - m)*(d[i] - m);
            return var / (n - 1);
        };
        double v1 = calc_var(data1, n1);
        double v2 = calc_var(data2, n2);
        double v3 = calc_var(data3, n3);
        
        double max_v = std::max({v1, v2, v3});
        double C = max_v / (v1 + v2 + v3);
        return C; // Retorna el estadístico C de Cochran
    }

    // ============================================================================
    // MÓDULO RLM: INVERSA MATRICIAL Y MÍNIMOS CUADRADOS
    // ============================================================================

    // Gauss-Jordan Matrix Inversion (5x5 para RLM)
    bool invert_matrix(double mat[5][5], double inv[5][5], int n) {
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                inv[i][j] = (i == j) ? 1.0 : 0.0;
            }
        }
        // Implementation using partial pivoting to avoid near-zero divisibility division issues
        for (int i = 0; i < n; ++i) {
            int pivot_row = i;
            for (int k = i + 1; k < n; ++k) {
                if (std::abs(mat[k][i]) > std::abs(mat[pivot_row][i])) {
                    pivot_row = k;
                }
            }
            if (i != pivot_row) {
                for (int j = 0; j < n; ++j) {
                    std::swap(mat[i][j], mat[pivot_row][j]);
                    std::swap(inv[i][j], inv[pivot_row][j]);
                }
            }
            double pivot = mat[i][i];
            if (std::abs(pivot) < 1e-12) return false; // Singular matrix
            for (int j = 0; j < n; ++j) {
                mat[i][j] /= pivot;
                inv[i][j] /= pivot;
            }
            for (int k = 0; k < n; ++k) {
                if (k != i) {
                    double factor = mat[k][i];
                    for (int j = 0; j < n; ++j) {
                        mat[k][j] -= factor * mat[i][j];
                        inv[k][j] -= factor * inv[i][j];
                    }
                }
            }
        }
        return true;
    }

    /*
    Calcula OLS con 4 variables predictivas (X1, X2, X3, X4) y 1 dependiente Y.
    x_matrix_flat: array flat 4 x n.
    y_vector: array de logitud n.
    out_beta: array de longitud 5 (b0, b1, b2, b3, b4)
    out_metrics: array [R2, F_model, p_value_model]
    */
    FFI_EXPORT void stat_rlm_fit(const double* x1, const double* x2, const double* x3, const double* x4,
                                 const double* y_vec, int n, double* out_beta, double* out_metrics) {
        
        // Múltiple Regresión Lineal: Y = X * Beta
        // Beta = (X^T * X)^-1 * X^T * Y
        // Dimension de la matriz X es N x 5 (col0 es de unos)
        if (!out_beta || !out_metrics || n <= 4) return;
        
        double XtX[5][5] = {0};
        double XtY[5] = {0};
        
        for (int i = 0; i < n; i++) {
            double X_row[5] = {1.0, x1[i], x2[i], x3[i], x4[i]};
            double y_i = y_vec[i];
            for (int j = 0; j < 5; j++) {
                XtY[j] += X_row[j] * y_i;
                for (int k = 0; k < 5; k++) {
                    XtX[j][k] += X_row[j] * X_row[k];
                }
            }
        }

        double XtX_inv[5][5];
        if (!invert_matrix(XtX, XtX_inv, 5)) {
            // Error, matrix is non-invertible
            return;
        }

        // Multiply Beta = XtX_inv * XtY
        for (int i = 0; i < 5; i++) {
            out_beta[i] = 0.0;
            for (int j = 0; j < 5; j++) {
                out_beta[i] += XtX_inv[i][j] * XtY[j];
            }
        }

        // Calculate R2 and F-statistic
        double y_mean = 0;
        for (int i=0; i<n; i++) y_mean += y_vec[i];
        y_mean /= n;

        double sse = 0; // Sum of squared errors
        double sst = 0; // Total sum of squares
        for (int i=0; i<n; i++) {
            double y_pred = out_beta[0] + out_beta[1]*x1[i] + out_beta[2]*x2[i] + out_beta[3]*x3[i] + out_beta[4]*x4[i];
            sse += (y_vec[i] - y_pred)*(y_vec[i] - y_pred);
            sst += (y_vec[i] - y_mean)*(y_vec[i] - y_mean);
        }

        double r2 = 1.0 - (sse / sst);
        double f_model = ( (sst - sse) / 4.0 ) / (sse / (n - 5));
        
        double p_value = 1.0 - stats::pf(f_model, 4.0, static_cast<double>(n - 5));

        out_metrics[0] = r2;
        out_metrics[1] = f_model;
        out_metrics[2] = p_value;
        
        double mse = sse / (n - 5);
        out_metrics[3] = mse; // MSE
        out_metrics[4] = sst - sse; // SSR
        out_metrics[5] = sst; // SST
        
        // Calculate Standard Errors and T-statistics for Beta parameters
        for(int i = 0; i < 5; i++) {
            double se = std::sqrt(mse * XtX_inv[i][i]);
            double t_stat = out_beta[i] / se;
            double p_val_t = 2.0 * (1.0 - stats::pt(std::abs(t_stat), static_cast<double>(n - 5)));
            
            out_metrics[6 + i] = se; // 6..10
            out_metrics[11 + i] = t_stat; // 11..15
            out_metrics[16 + i] = p_val_t; // 16..20
        }
    }
}
