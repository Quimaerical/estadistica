import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

# ==============================================================================
# MÓDULO 1: CÁLCULOS Y TABLAS ESTADÍSTICAS
# ==============================================================================

def tabla_frecuencias_continua(datos, num_intervalos):
    """
    Construye una tabla de frecuencias para datos continuos usando np.histogram.
    """
    frecuencias, limites = np.histogram(datos, bins=num_intervalos)
    tabla = []
    for i in range(num_intervalos):
        lim_inf, lim_sup = limites[i], limites[i + 1]
        marca = (lim_inf + lim_sup) / 2
        tabla.append((lim_inf, lim_sup, marca, frecuencias[i]))
    return tabla

def imprimir_tabla_frecuencias_discreta(datos):
    """
    Imprime una tabla de frecuencias para datos discretos.
    """
    valores, frecuencias = np.unique(datos, return_counts=True)
    total = len(datos)
    f_rel = frecuencias / total
    f_acu = np.cumsum(frecuencias)
    fr_acu = np.cumsum(f_rel)
    print("\nTabla de frecuencias discretas:")
    print(f"{'Xi':>8} {'f':>5} {'fr':>7} {'F':>6} {'Fr':>8}")
    print("-" * 38)
    for v, f, fr, fa, fra in zip(valores, frecuencias, f_rel, f_acu, fr_acu):
        # Asegura que los valores discretos se impriman como enteros si es posible
        valor_str = f"{int(v):8d}" if v == int(v) else f"{v:8.2f}"
        print(f"{valor_str} {f:5d} {fr:7.3f} {fa:6d} {fra:8.3f}")

def imprimir_tabla_frecuencias_continua(tabla):
    """
    Imprime una tabla de frecuencias continuas (intervalos).
    """
    total = sum(f for _, _, _, f in tabla)
    if total == 0: return
    f_rel = [f / total for _, _, _, f in tabla]
    f_acu = np.cumsum([f for _, _, _, f in tabla])
    fr_acu = np.cumsum(f_rel)
    print("\nTabla de frecuencias continuas (intervalos):")
    print(f"{'Intervalo':>18} {'Marca':>8} {'f':>5} {'fr':>7} {'F':>6} {'Fr':>8}")
    print("-" * 60)
    for i, ((li, ls, m, f), fr, fa, fra) in enumerate(zip(tabla, f_rel, f_acu, fr_acu)):
        intervalo = f"[{li:.2f}, {ls:.2f}]" if i == len(tabla) - 1 else f"[{li:.2f}, {ls:.2f})"
        print(f"{intervalo:>18} {m:8.2f} {f:5d} {fr:7.3f} {fa:6d} {fra:8.3f}")

def calcular_cuartil_agrupado(tabla, cuartil):
    """
    Calcula el cuartil (1, 2, 3) para datos agrupados por interpolación.
    """
    n = sum(f for _, _, _, f in tabla)
    pos = cuartil * n / 4
    acumulada = 0
    for li, ls, _, f in tabla:
        F_ant = acumulada
        acumulada += f
        if acumulada >= pos:
            return li + ((pos - F_ant) / f) * (ls - li) if f > 0 else np.nan
    return np.nan

def estadisticas_discretas(datos):
    """
    Calcula e imprime un resumen completo de estadísticos para datos discretos.
    """
    media = np.mean(datos)
    moda = stats.mode(datos, keepdims=False)
    print("\nEstadísticas para Datos Discretos (No Agrupados):")
    print(f"  Media: {media:.4f}")
    print(f"  Mediana: {np.median(datos):.4f}")
    print(f"  Moda: {moda.mode:.4f} (frecuencia: {moda.count})")
    print("-" * 35)
    print(f"  Varianza Poblacional: {np.var(datos):.4f}")
    print(f"  Varianza Muestral: {np.var(datos, ddof=1):.4f}")
    print(f"  Desv. Estándar Poblacional: {np.std(datos):.4f}")
    print(f"  Desv. Estándar Muestral: {np.std(datos, ddof=1):.4f}")
    print(f"  Rango: {np.ptp(datos):.4f}")
    print(f"  Cuartiles (Q1, Q2, Q3): {np.percentile(datos, [25, 50, 75])}")
    print("-" * 35)
    print(f"  Asimetría (Fisher, muestral): {stats.skew(datos, bias=False):.4f}")
    print(f"  Curtosis (Fisher, exceso, muestral): {stats.kurtosis(datos, fisher=True, bias=False):.4f}")
    print("-" * 35)
    print(f"  2º Momento Simple (Poblacional): {np.mean(datos**2):.4f}")
    print(f"  2º Momento Central (Poblacional): {np.mean((datos - media)**2):.4f}")
    a = 1 #valor a cambiar, valor de Z
    normal_estandar_Z(a)

def estadisticas_continuas(tabla):
    """
    Calcula e imprime un resumen completo de estadísticos para datos agrupados.
    """
    marcas = np.array([m for _, _, m, _ in tabla])
    frecuencias = np.array([f for _, _, _, f in tabla])
    n = np.sum(frecuencias)
    if n == 0: return
    
    media = np.average(marcas, weights=frecuencias)
    var_pob = np.average((marcas - media)**2, weights=frecuencias)
    var_mue = var_pob * (n / (n - 1)) if n > 1 else np.nan
    desv_pob = np.sqrt(var_pob)
    desv_mue = np.sqrt(var_mue) if n > 1 else np.nan
    
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
    print(f"  Asimetría (poblacional): {asimetria:.4f}")
    print(f"  Curtosis (exceso, poblacional): {curtosis:.4f}")
    q1, q2, q3 = [round(calcular_cuartil_agrupado(tabla, q), 4) for q in [1, 2, 3]]
    print(f"  Cuartiles (Q1, Q2, Q3) por interpolación: [{q1}, {q2}, {q3}]")
    a = 1 #valor a cambiar, valor de Z
    normal_estandar_Z(a)

