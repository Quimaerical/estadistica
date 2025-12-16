# -*- coding: utf-8 -*-
"""
Guía y Calculadora del Método de Momentos.
Herramienta completa que muestra:
1. Fórmulas teóricas de las distribuciones.
2. Fórmulas universales de los momentos muestrales.
3. Calculadora de momentos teóricos (poblacionales).
4. Calculadora de momentos empíricos (muestrales) a partir de datos.
"""
import scipy.stats as stats
import numpy as np
import math

# --- SECCIÓN 1: CALCULADORA DE MOMENTOS MUESTRALES ---

def calcular_momentos_muestrales():
    """Pide al usuario una lista de datos y calcula sus momentos muestrales."""
    print("\n--- Calculadora de Momentos Muestrales ---")
    print("Introduce tus datos numéricos separados por espacios o comas.")
    print("Ejemplo: 2.5 4 5.1 6 7.2")
    input_str = input("Datos: ")
    input_str = input_str.replace(',', ' ')
    try:
        datos = np.array([float(item) for item in input_str.split()])
        if datos.size == 0:
            print("Error: No se introdujeron datos.")
            return
        media = np.mean(datos)
        varianza = np.var(datos)
        asimetria = stats.skew(datos, bias=True)
        curtosis = stats.kurtosis(datos, fisher=True, bias=True)
        
        print("\nResultados de los Momentos Muestrales:")
        print("---------------------------------------")
        print(f"  - Número de datos (n): {datos.size}")
        print(f"  - Media (x̄):               {media:.4f}")
        print(f"  - Varianza (m₂):           {varianza:.4f}")
        print(f"  - Asimetría:               {asimetria:.4f}")
        print(f"  - Curtosis (Exceso):       {curtosis:.4f}")
        print("---------------------------------------")
    except ValueError:
        print("\nError: Asegúrate de que todos los datos introducidos son números válidos.")
    except Exception as e:
        print(f"\nHa ocurrido un error inesperado: {e}")

# --- SECCIÓN 2: CLASES DE DISTRIBUCIONES ---

class Distribucion:
    """Clase base para las distribuciones."""
    def __init__(self, nombre, tipo, parametros, fmp_fdp_formula, momentos_formulas):
        self.nombre = nombre
        self.tipo = tipo
        self.parametros_requeridos = parametros
        self.fmp_fdp_formula = fmp_fdp_formula
        self.momentos_formulas = momentos_formulas

    def mostrar_info(self):
        """Muestra las fórmulas de los momentos teóricos y muestrales."""
        print(f"\n--- {self.nombre} ---")
        print(f"Tipo: {self.tipo}")
        print(f"\nFórmula de {'FMP' if self.tipo == 'Discreta' else 'FDP'}:")
        print(f"  {self.fmp_fdp_formula}")
        
        print("\n--- Fórmulas para el Método de Momentos ---")
        
        print("\nMomentos Teóricos (Poblacionales)")
        print("  (Fórmulas específicas de esta distribución, dependen de sus parámetros)")
        for nombre, formula in self.momentos_formulas.items():
            print(f"    - {nombre}: {formula}")

        print("\nMomentos Muestrales (Empíricos)")
        print("  (Fórmulas universales, se calculan a partir de los datos x₁, ..., xₙ)")
        print("    - 1er Momento (Media, x̄): (1/n) * Σxᵢ")
        print("    - 2do Momento Central (Varianza, m₂): (1/n) * Σ(xᵢ - x̄)²")
        print("    - 3er Momento Central (m₃): (1/n) * Σ(xᵢ - x̄)³")
        print("    - 4to Momento Central (m₄): (1/n) * Σ(xᵢ - x̄)⁴")
        
        print("\nEl método consiste en igualar los momentos correspondientes y resolver para los parámetros.")
        print("--------------------------------------------------")


    def calcular_momentos_teoricos(self, *args):
        raise NotImplementedError("Este método debe ser implementado por las subclases.")

# --- Implementaciones específicas ---

