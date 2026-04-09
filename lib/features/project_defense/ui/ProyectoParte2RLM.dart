import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import '../../../services/stat_engine_ffi.dart';

class ProyectoParte2RLM extends StatefulWidget {
  const ProyectoParte2RLM({super.key});

  @override
  State<ProyectoParte2RLM> createState() => _ProyectoParte2RLMState();
}

class _ProyectoParte2RLMState extends State<ProyectoParte2RLM> {
  // Datos Crudos Telemetría
  final List<double> x1 = [3.3, 4.4, 3.9, 5.9, 4.6, 5.2, 4.0, 4.7, 4.5, 3.7, 4.6, 4.7, 3.9, 4.6, 5.1, 5.0, 4.8, 5.3, 3.9, 3.4];
  final List<double> x2 = [2.8, 4.9, 5.3, 2.6, 5.1, 3.2, 4.0, 4.5, 4.1, 3.6, 4.6, 3.5, 4.6, 4.0, 3.6, 4.4, 4.4, 3.5, 3.8, 3.8];
  final List<double> x3 = [3.1, 3.5, 4.8, 3.1, 5.0, 3.3, 3.3, 3.5, 3.7, 3.3, 3.6, 3.5, 3.6, 3.4, 3.3, 3.6, 3.4, 3.6, 3.4, 3.4];
  final List<double> x4 = [4.1, 3.9, 4.7, 3.6, 4.1, 4.3, 4.0, 3.8, 3.6, 3.6, 3.6, 3.7, 4.1, 3.6, 4.0, 3.7, 3.6, 3.7, 4.0, 3.4];
  final List<double> y =  [9.8, 12.6, 11.9, 13.1, 13.3, 13.5, 10.1, 13.1, 10.7, 11.0, 13.0, 11.6, 12.0, 11.4, 12.2, 12.8, 12.4, 13.2, 10.6, 7.9];

  // Sliders reactivos
  double inputX1 = 5.1;
  double inputX2 = 4.7;
  double inputX3 = 4.8;
  double inputX4 = 4.0;
  
  // Resultados del modelo
  List<double> betas = [0,0,0,0,0];
  double r2 = 0.0;
  double f_value = 0.0;
  double p_value = 0.0;
  
  List<double> seBetas = [0,0,0,0,0];
  List<double> pValBetas = [0,0,0,0,0];
  
  double predictedY = 0.0;
  bool isReady = false;

  String _fmt(double? value) {
    if (value == null) return '-';
    if (value == 0) return '0.000000';
    if (value.abs() < 0.0001 || value.abs() > 10000) {
      String expStr = value.toStringAsExponential(6);
      List<String> parts = expStr.split('e');
      if (parts.length == 2) {
        String numPart = parts[0];
        String expPart = parts[1].startsWith('+') ? parts[1].substring(1) : parts[1];
        return '10^$expPart x ($numPart)';
      }
      return expStr;
    }
    return value.toStringAsFixed(6);
  }

  Pointer<Double> _toListPointer(List<double> list) {
    final ptr = calloc<Double>(list.length);
    for (int i = 0; i < list.length; i++) {
      ptr[i] = list[i];
    }
    return ptr;
  }

  void _trainModel() {
    final engine = StatEngineFFI();

    final px1 = _toListPointer(x1);
    final px2 = _toListPointer(x2);
    final px3 = _toListPointer(x3);
    final px4 = _toListPointer(x4);
    final py = _toListPointer(y);

    final outBeta = calloc<Double>(5);
    final outMetrics = calloc<Double>(21);

    engine.statRlmFit(px1, px2, px3, px4, py, 20, outBeta, outMetrics);

    setState(() {
      for(int i=0; i<5; i++) betas[i] = outBeta[i];
      r2 = outMetrics[0];
      f_value = outMetrics[1];
      p_value = outMetrics[2];
      
      for(int i=0; i<5; i++) {
        seBetas[i] = outMetrics[6 + i];
        pValBetas[i] = outMetrics[16 + i];
      }
      
      isReady = true;
    });

    _predict();

    calloc.free(px1);
    calloc.free(px2);
    calloc.free(px3);
    calloc.free(px4);
    calloc.free(py);
    calloc.free(outBeta);
    calloc.free(outMetrics);
  }

  void _predict() {
    double base = betas[0];
    double bx1 = betas[1] * inputX1;
    double bx2 = betas[2] * inputX2;
    double bx3 = betas[3] * inputX3;
    double bx4 = betas[4] * inputX4;
    setState(() {
      predictedY = base + bx1 + bx2 + bx3 + bx4;
    });
  }