# ==============================================================================
# MÓDULO 2: VISUALIZACIÓN DE DATOS
# ==============================================================================

def graficar_distribucion_discreta(datos):
    """
    Genera un gráfico de barras para la distribución de datos discretos.
    """
    valores, frecuencias = np.unique(datos, return_counts=True)
    plt.figure(figsize=(10, 6))
    plt.bar(valores, frecuencias, color='skyblue', edgecolor='black', width=0.6)
    plt.title('Distribución de Frecuencias para Datos Discretos')
    plt.xlabel('Valores'); plt.ylabel('Frecuencia')
    # Asegura que los ticks sean enteros si los datos lo son.
    if np.all(np.mod(valores, 1) == 0):
        plt.xticks(np.arange(min(valores), max(valores)+1, 1))
    else:
        plt.xticks(valores)
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.show()

def graficar_distribucion_continua(datos):
    """
    Genera un histograma para la distribución de datos continuos.
    """
    num_intervalos = int(np.ceil(1 + 3.322 * np.log10(len(datos))))
    plt.figure(figsize=(10, 6))
    plt.hist(datos, bins=num_intervalos, color='lightgreen', edgecolor='black')
    plt.title('Histograma de Frecuencias para Datos Continuos')
    plt.xlabel('Valores'); plt.ylabel('Frecuencia')
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.show()

def normal_estandar_Z(a):
	
	p_menor = stats.norm.cdf(a)
	p_mayor = 1 - p_menor
	
	print(f"\nDistribucion Normal Estándar N(0,1)  ")
	print(f"P(X < {a}) = {p_menor:.6f}")
	print(f"P(X > {a}) = {p_mayor:.6f}")

# ==============================================================================
# MÓDULO 3: EJECUCIÓN DEL ANÁLISIS
# ==============================================================================

def main():
    """
    Función principal que ejecuta el análisis estadístico.
    Modifica las variables en la sección de CONFIGURACIÓN para cambiar los datos.
    """
    # ------------------- CONFIGURACIÓN DEL ANÁLISIS -------------------
    # 1. Elige el tipo de análisis: 'discreto' o 'continuo'
    TIPO_DE_ANALISIS = 'continuo'

    #    Puedes pegar aquí cualquier lista de números.
    DATOS = [
       212.8, 256.3, 278.1, 298.3, 213.7, 257.0, 278.2, 298.4, 214.2, 258.6, 279.1, 299.3, 217.7, 259.1, 279.6, 300.8, 219.8, 259.2, 279.9, 300.9, 220.0, 261.6, 283.0, 301.1, 224.5, 262.5, 283.1, 301.7, 225.3, 265.2, 283.6, 302.5, 227.8, 267.0, 284.9, 304.8, 230.8, 267.9, 285.0, 306.6, 232.7, 268.1, 286.0, 306.8, 233.8, 268.3, 286.3, 310.5, 236.1, 269.1, 286.6, 310.6, 237.7, 269.5, 286.6, 310.9, 239.7, 270.1, 286.8, 310.9, 241.0, 271.2, 286.9, 312.4, 243.3, 271.8, 289.3, 313.8, 244.7, 272.7, 290.4, 316.0, 246.1, 273.3, 291.0, 316.9, 249.8, 274.8, 291.2 ,320.2, 250.9, 275.1, 293.8, 321.5, 252.0, 275.2 ,296.1, 332.2, 252.7, 275.8, 296.1, 335.7, 254.9, 276.8 ,297.1, 342.4, 255.4, 277.6, 298.2, 353.6
    ]
    # --------------------------------------------------------------------

    print("="*53)
    print("      ANALIZADOR ESTADÍSTICO DIRECTO Y VISUAL")
    print("="*53)
    print(f"Tipo de análisis seleccionado: '{TIPO_DE_ANALISIS}'")
    print(f"Número de datos a analizar: {len(DATOS)}")

    if TIPO_DE_ANALISIS == 'discreto':
        datos_np = np.array(DATOS)
        imprimir_tabla_frecuencias_discreta(datos_np)
        estadisticas_discretas(datos_np)
        graficar_distribucion_discreta(datos_np)
    
    elif TIPO_DE_ANALISIS == 'continuo':
        datos_np = np.array(DATOS)
        num_intervalos = int(np.ceil(1 + 3.322 * np.log10(len(datos_np))))
        tabla_cont = tabla_frecuencias_continua(datos_np, num_intervalos)
        imprimir_tabla_frecuencias_continua(tabla_cont)
        estadisticas_continuas(tabla_cont)
        graficar_distribucion_continua(datos_np)
    
    else:
        print("\nError: El TIPO_DE_ANALISIS debe ser 'discreto' o 'continuo'.")
        print("Por favor, corrige la variable en la sección de configuración.")

if __name__ == "__main__":
    main()

