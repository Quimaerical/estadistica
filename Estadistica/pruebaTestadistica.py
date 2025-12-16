# -*- coding: utf-8 -*-
"""
Análisis Estadístico: Prueba t de Student para una Muestra

Este script automatiza el proceso de inferencia estadística visto en la pizarra,
enfocado en la prueba de hipótesis para la media de una población cuando la
desviación estándar poblacional (σ) es desconocida.

Utiliza las librerías NumPy para cálculos numéricos eficientes y SciPy para
las funciones estadísticas avanzadas.
"""

import numpy as np
from scipy import stats

def realizar_prueba_t_una_muestra(datos_muestra, mu_hipotetica, alpha):
    """
    Realiza una prueba t de Student para una muestra y muestra los resultados.

    Esta función replica los cálculos de la pizarra:
    1. Calcula los estadísticos de la muestra (tamaño, media, desviación estándar).
    2. Calcula el estadístico t.
    3. Calcula el p-valor.
    4. Interpreta el resultado basándose en un nivel de significancia.

    Args:
        datos_muestra (list or np.array): Una lista de números con los datos de la muestra.
        mu_hipotetica (float): El valor de la media poblacional (μ) que se quiere probar.
        alpha (float, optional): El nivel de significancia para la prueba. Por defecto es 0.05.
    """
    print("="*50)
    print("Iniciando Análisis Estadístico: Prueba t para una Muestra")
    print("="*50)

    # --- 1. Calcular estadísticos descriptivos de la muestra ---
    # Convertimos los datos a un array de NumPy para facilitar los cálculos.
    muestra_array = np.array(datos_muestra)

    # Tamaño de la muestra (n)
    n = len(muestra_array)

    # Media muestral (X̄)
    media_muestral = np.mean(muestra_array)

    # Desviación estándar muestral (S).
    # 'ddof=1' (Delta Degrees of Freedom) es crucial para calcular la desviación
    # estándar MUESTRAL (dividiendo por n-1) en lugar de la poblacional (dividiendo por n).
    desviacion_estandar_muestral = np.std(muestra_array, ddof=1)
    
    # Varianza muestral (S²)
    varianza_muestral = np.var(muestra_array, ddof=1)

    print("\n[1] Estadísticos Descriptivos de la Muestra:")
    print(f"   - Tamaño de la muestra (n): {n}")
    print(f"   - Media muestral (X̄): {media_muestral:.4f}")
    print(f"   - Desviación Estándar muestral (S): {desviacion_estandar_muestral:.4f}")
    print(f"   - Varianza muestral (S²): {varianza_muestral:.4f}")

    # --- 2. Realizar la prueba t de Student ---
    # scipy.stats.ttest_1samp hace todo el trabajo por nosotros:
    # calcula el estadístico t y el p-valor (para una prueba de dos colas).
    # La fórmula que aplica internamente es: t = (media_muestral - mu_hipotetica) / (S / sqrt(n))
    
    # Grados de libertad (n-1)
    grados_libertad = n - 1
    
    t_statistic, p_value = stats.ttest_1samp(
        a=muestra_array,
        popmean=mu_hipotetica
    )

    print("\n[2] Resultados de la Prueba de Hipótesis:")
    print(f"   - Hipótesis nula (H₀): μ = {mu_hipotetica}")
    print(f"   - Grados de libertad (n-1): {grados_libertad}")
    print(f"   - Estadístico t calculado: {t_statistic:.4f}")
    print(f"   - Valor p (p-value): {p_value:.4f}")

    # --- 3. Interpretación del resultado ---
    print("\n[3] Conclusión:")
    print(f"   - Nivel de significancia (α): {alpha}")

    if p_value < alpha:
        print(f"   - Decisión: Rechazar la hipótesis nula (H₀).")
        print(f"   - Interpretación: El resultado es estadísticamente significativo. Existe evidencia")
        print(f"     suficiente para concluir que la verdadera media poblacional es diferente de {mu_hipotetica}.")
    else:
        print(f"   - Decisión: No rechazar la hipótesis nula (H₀).")
        print(f"   - Interpretación: El resultado no es estadísticamente significativo. No hay evidencia")
        print(f"     suficiente para concluir que la verdadera media poblacional sea diferente de {mu_hipotetica}.")
    print("="*50)


if __name__ == '__main__':
    # --- EJEMPLO DE USO ---
    # Usaremos un conjunto de datos que se asemeja a los resultados de la pizarra.
    # En la pizarra: n=10, media≈101.02, S²≈6.02
    # El siguiente conjunto de datos genera valores muy similares.
    
    datos_de_google = [80, 72, 85, 74, 90, 78, 69, 82]
    
    # La media poblacional que queremos probar
    media_poblacional_hipotetica = 75.0
    alpha = 0.05

    # Llamamos a la función para que ejecute todo el análisis.
    realizar_prueba_t_una_muestra(datos_de_google, media_poblacional_hipotetica, alpha)