class Normal(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución Normal", "Continua", ["μ (media)", "σ (desv. estándar)"],
            "f(x) = (1 / (σ√2π)) * exp(-0.5 * ((x-μ)/σ)²)",
            {"Media": "μ", "Varianza": "σ²", "Asimetría": "0", "Curtosis (Exceso)": "0"}
        )
    def calcular_momentos_teoricos(self, mu, sigma):
        mean, var, skew, kurt = stats.norm.stats(loc=mu, scale=sigma, moments='mvsk')
        print(f"\nValores calculados con μ={mu}, σ={sigma}:")
        print(f"  - Media: {mean:.4f}\n  - Varianza: {var:.4f}\n  - Asimetría: {skew:.4f}\n  - Curtosis (Exceso): {kurt:.4f}")

class Binomial(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución Binomial", "Discreta", ["n (ensayos)", "p (prob. de éxito)"],
            "P(k) = C(n,k) * p^k * (1-p)^(n-k)",
            {"Media": "n*p", "Varianza": "n*p*(1-p)", "Asimetría": "(1 - 2p) / √(n*p*(1-p))", "Curtosis (Exceso)": "(1 - 6p(1-p)) / (n*p*(1-p))"}
        )
    def calcular_momentos_teoricos(self, n, p):
        mean, var, skew, kurt = stats.binom.stats(n=int(n), p=p, moments='mvsk')
        print(f"\nValores calculados con n={int(n)}, p={p}:")
        print(f"  - Media: {mean:.4f}\n  - Varianza: {var:.4f}\n  - Asimetría: {skew:.4f}\n  - Curtosis (Exceso): {kurt:.4f}")

class Poisson(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución de Poisson", "Discreta", ["λ (tasa)"],
            "P(k) = (λ^k * exp(-λ)) / k!",
            {"Media": "λ", "Varianza": "λ", "Asimetría": "1 / √λ", "Curtosis (Exceso)": "1 / λ"}
        )
    def calcular_momentos_teoricos(self, lam):
        mean, var, skew, kurt = stats.poisson.stats(mu=lam, moments='mvsk')
        print(f"\nValores calculados con λ={lam}:")
        print(f"  - Media: {mean:.4f}\n  - Varianza: {var:.4f}\n  - Asimetría: {skew:.4f}\n  - Curtosis (Exceso): {kurt:.4f}")

class Exponencial(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución Exponencial", "Continua", ["λ (tasa)"],
            "f(x) = λ * exp(-λx)",
            {"Media": "1/λ", "Varianza": "1/λ²", "Asimetría": "2", "Curtosis (Exceso)": "6"}
        )
    def calcular_momentos_teoricos(self, lam):
        scale = 1 / lam
        mean, var, skew, kurt = stats.expon.stats(scale=scale, moments='mvsk')
        print(f"\nValores calculados con λ={lam}:")
        print(f"  - Media: {mean:.4f}\n  - Varianza: {var:.4f}\n  - Asimetría: {skew:.4f}\n  - Curtosis (Exceso): {kurt:.4f}")

class Uniforme(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución Uniforme", "Continua", ["a (mínimo)", "b (máximo)"],
            "f(x) = 1 / (b - a)",
            {"Media": "(a+b)/2", "Varianza": "(b-a)²/12", "Asimetría": "0", "Curtosis (Exceso)": "-6/5"}
        )
    def calcular_momentos_teoricos(self, a, b):
        loc, scale = a, b-a
        mean, var, skew, kurt = stats.uniform.stats(loc=loc, scale=scale, moments='mvsk')
        print(f"\nValores calculados con a={a}, b={b}:")
        print(f"  - Media: {mean:.4f}\n  - Varianza: {var:.4f}\n  - Asimetría: {skew:.4f}\n  - Curtosis (Exceso): {kurt:.4f}")

