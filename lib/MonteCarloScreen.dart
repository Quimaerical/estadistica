import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class MonteCarloScreen extends StatefulWidget {
  const MonteCarloScreen({super.key});

  @override
  State<MonteCarloScreen> createState() => _MonteCarloScreenState();
}

class _MonteCarloScreenState extends State<MonteCarloScreen> {
  String _distType = 'Uniforme';
  double _sampleSize = 30; // n
  double _numSamples = 1000; // k
  
  List<double> _means = [];
  List<BarChartGroupData> _bars = [];
  List<ScatterSpot> _scatterPoints = []; // For the strip plot
  final math.Random _rnd = math.Random();

  void _runCLT() {
    List<double> means = [];
    int n = _sampleSize.toInt();
    int k = _numSamples.toInt();

    // Data for Scatter Plot (Strip Plot)
    List<ScatterSpot> points = [];

    for (int i = 0; i < k; i++) {
        double sum = 0;
        for (int j = 0; j < n; j++) {
           if (_distType == 'Uniforme') {
             sum += _rnd.nextDouble(); // [0, 1]
           } else {
             // Exponential lambda=1: -ln(U)
             sum += -math.log(1 - _rnd.nextDouble());
           }
        }
        double mean = sum / n;
        means.add(mean);
        
        // Add random jitter to Y for better visibility
        // If we want to show them effectively, we can normalize Y between 0 and 1
        points.add(ScatterSpot(
          mean, 
          0.5 + (_rnd.nextDouble() - 0.5) * 0.8, // Jitter around 0.5
          dotPainter: FlDotCirclePainter(
            color: Colors.indigo.withOpacity(0.3),
            radius: 2,
            strokeWidth: 0,
          ),
        ));
    }
    
    // Create Histogram Bins
    means.sort();
    if (means.isEmpty) return;

    // Simple fixed bins
    int binCount = 20;
    double min = means.first;
    double max = means.last;
    double width = (max - min) / binCount;
    if (width == 0) width = 0.1;
    
    List<int> bins = List.filled(binCount, 0);
    for (var m in means) {
      int idx = ((m - min) / width).floor();
      if (idx >= binCount) idx = binCount - 1;
      bins[idx]++;
    }

    List<BarChartGroupData> bars = [];
    for (int i = 0; i < binCount; i++) {
      bars.add(BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: bins[i].toDouble(), color: Colors.indigo, width: 12, borderRadius: BorderRadius.circular(2))]
      ));
    }

    setState(() {
      _means = means;
      _bars = bars;
      _scatterPoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulación Monte Carlo (CLT)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CONTROLS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButton<String>(
                      value: _distType,
                      isExpanded: true,
                      items: const [
                         DropdownMenuItem(value: 'Uniforme', child: Text('Uniforme [0, 1]')),
                         DropdownMenuItem(value: 'Exponencial', child: Text('Exponencial (lambda=1)')),
                      ], 
                      onChanged: (v) => setState(() => _distType = v!)
                    ),
                    const SizedBox(height: 10),
                    Text("Tamaño de Muestra (n): ${_sampleSize.toInt()}"),
                    Slider(value: _sampleSize, min: 1, max: 100, divisions: 99, onChanged: (v) => setState(() => _sampleSize = v)),
                    const SizedBox(height: 5),
                    Text("Número de Muestras (k): ${_numSamples.toInt()}"),
                    Slider(value: _numSamples, min: 100, max: 5000, divisions: 49, onChanged: (v) => setState(() => _numSamples = v)),
                    ElevatedButton(onPressed: _runCLT, child: const Text("Simular Distribución de Medias")),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // CHARTS
            Expanded(
              child: _bars.isEmpty 
              ? const Center(child: Text("Presiona Simular para ver el histograma y datos"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // HISTOGRAM
                      const Text("Histograma de Frecuencias", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: BarChart(
                          BarChartData(
                            barGroups: _bars,
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide indices
                            ),
                          )
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // SCATTER / STRIP PLOT
                      const Text("Distribución de Puntos (Strip Plot)", style: TextStyle(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 5),
                      Container(
                        height: 150,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3))
                        ),
                        child: ScatterChart(
                          ScatterChartData(
                            scatterSpots: _scatterPoints,
                            minX: _means.first - 0.1,
                            maxX: _means.last + 0.1,
                            minY: 0,
                            maxY: 1,
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: false),
                            scatterTouchData: ScatterTouchData(enabled: false)
                          )
                        ),
                      ),
                       if (_means.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Nota: El gráfico inferior muestra cada media muestral individual como un punto, con una pequeña variación vertical aleatoria para evitar solapamiento.", 
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        )
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