  @override
  void initState() {
    super.initState();
    _trainModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parte II - Predicción CPU RLM', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: !isReady
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildResultsCard(),
                  const SizedBox(height: 16),
                  _buildExamAnswersCard(),
                  const SizedBox(height: 16),
                  _buildInteractivePredictor(),
                ],
              ),
            ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajuste del Modelo OLS (Paso a Paso)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
            const Divider(),
            const Text('Paso 1: Planteamiento de Ecuación', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Modelo: Y = β₀ + β₁X₁ + β₂X₂ + β₃X₃ + β₄X₄ + ε'),
            const SizedBox(height: 12),

            const Text('Paso 2: Coeficientes Calculados (β) por Mínimos Cuadrados', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('β₀ (Intercepto) = ${_fmt(betas[0])}'),
            Text('β₁ (Peticiones) = ${_fmt(betas[1])}'),
            Text('β₂ (Trama) = ${_fmt(betas[2])}'),
            Text('β₃ (Latencia BD) = ${_fmt(betas[3])}'),
            Text('β₄ (Memoria) = ${_fmt(betas[4])}'),
            const SizedBox(height: 12),

            const Text('Paso 3: Ecuación Resultante', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Y = ${_fmt(betas[0])} + '
                '${_fmt(betas[1])}X₁ + '
                '${_fmt(betas[2])}X₂ + '
                '${_fmt(betas[3])}X₃ + '
                '${_fmt(betas[4])}X₄',
                style: const TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),

            const Text('Paso 4: Análisis de Varianza del Modelo', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Estadístico F: ${_fmt(f_value)}'),
            Text('P-Valor F-Test: ${_fmt(p_value)} (Si < 0.05, el modelo es linealmente significativo)'),
            const SizedBox(height: 12),

            const Text('Paso 5: Bondad de Ajuste', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('R²: ${_fmt(r2 * 100)}%', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary)),
            Text('El modelo explica el ${_fmt(r2 * 100)}% de toda la variabilidad en el consumo histórico de CPU de los servidores.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePredictor() {
    return Card(
      elevation: 8,
      shadowColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Simulador en Tiempo Real',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 16),
            _sliderInput('X1 (Peticiones)', inputX1, 2.0, 7.0, (val) {
              setState(() => inputX1 = val);
              _predict();
            }),
            _sliderInput('X2 (Tamaño Trama)', inputX2, 2.0, 7.0, (val) {
              setState(() => inputX2 = val);
              _predict();
            }),
            _sliderInput('X3 (Latencia Bóveda)', inputX3, 2.0, 7.0, (val) {
              setState(() => inputX3 = val);
              _predict();
            }),
            _sliderInput('X4 (Memoria Microserv.)', inputX4, 2.0, 7.0, (val) {
              setState(() => inputX4 = val);
              _predict();
            }),
            const Divider(height: 32, thickness: 2),
            const Text('CPU Estimado Predicho (Y)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            Text(
              '${_fmt(predictedY)} %',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderInput(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(_fmt(value), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Colors.teal,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildExamAnswersCard() {
    double tCrit = 2.131450; // Para 95% de confianza, DF = 20-5 = 15

    String _ic(int i) {
      double margin = tCrit * seBetas[i];
      return '[${_fmt(betas[i] - margin)} , ${_fmt(betas[i] + margin)}]';
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Respuestas Oficiales para Examen (Parte II)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const Divider(),
            const Text('5) Intervalos de Confianza (95%) para los parámetros β_i', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('β₀: ${_ic(0)}'),
            Text('β₁: ${_ic(1)}'),
            Text('β₂: ${_ic(2)}'),
            Text('β₃: ${_ic(3)}'),
            Text('β₄: ${_ic(4)}\n'),
            
            const Text('6) Pruebe con 5% de significancia si el aporte de cada variable Xi es significativo', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('X₁ (Peticiones): p-valor = ${_fmt(pValBetas[1])} -> ${pValBetas[1] < 0.05 ? "Significativa" : "NO Significativa"}'),
            Text('X₂ (Trama): p-valor = ${_fmt(pValBetas[2])} -> ${pValBetas[2] < 0.05 ? "Significativa" : "NO Significativa"}'),
            Text('X₃ (Latencia): p-valor = ${_fmt(pValBetas[3])} -> ${pValBetas[3] < 0.05 ? "Significativa" : "NO Significativa"}'),
            Text('X₄ (Memoria): p-valor = ${_fmt(pValBetas[4])} -> ${pValBetas[4] < 0.05 ? "Significativa" : "NO Significativa"}\n'),

            const Text('7) ¿Cuál modelo recomendaría usted? Justifique.', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Se recomienda un modelo reducido que excluya las variables X2 y X3 en caso de no ser significativas, o retenga los predictores cuyo p-valor sea estrictamente < 0.05 (evaluables desde la métrica anterior) para evitar sobreajuste y estabilizar la predicción de rendimiento de CPU.'),
          ],
        ),
      ),
    );
  }
}
