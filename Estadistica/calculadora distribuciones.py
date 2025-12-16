# -*- coding: utf-8 -*-
"""
Calculadora Estadística Interactiva

Este script funciona como una herramienta completa para calcular probabilidades y
valores críticos (cuantiles) para diversas distribuciones de probabilidad,
reemplazando la necesidad de usar tablas estadísticas físicas.

Utiliza las potentes funciones de la librería SciPy.

Funcionalidades:
- Permite elegir entre las distribuciones más comunes (Normal, t-Student, Chi-cuadrado, F, etc.).
- Para cada distribución, se puede calcular:
  1. CDF (Función de Distribución Acumulada): P(X <= x)
     Dado un valor 'x', calcula la probabilidad acumulada hasta ese punto.
  2. PPF (Función de Punto Porcentual / Inversa de la CDF):
     Dada una probabilidad 'p', encuentra el valor 'x' tal que P(X <= x) = p.
     Esto es ideal para encontrar valores críticos.
"""

from scipy import stats
import numpy as np

def get_float_input(prompt):
    """Función auxiliar para obtener un input numérico del usuario de forma segura."""
    while True:
        try:
            return float(input(prompt))
        except ValueError:
            print("Error: Por favor, ingrese un valor numérico válido.")

def calcular_normal():
    print("\n--- Distribución Normal ---")
    mu = get_float_input("Ingrese la media (μ): ")
    sigma = get_float_input("Ingrese la desviación estándar (σ): ")
    
    opcion = input("¿Qué desea calcular? (1: Probabilidad P(X<=x) [CDF] / 2: Valor x [PPF]): ")
    
    if opcion == '1':
        x = get_float_input("Ingrese el valor de x: ")
        prob = stats.norm.cdf(x, loc=mu, scale=sigma)
        print(f"Resultado: P(X <= {x}) = {prob:.5f}")
    elif opcion == '2':
        p = get_float_input("Ingrese la probabilidad acumulada p (ej. 0.95): ")
        x = stats.norm.ppf(p, loc=mu, scale=sigma)
        print(f"Resultado: El valor de x tal que P(X <= x) = {p} es {x:.5f}")
    else:
        print("Opción no válida.")

def calcular_t_student():
    print("\n--- Distribución t-Student ---")
    df = int(get_float_input("Ingrese los grados de libertad (ν): "))
    
    opcion = input("¿Qué desea calcular? (1: Probabilidad P(T<=t) [CDF] / 2: Valor t [PPF]): ")

    if opcion == '1':
        t = get_float_input("Ingrese el valor de t: ")
        prob = stats.t.cdf(t, df=df)
        print(f"Resultado: P(T <= {t}) = {prob:.5f}")
    elif opcion == '2':
        p = get_float_input("Ingrese la probabilidad acumulada p: ")
        t = stats.t.ppf(p, df=df)
        print(f"Resultado: El valor de t tal que P(T <= t) = {p} es {t:.5f}")
    else:
        print("Opción no válida.")

def calcular_chi_cuadrado():
    print("\n--- Distribución Chi-cuadrado (χ²) ---")
    df = int(get_float_input("Ingrese los grados de libertad (ν): "))

    opcion = input("¿Qué desea calcular? (1: Probabilidad P(X²<=x) [CDF] / 2: Valor x [PPF]): ")

    if opcion == '1':
        x = get_float_input("Ingrese el valor de x (chi²): ")
        prob = stats.chi2.cdf(x, df=df)
        print(f"Resultado: P(χ² <= {x}) = {prob:.5f}")
    elif opcion == '2':
        p = get_float_input("Ingrese la probabilidad acumulada p: ")
        x = stats.chi2.ppf(p, df=df)
        print(f"Resultado: El valor de x tal que P(χ² <= x) = {p} es {x:.5f}")
    else:
        print("Opción no válida.")

def calcular_f_snedecor():
    print("\n--- Distribución F de Snedecor ---")
    dfn = int(get_float_input("Ingrese los grados de libertad del numerador (ν₁): "))
    dfd = int(get_float_input("Ingrese los grados de libertad del denominador (ν₂): "))

    opcion = input("¿Qué desea calcular? (1: Probabilidad P(F<=f) [CDF] / 2: Valor f [PPF]): ")

    if opcion == '1':
        f = get_float_input("Ingrese el valor de f: ")
        prob = stats.f.cdf(f, dfn=dfn, dfd=dfd)
        print(f"Resultado: P(F <= {f}) = {prob:.5f}")
    elif opcion == '2':
        p = get_float_input("Ingrese la probabilidad acumulada p: ")
        f = stats.f.ppf(p, dfn=dfn, dfd=dfd)
        print(f"Resultado: El valor de f tal que P(F <= f) = {p} es {f:.5f}")
    else:
        print("Opción no válida.")

def calcular_gamma():
    print("\n--- Distribución Gamma ---")
    # En SciPy, 'a' es el parámetro de forma (α) y 'scale' es el de escala (β)
    alpha = get_float_input("Ingrese el parámetro de forma (α): ")
    beta = get_float_input("Ingrese el parámetro de escala (β): ")

    opcion = input("¿Qué desea calcular? (1: Probabilidad P(X<=x) [CDF] / 2: Valor x [PPF]): ")

    if opcion == '1':
        x = get_float_input("Ingrese el valor de x: ")
        prob = stats.gamma.cdf(x, a=alpha, scale=beta)
        print(f"Resultado: P(X <= {x}) = {prob:.5f}")
    elif opcion == '2':
        p = get_float_input("Ingrese la probabilidad acumulada p: ")
        x = stats.gamma.ppf(p, a=alpha, scale=beta)
        print(f"Resultado: El valor de x tal que P(X <= x) = {p} es {x:.5f}")
    else:
        print("Opción no válida.")


def menu_principal():
    """Muestra el menú principal y gestiona la selección del usuario."""
    while True:
        print("\n" + "="*40)
        print("    Calculadora de Probabilidades")
        print("="*40)
        print("Seleccione la distribución de probabilidad:")
        print("1. Normal")
        print("2. t-Student")
        print("3. Chi-cuadrado (χ²)")
        print("4. F de Snedecor")
        print("5. Gamma")
        print("0. Salir")

        opcion = input("Ingrese su opción: ")

        if opcion == '1':
            calcular_normal()
        elif opcion == '2':
            calcular_t_student()
        elif opcion == '3':
            calcular_chi_cuadrado()
        elif opcion == '4':
            calcular_f_snedecor()
        elif opcion == '5':
            calcular_gamma()
        elif opcion == '0':
            print("Saliendo de la calculadora. ¡Hasta luego!")
            break
        else:
            print("Opción no válida. Por favor, intente de nuevo.")

if __name__ == "__main__":
    menu_principal()

