import numpy as np
import matplotlib.pyplot as plt

# ==============================================================================
# MÓDULO 1: RECONSTRUCCIÓN Y ANÁLISIS DE TABLA DE FRECUENCIAS
# ==============================================================================

def construir_tabla_completa(datos_agrupados):
    """
    Toma una lista de intervalos y frecuencias y construye la tabla completa.
    Input: [[lim_inf, lim_sup, frec_abs], ...]
    Output: [(li, ls, marca, f, fr, F, Fr), ...]
    """
    tabla_completa = []
    total_datos = sum(fila[2] for fila in datos_agrupados)
    if total_datos == 0:
        return []

    frecuencia_acumulada = 0
    frec_rel_acumulada = 0.0

    for li, ls, f in datos_agrupados:
        marca = (li + ls) / 2
        frecuencia_relativa = f / total_datos
        frecuencia_acumulada += f
        frec_rel_acumulada += frecuencia_relativa
        tabla_completa.append((li, ls, marca, f, frecuencia_relativa, frecuencia_acumulada, frec_rel_acumulada))
    
    return tabla_completa

def imprimir_tabla_completa(tabla):
    """
    Imprime una tabla de frecuencias continuas completa.
    """
    print("\nTabla de Frecuencias Reconstruida:")
    print(f"{'Intervalo':>18} {'Marca':>8} {'f':>5} {'fr':>7} {'F':>6} {'Fr':>8}")
    print("-" * 60)
    for i, (li, ls, m, f, fr, F, Fr) in enumerate(tabla):
        intervalo = f"[{li:.2f}, {ls:.2f}]" if i == len(tabla) - 1 else f"[{li:.2f}, {ls:.2f})"
        print(f"{intervalo:>18} {m:8.2f} {f:5d} {fr:7.3f} {int(F):6d} {Fr:8.3f}")

def calcular_cuartil_agrupado(tabla, cuartil):
    """
    Calcula el cuartil (1, 2, 3) para datos agrupados por interpolación.
    """
    n = tabla[-1][5]
    pos = cuartil * n / 4
    
    F_ant = 0
    for li, ls, _, f, _, F, _ in tabla:
        if F >= pos:
            return li + ((pos - F_ant) / f) * (ls - li) if f > 0 else np.nan
        F_ant = F
    return np.nan

def analizar_estadisticas_agrupadas(tabla):
    """
    Calcula un resumen completo de estadísticos y los retorna.
    """
    marcas = np.array([row[2] for row in tabla])
    frecuencias = np.array([row[3] for row in tabla])
    n = np.sum(frecuencias)
    if n == 0: return None, None
    
    media = np.average(marcas, weights=frecuencias)
    var_pob = np.average((marcas - media)**2, weights=frecuencias)
    var_mue = var_pob * (n / (n - 1)) if n > 1 else np.nan
    desv_pob = np.sqrt(var_pob)
    desv_mue = np.sqrt(var_mue) if n > 1 else np.nan
    cv_mue = desv_mue / abs(media) if media != 0 else np.nan
    m3_cen = np.average((marcas - media)**3, weights=frecuencias)
    asimetria = m3_cen / (desv_pob**3) if desv_pob > 0 else np.nan
    m4_cen = np.average((marcas - media)**4, weights=frecuencias)
    curtosis = m4_cen / (desv_pob**4) - 3 if desv_pob > 0 else np.nan
    
    print("\nEstadísticas para Datos Agrupados (Aproximadas):")
    print(f"  Media: {media:.4f}")
    print(f"  Varianza Poblacional: {var_pob:.4f}")
    print(f"  Varianza Muestral: {var_mue:.4f}")
    print(f"  Desv. Estándar Poblacional: {desv_pob:.4f}")
    print(f"  Desv. Estándar Muestral: {desv_mue:.4f}")
    print(f"  Coeficiente de Variación (muestral): {cv_mue:.4f}")
    print(f"  Asimetría (poblacional): {asimetria:.4f}")
    print(f"  Curtosis (exceso, poblacional): {curtosis:.4f}")
    q1, q2, q3 = [round(calcular_cuartil_agrupado(tabla, q), 4) for q in [1, 2, 3]]
    print(f"  Cuartiles (Q1, Q2, Q3) por interpolación: [{q1}, {q2}, {q3}]")
    
    # Retorna los valores clave para usarlos fuera de la función
    return media, desv_pob

