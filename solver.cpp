#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>

using namespace std;

// Minimal pt and pf using standard approximations if needed, or just dummy since we only need the betas and exact SSA/SSE/SST
// Wait, I can just calculate OLS and ANOVA here.
int main() {
    // PARTE 1
    vector<double> data1 = {3.30, 3.42, 3.36, 3.34};
    vector<double> data2 = {3.25, 3.15, 3.30, 3.20};
    vector<double> data3 = {3.10, 3.25, 3.18, 3.12};

    int n1=4, n2=4, n3=4;
    double m1=0, m2=0, m3=0;
    for(auto v: data1) m1+=v; m1/=4;
    for(auto v: data2) m2+=v; m2/=4;
    for(auto v: data3) m3+=v; m3/=4;
    double g = (4*m1 + 4*m2 + 4*m3);
    double gm = g/12;
    double sst=0;
    for(auto v: data1) sst+=(v-gm)*(v-gm);
    for(auto v: data2) sst+=(v-gm)*(v-gm);
    for(auto v: data3) sst+=(v-gm)*(v-gm);
    double ssa = 4*(m1-gm)*(m1-gm) + 4*(m2-gm)*(m2-gm) + 4*(m3-gm)*(m3-gm);
    double sse = sst - ssa;
    double msa = ssa/2;
    double mse = sse/9;
    double f = msa/mse;

    cout << "PARTE 1\n";
    cout << fixed << setprecision(6);
    cout << "GM: " << gm << "\n";
    cout << "MSE: " << mse << "\n";
    cout << "tau1: " << m1-gm << " tau2: " << m2-gm << " tau3: " << m3-gm << "\n";
    cout << "SSA: " << ssa << " SSE: " << sse << " SST: " << sst << " F: " << f << "\n";


    // PARTE 2 Matrix
    double y[20] = {9.8, 12.6, 11.9, 13.1, 13.3, 13.5, 10.1, 13.1, 10.7, 11.0, 13.0, 11.6, 12.0, 11.4, 12.2, 12.8, 12.4, 13.2, 10.6, 7.9};
    double x1[20] = {3.3, 4.4, 3.9, 5.9, 4.6, 5.2, 4.0, 4.7, 4.5, 3.7, 4.6, 4.7, 3.9, 4.6, 5.1, 5.0, 4.8, 5.3, 3.9, 3.4};
    double x2[20] = {2.8, 4.9, 5.3, 2.6, 5.1, 3.2, 4.0, 4.5, 4.1, 3.6, 4.6, 3.5, 4.6, 4.0, 3.6, 4.4, 4.4, 3.5, 3.8, 3.8};
    double x3[20] = {3.1, 3.5, 4.8, 3.1, 5.0, 3.3, 3.3, 3.5, 3.7, 3.3, 3.6, 3.5, 3.6, 3.4, 3.3, 3.6, 3.4, 3.6, 3.4, 3.4};
    double x4[20] = {4.1, 3.9, 4.7, 3.6, 4.1, 4.3, 4.0, 3.8, 3.6, 3.6, 3.6, 3.7, 4.1, 3.6, 4.0, 3.7, 3.6, 3.7, 4.0, 3.4};

    double XtX[5][5] = {0};
    double XtY[5] = {0};
    int n = 20;

    for (int i = 0; i < n; ++i) {
        double row[5] = {1.0, x1[i], x2[i], x3[i], x4[i]};
        for (int r = 0; r < 5; ++r) {
            XtY[r] += row[r] * y[i];
            for (int c = 0; c < 5; ++c) {
                XtX[r][c] += row[r] * row[c];
            }
        }
    }

    double mat[5][5], inv[5][5];
    for (int r=0; r<5; r++) {
        for(int c=0; c<5; c++) {
            mat[r][c] = XtX[r][c];
            inv[r][c] = (r==c)?1.0:0.0;
        }
    }

    for (int i = 0; i < 5; ++i) {
        int pivot_row = i;
        for (int k = i + 1; k < 5; ++k) {
            if (std::abs(mat[k][i]) > std::abs(mat[pivot_row][i])) {
                pivot_row = k;
            }
        }
        if (i != pivot_row) {
            for (int j = 0; j < 5; ++j) {
                std::swap(mat[i][j], mat[pivot_row][j]);
                std::swap(inv[i][j], inv[pivot_row][j]);
            }
        }
        double pivot = mat[i][i];
        for (int j = 0; j < 5; ++j) {
            mat[i][j] /= pivot;
            inv[i][j] /= pivot;
        }
        for (int k = 0; k < 5; ++k) {
            if (k != i) {
                double factor = mat[k][i];
                for (int j = 0; j < 5; ++j) {
                    mat[k][j] -= factor * mat[i][j];
                    inv[k][j] -= factor * inv[i][j];
                }
            }
        }
    }

    double beta[5] = {0};
    for(int i=0; i<5; i++) {
        for(int j=0; j<5; j++) {
            beta[i] += inv[i][j] * XtY[j];
        }
    }

    double mean_y = 0;
    for(int i=0; i<20; ++i) mean_y+=y[i];
    mean_y/=20;

    double sst2=0, sse2=0;
    for(int i=0; i<20; i++){
        sst2 += (y[i]-mean_y)*(y[i]-mean_y);
        double y_hat = beta[0] + beta[1]*x1[i] + beta[2]*x2[i] + beta[3]*x3[i] + beta[4]*x4[i];
        sse2 += (y[i]-y_hat)*(y[i]-y_hat);
    }
    double r2 = 1.0 - (sse2/sst2);
    double mse2 = sse2 / 15.0;

    cout << "\nPARTE 2\n";
    cout << "Beta0: " << beta[0] << "\n";
    cout << "Beta1: " << beta[1] << "\n";
    cout << "Beta2: " << beta[2] << "\n";
    cout << "Beta3: " << beta[3] << "\n";
    cout << "Beta4: " << beta[4] << "\n";
    cout << "R2: " << r2 << "\n";
    cout << "MSE RLM: " << mse2 << "\n";
    
    // Prediccion
    double pred = beta[0] + beta[1]*5.1 + beta[2]*4.7 + beta[3]*4.8 + beta[4]*4.0;
    cout << "Pred(5.1, 4.7, 4.8, 4.0): " << pred << "%\n";

    double tCrit = 2.131450;
    for(int i=0; i<5; i++) {
        double se = std::sqrt(mse2 * inv[i][i]);
        cout << "Beta" << i << " SE: " << se << " IC: [" << beta[i] - tCrit*se << ", " << beta[i] + tCrit*se << "]\n";
        cout << "TStat" << i << ": " << beta[i]/se << "\n";
    }

    return 0;
}
