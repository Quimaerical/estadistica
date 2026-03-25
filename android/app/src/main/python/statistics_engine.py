import sympy as sp
from sympy import symbols, log, diff, solve, exp, zoo, oo, pi, sqrt, summation, IndexedBase, Idx
from typing import Dict, Any, List

class DistributionModel:
    def __init__(self, distribution_type: str):
        self.distribution_type = distribution_type
        self.latex_steps = []
        
    def add_step(self, title: str, latex_content: str):
        self.latex_steps.append(f"\\textbf{{{title}}}: $${latex_content}$$")

    def analyze(self, sample_data: List[float] = None) -> Dict[str, Any]:
        results = {
            "mle": self.calculate_mle(),
            "mm": self.calculate_mm(),
            "properties": self.check_ices(),
            "steps": self.latex_steps
        }
        return results

    def _get_pdf(self):
        # Define symbols common to all
        x = symbols('x')
        n = symbols('n', integer=True, positive=True)
        # i = Idx('i', (1, n)) # Using generic index for display
        # X = IndexedBase('X') # For sample notation X_i
        
        if self.distribution_type == "Exponential":
            theta = symbols('theta', positive=True) # Rate parameter lambda often called theta in inference context or lambda
            pdf = theta * exp(-theta * x)
            return pdf, [theta], x
            
        elif self.distribution_type == "Normal":
            mu = symbols('mu', real=True)
            sigma2 = symbols('sigma^2', positive=True) # Variance
            pdf = (1 / sqrt(2 * pi * sigma2)) * exp(-(x - mu)**2 / (2 * sigma2))
            return pdf, [mu, sigma2], x
            
        return None, None, None

    def calculate_mle(self):
        self.add_step("Maximum Likelihood Estimation", "\\text{Starting MLE Procedure...}")
        
        pdf, params, x = self._get_pdf()
        if not pdf:
            return "Distribution not implemented"

        # 1. Likelihood Function
        n = symbols('n', integer=True, positive=True)
        # Represent Product of PDF symbolically
        # For display purposes, we show the general form
        
        if self.distribution_type == "Exponential":
            theta = params[0]
            # L(theta) = theta^n * exp(-theta * sum(x_i))
            sum_xi = symbols('sum_x') # Represents \sum x_i
            L = theta**n * exp(-theta * sum_xi)
            self.add_step("Likelihood Function L", sp.latex(L))
            
            # 2. Log-Likelihood
            ln_L = log(L).expand(force=True) # force=True to simplify log(exp)
            self.add_step("Log-Likelihood ln(L)", sp.latex(ln_L))
            
            # 3. Differentiate
            d_ln_L = diff(ln_L, theta)
            self.add_step("Partial Derivative d/d(theta)", sp.latex(d_ln_L))
            
            # 4. Solve for theta
            estimator = solve(d_ln_L, theta)[0]
            self.add_step("Solved Estimator (MLE)", "\\hat{\\theta} = " + sp.latex(estimator))
            
            return str(estimator).replace("sum_x", "\\sum X_i")

        elif self.distribution_type == "Normal":
            mu, sigma2 = params
            sum_xi = symbols('S_1') # sum x
            sum_xi_sq = symbols('S_2') # sum (x - mu)^2 approximately
            
            # For Normal, we do log likelihood directly to save complexity in symbolic expansion of product
            # ln L = -n/2 ln(2pi) - n/2 ln(sigma2) - 1/(2sigma2) sum(x_i - mu)^2
            
            # Deriv wrt mu
            # d/dmu = 1/sigma2 * sum(x_i - mu) = 0 => sum x_i - n*mu = 0 => mu = sum x_i / n
            
            # This is hard to do purely symbolically without proper Summation handling in SymPy which can be tricky
            # We will construct the known steps for display.
            
            # Partial wrt mu
            dl_dmu = " \\frac{1}{\\sigma^2} \\sum (x_i - \\mu) "
            self.add_step("Partial Derivative w.r.t mu", dl_dmu + " = 0 \\implies \\hat{\\mu} = \\bar{X}")
            
            # Partial wrt sigma2
            dl_dsigma2 = " -\\frac{n}{2\\sigma^2} + \\frac{1}{2(\\sigma^2)^2} \\sum (x_i - \\mu)^2 "
            self.add_step("Partial Derivative w.r.t sigma^2", dl_dsigma2 + " = 0")
            
            sol_sigma2 = "\\hat{\\sigma}^2 = \\frac{1}{n} \\sum (x_i - \\bar{X})^2"
            self.add_step("Solved Estimator for Sigma^2", sol_sigma2)
            
            return {"mu": "\\bar{X}", "sigma2": "\\frac{1}{n} S_{XX}"}

        return "N/A"

    def calculate_mm(self):
        self.add_step("Method of Moments", "\\text{Equating sample moments to theoretical moments}")
        
        pdf, params, x = self._get_pdf()
        
        # E[X]
        mu_1 = sp.integrate(x * pdf, (x, -oo, oo)) if self.distribution_type == "Normal" else sp.integrate(x * pdf, (x, 0, oo))
        # Simplify if necessary (Exponential E[X] should be 1/theta)
        
        self.add_step("Theoretical First Moment E[X]", sp.latex(mu_1))
        
        M1 = symbols('M_1') # Sample mean
        
        if self.distribution_type == "Exponential":
            theta = params[0]
            # eq: 1/theta = M1
            estimator = solve(mu_1 - M1, theta)[0]
            self.add_step("Solved Estimator (MM)", "\\hat{\\theta}_{MM} = " + sp.latex(estimator))
            return str(estimator).replace("M_1", "\\bar{X}")
            
        elif self.distribution_type == "Normal":
            # Need 2nd moment
            mu, sigma2 = params
            mu_2 = sp.integrate(x**2 * pdf, (x, -oo, oo))
            self.add_step("Theoretical Second Moment E[X^2]", sp.latex(mu_2)) # Should be mu^2 + sigma^2
            
            M2 = symbols('M_2')
            
            # System
            # mu = M1
            # mu^2 + sigma^2 = M2
            
            self.add_step("System of Equations", f"\\mu = M_1 \\\\ \\sigma^2 + \\mu^2 = M_2")
            
            sol_mu = M1
            sol_sigma2 = M2 - M1**2 
            
            self.add_step("Solved Estimators (MM)", f"\\hat{{\\mu}} = M_1, \\quad \\hat{{\\sigma}}^2 = M_2 - M_1^2 = S^2_{ biased}")
            return {"mu": "M_1", "sigma2": "M_2 - M_1^2"}

        return "N/A"

    def check_ices(self):
        # Information criteria check (Fisher, Cramer-Rao)
        self.add_step("Properties check", "\\text{Checking Bias and Efficiency}")
        
        if self.distribution_type == "Exponential":
            # Check bias of 1/X_bar for theta? Actually MLE for exp is 1/X_bar.
            # E[1/X_bar] = n * E[1/Sum(X)]. Sum(X) ~ Gamma(n, theta). 
            # E[1/G] = theta * n / (n-1). so E[hat_theta] = n/(n-1) * theta. Biased.
            
            self.add_step("Bias Check", "E[\\hat{\\theta}] = \\frac{n}{n-1}\\theta \\neq \\theta \\implies \\text{Biased}")
            
            # Fisher Info
            # I(theta) = E[ (d/dtheta ln f)^2 ]
            # ln f = ln theta - theta x
            # d/dtheta = 1/theta - x
            # E[ (1/theta - X)^2 ] = Var(X) = 1/theta^2
            # I_n(theta) = n / theta^2
            
            self.add_step("Fisher Information I(theta)", "I(\\theta) = \\frac{n}{\\theta^2}")
            self.add_step("Cramer-Rao Lower Bound", "CRLB = \\frac{1}{I(\\theta)} = \\frac{\\theta^2}{n}")
            
            return "Biased, CRLB computed"
            
        return "Properties check pending implementation for this distribution"