class Geometrica(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución Geométrica", "Discreta", ["p (prob. de éxito)"],
            "P(k) = (1-p)^(k-1) * p",
            {"Media": "1/p", "Varianza": "(1-p)/p²", "Asimetría": "(2-p) / √(1-p)", "Curtosis (Exceso)": "6 + p²/(1-p)"}
        )
    def calcular_momentos_teoricos(self, p):
        mean, var, skew, kurt = stats.geom.stats(p=p, moments='mvsk')
        print(f"\nValores calculados con p={p}:")
        print(f"  - Media: {mean:.4f}\n  - Varianza: {var:.4f}\n  - Asimetría: {skew:.4f}\n  - Curtosis (Exceso): {kurt:.4f}")

class ChiCuadrado(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución Chi-Cuadrado (χ²)", "Continua", ["k (grados de libertad)"],
            "f(x) ∝ x^((k/2)-1) * exp(-x/2)",
            {"Media": "k", "Varianza": "2k", "Asimetría": "√(8/k)", "Curtosis (Exceso)": "12/k"}
        )
    def calcular_momentos_teoricos(self, k):
        mean, var, skew, kurt = stats.chi2.stats(df=k, moments='mvsk')
        print(f"\nValores calculados con k={k}:")
        print(f"  - Media: {mean:.4f}\n  - Varianza: {var:.4f}\n  - Asimetría: {skew:.4f}\n  - Curtosis (Exceso): {kurt:.4f}")

class TStudent(Distribucion):
    def __init__(self):
        super().__init__(
            "Distribución t de Student", "Continua", ["ν (grados de libertad)"],
            "f(t) ∝ (1+t²/ν)^(-(ν+1)/2)",
            {"Media": "0 (ν>1)", "Varianza": "ν/(ν-2) (ν>2)", "Asimetría": "0 (ν>3)", "Curtosis (Exceso)": "6/(ν-4) (ν>4)"}
        )
    def calcular_momentos_teoricos(self, nu):
        mean, var, skew, kurt = stats.t.stats(df=nu, moments='mvsk')
        print(f"\nValores calculados con ν={nu}:")
        print(f"  - Media: {float(mean):.4f} (definida si ν > 1)")
        print(f"  - Varianza: {float(var):.4f} (definida si ν > 2)")
        print(f"  - Asimetría: {float(skew):.4f} (definida si ν > 3)")
        print(f"  - Curtosis (Exceso): {float(kurt):.4f} (definida si ν > 4)")
        print("  (Nota: 'inf' o 'nan' significa que el momento no está definido para ese valor de ν)")

# --- SECCIÓN 3: INTERFAZ DE USUARIO ---

def main():
    distribuciones = {
        "1": Normal(), "2": Binomial(), "3": Poisson(), "4": Exponencial(),
        "5": Uniforme(), "6": Geometrica(), "7": ChiCuadrado(), "8": TStudent(),
    }
    print("Bienvenido a la Guía y Calculadora del Método de Momentos.")
    while True:
        print("\nSelecciona una opción:")
        print("--- Guía de Distribuciones Teóricas ---")
        for key, dist in distribuciones.items():
            print(f"  {key}. {dist.nombre}")
        print("\n--- Herramientas de Cálculo ---")
        print("  9. Calcular momentos de mi propia muestra")
        print("\n  0. Salir")
        
        opcion = input("Opción: ")

        if opcion == "0":
            print("Hasta luego.")
            break
        elif opcion == "9":
            calcular_momentos_muestrales()
        elif opcion in distribuciones:
            dist = distribuciones[opcion]
            dist.mostrar_info()
            
            # Lógica de cálculo integrada
            calcular = input("\n¿Deseas calcular los valores numéricos para esta distribución? (s/n): ").lower()
            if calcular == 's':
                try:
                    params = [float(input(f"  Introduce el valor para '{p}': ")) for p in dist.parametros_requeridos]
                    dist.calcular_momentos_teoricos(*params)
                except ValueError:
                    print("\nError: Por favor, introduce un valor numérico válido.")
                except Exception as e:
                    print(f"\nHa ocurrido un error inesperado: {e}")
        else:
            print("Opción no válida. Inténtalo de nuevo.")

if __name__ == "__main__":
    main()