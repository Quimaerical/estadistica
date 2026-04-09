import numpy as np
import scipy.stats as stats
import statsmodels.api as sm
from statsmodels.stats.multicomp import MultiComparison

# PARTE 1
print("============== PARTE 1 ==============")
y1 = np.array([3.30, 3.42, 3.36, 3.34])
y2 = np.array([3.25, 3.15, 3.30, 3.20])
y3 = np.array([3.10, 3.25, 3.18, 3.12])

all_y = np.concatenate([y1, y2, y3])
N = len(all_y)
k = 3
mu = np.mean(all_y)
mean1 = np.mean(y1)
mean2 = np.mean(y2)
mean3 = np.mean(y3)
tau1 = mean1 - mu
tau2 = mean2 - mu
tau3 = mean3 - mu

ssa = len(y1)*(mean1 - mu)**2 + len(y2)*(mean2 - mu)**2 + len(y3)*(mean3 - mu)**2
sst = np.sum((all_y - mu)**2)
sse = sst - ssa

dfA = k - 1
dfE = N - k
msa = ssa / dfA
mse = sse / dfE
F0 = msa / mse
p_val = stats.f.sf(F0, dfA, dfE)

print(f"mu={mu:.6f}, tau1={tau1:.6f}, tau2={tau2:.6f}, tau3={tau3:.6f}")
print(f"SSA={ssa:.6f}, SSE={sse:.6f}, SST={sst:.6f}, F0={F0:.6f}, p-val={p_val:.6f}")

print("\n============== PARTE 2 ==============")
y = np.array([9.8, 12.6, 11.9, 13.1, 13.3, 13.5, 10.1, 13.1, 10.7, 11.0, 13.0, 11.6, 12.0, 11.4, 12.2, 12.8, 12.4, 13.2, 10.6, 7.9])
x1 = np.array([3.3, 4.4, 3.9, 5.9, 4.6, 5.2, 4.0, 4.7, 4.5, 3.7, 4.6, 4.7, 3.9, 4.6, 5.1, 5.0, 4.8, 5.3, 3.9, 3.4])
x2 = np.array([2.8, 4.9, 5.3, 2.6, 5.1, 3.2, 4.0, 4.5, 4.1, 3.6, 4.6, 3.5, 4.6, 4.0, 3.6, 4.4, 4.4, 3.5, 3.8, 3.8])
x3 = np.array([3.1, 3.5, 4.8, 3.1, 5.0, 3.3, 3.3, 3.5, 3.7, 3.3, 3.6, 3.5, 3.6, 3.4, 3.3, 3.6, 3.4, 3.6, 3.4, 3.4])
x4 = np.array([4.1, 3.9, 4.7, 3.6, 4.1, 4.3, 4.0, 3.8, 3.6, 3.6, 3.6, 3.7, 4.1, 3.6, 4.0, 3.7, 3.6, 3.7, 4.0, 3.4])

X = np.column_stack((x1, x2, x3, x4))
X = sm.add_constant(X)
model = sm.OLS(y, X).fit()
print(model.summary().as_text())

pred_X = [1, 5.1, 4.7, 4.8, 4.0]
y_pred = model.predict(pred_X)
print(f"Prediccion (5.1, 4.7, 4.8, 4.0): {y_pred[0]}")