# --- NUEVA FUNCIÓN ---
def estimar_rangos_normales(media, desv_pob, tabla):
    """
    Calcula y muestra los rangos de la Regla Empírica (68-95-99.7).
    """
    print("\nEstimación de Rangos (basado en la Regla Empírica de la Curva Normal):")
    
    # Calcula los rangos teóricos
    rango_1sigma = (media - desv_pob, media + desv_pob)
    rango_2sigma = (media - 2 * desv_pob, media + 2 * desv_pob)
    rango_3sigma = (media - 3 * desv_pob, media + 3 * desv_pob)
    
    print(f"  - Aprox. 68% de los datos deberían estar en: [{rango_1sigma[0]:.3f}, {rango_1sigma[1]:.3f}]")
    print(f"  - Aprox. 95% de los datos deberían estar en: [{rango_2sigma[0]:.3f}, {rango_2sigma[1]:.3f}]")
    print(f"  - Aprox. 99.7% de los datos deberían estar en: [{rango_3sigma[0]:.3f}, {rango_3sigma[1]:.3f}]")

    # Compara con el rango real de los datos
    rango_real = (tabla[0][0], tabla[-1][1])
    print(f"\n  El rango real de tus datos es: [{rango_real[0]:.3f}, {rango_real[1]:.3f}]")
    
    if rango_real[0] < rango_3sigma[0] or rango_real[1] > rango_3sigma[1]:
        print("  -> ¡Atención! El rango de tus datos excede las 3 desviaciones estándar.")
        print("     Esto sugiere la posible presencia de valores atípicos o que la distribución no es perfectamente normal.")
    else:
        print("  -> El rango de tus datos se encuentra dentro de los límites esperados por la Regla Empírica.")


# ==============================================================================
# MÓDULO 2: VISUALIZACIÓN DE DATOS
# ==============================================================================

def graficar_histograma_agrupado(tabla):
    """
    Genera un histograma a partir de una tabla de frecuencias.
    """
    limites_inf = np.array([row[0] for row in tabla])
    frecuencias = np.array([row[3] for row in tabla])
    ancho = tabla[0][1] - tabla[0][0] # Asume ancho constante

    plt.figure(figsize=(10, 6))
    plt.bar(limites_inf, frecuencias, width=ancho, align='edge', color='dodgerblue', edgecolor='black', alpha=0.7)
    
    plt.title('Histograma a partir de Datos Agrupados')
    plt.xlabel('Intervalos de Clase')
    plt.ylabel('Frecuencia Absoluta')
    
    todos_limites = np.append(limites_inf, tabla[-1][1])
    plt.xticks(todos_limites, rotation=45)
    
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.show()

# ==============================================================================
# MÓDULO 3: EJECUCIÓN DEL ANÁLISIS
# ==============================================================================

def main():
    """
    Función principal que ejecuta el análisis.
    Modifica la variable DATOS_AGRUPADOS para cambiar los datos de entrada.
    """
    # ------------------- CONFIGURACIÓN DE ENTRADA -------------------
    DATOS_AGRUPADOS = [
        [194, 196, 7],
        [196, 198, 13],
        [198, 200, 24],
        [200, 202, 14],
        [202, 204, 6],
    ]
    # ----------------------------------------------------------------

    print("="*58)
    print("      ANALIZADOR ESTADÍSTICO DESDE DATOS AGRUPADOS")
    print("="*58)

    if not DATOS_AGRUPADOS:
        print("Error: La lista de datos agrupados está vacía.")
        return

    tabla_completa = construir_tabla_completa(DATOS_AGRUPADOS)
    imprimir_tabla_completa(tabla_completa)
    
    # --- MODIFICACIÓN: La función ahora retorna la media y desv. estándar ---
    media_aprox, desv_pob_aprox = analizar_estadisticas_agrupadas(tabla_completa)
    
    # --- MODIFICACIÓN: Se llama a la nueva función de estimación ---
    if media_aprox is not None and desv_pob_aprox is not None:
        estimar_rangos_normales(media_aprox, desv_pob_aprox, tabla_completa)

    graficar_histograma_agrupado(tabla_completa)

if __name__ == "__main__":
    main()


