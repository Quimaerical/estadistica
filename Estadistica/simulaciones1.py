import numpy as np
import matplotlib.pyplot as plt
import os

# --- 1. Configuración ---
SAMPLES = 10          # Muestra pequeña
MU_NORM = 70.0
SIGMA_NORM = 25.0
LAMBDA_EXP = 1.0
SCALE_EXP = 1.0 / LAMBDA_EXP

FILENAME = "resultados_simulacion.txt"

class SimulationEngine:
    @staticmethod
    def run_normal(n, mu, sigma):
        return np.random.normal(mu, sigma, n)

    @staticmethod
    def run_exponential(n, scale):
        return np.random.exponential(scale, n)

    @staticmethod
    def get_stats(data):
        return {
            "Media": np.mean(data),
            "Desv": np.std(data, ddof=1), # Muestral
            "Min": np.min(data),
            "Max": np.max(data),
            "Data": data
        }

def save_results_to_file(s_norm, s_exp):
    """Guarda los resultados en un archivo de texto persistente"""
    with open(FILENAME, "w", encoding='utf-8') as f:
        f.write("=== REPORTE DE SIMULACIÓN (Montecarlo) ===\n")
        f.write(f"Muestras por experimento: {SAMPLES}\n\n")
        
        f.write(f"--- DISTRIBUCIÓN NORMAL (Teórico: Mean=70) ---\n")
        f.write(f"Datos: {np.round(s_norm['Data'], 2)}\n")
        f.write(f"Media Muestral: {s_norm['Media']:.4f}\n")
        f.write(f"Desv. Std:      {s_norm['Desv']:.4f}\n")
        f.write(f"Rango:          {s_norm['Min']:.2f} a {s_norm['Max']:.2f}\n\n")
        
        f.write(f"--- DISTRIBUCIÓN EXPONENCIAL (Teórico: Lambda=1) ---\n")
        f.write(f"Datos: {np.round(s_exp['Data'], 2)}\n")
        f.write(f"Media Muestral: {s_exp['Media']:.4f}\n")
        f.write(f"Lambda Calc:    {1.0/s_exp['Media']:.4f}\n")
        
    print(f"\n[SISTEMA] Datos guardados exitosamente en: {FILENAME}")

def plot_with_stats(d_norm, d_exp, s_norm, s_exp):
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 10))
    plt.subplots_adjust(hspace=0.5)

    # --- GRÁFICO 1: NORMAL ---
    ax1.hist(d_norm, bins=5, density=True, alpha=0.6, color='skyblue', edgecolor='black')
    
    # Curva Teórica
    x_plot = np.linspace(MU_NORM - 3*SIGMA_NORM, MU_NORM + 3*SIGMA_NORM, 100)
    pdf_norm = (1/(SIGMA_NORM * np.sqrt(2 * np.pi))) * np.exp(-0.5 * ((x_plot - MU_NORM) / SIGMA_NORM)**2)
    ax1.plot(x_plot, pdf_norm, 'r--', linewidth=2)
    
    # **ESTADÍSTICOS EN PANTALLA**
    stats_text_norm = (f"$\\mu$ Teórica: {MU_NORM}\n"
                       f"$\\bar{{x}}$ Obtenida: {s_norm['Media']:.2f}\n"
                       f"$\\sigma$ Obtenida: {s_norm['Desv']:.2f}")
    # Caja de texto en la esquina superior derecha del gráfico
    ax1.text(0.95, 0.95, stats_text_norm, transform=ax1.transAxes, fontsize=10,
             verticalalignment='top', horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    ax1.set_title(f'Normal (N={SAMPLES})')

    # --- GRÁFICO 2: EXPONENCIAL ---
    ax2.hist(d_exp, bins=5, density=True, alpha=0.6, color='lightgreen', edgecolor='black')
    
    # Curva Teórica
    x_exp = np.linspace(0, max(d_exp)+1, 100)
    pdf_exp = LAMBDA_EXP * np.exp(-LAMBDA_EXP * x_exp)
    ax2.plot(x_exp, pdf_exp, 'g--', linewidth=2)

    # **ESTADÍSTICOS EN PANTALLA**
    stats_text_exp = (f"$\\lambda$ Teórico: {LAMBDA_EXP}\n"
                      f"$\\bar{{x}}$ Obtenida: {s_exp['Media']:.2f}\n"
                      f"$\\lambda$ Calc: {(1/s_exp['Media']):.2f}")
    
    ax2.text(0.95, 0.95, stats_text_exp, transform=ax2.transAxes, fontsize=10,
             verticalalignment='top', horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    ax2.set_title(f'Exponencial (N={SAMPLES})')

    print("[SISTEMA] Generando gráficos con etiquetas...")
    plt.show()

# --- EJECUCIÓN ---

# 1. Generar
data_n = SimulationEngine.run_normal(SAMPLES, MU_NORM, SIGMA_NORM)
data_e = SimulationEngine.run_exponential(SAMPLES, SCALE_EXP)

# 2. Calcular
stats_n = SimulationEngine.get_stats(data_n)
stats_e = SimulationEngine.get_stats(data_e)

# 3. GUARDAR EN ARCHIVO (Persistencia 1)
save_results_to_file(stats_n, stats_e)

# 4. GRAFICAR CON DATOS (Persistencia 2)
plot_with_stats(data_n, data_e, stats_n, stats_e)