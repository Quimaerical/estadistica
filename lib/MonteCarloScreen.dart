import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'Calculator.dart';

class MonteCarloScreen extends StatefulWidget {
  const MonteCarloScreen({super.key});

  @override
  State<MonteCarloScreen> createState() => _MonteCarloScreenState();
}

class _MonteCarloScreenState extends State<MonteCarloScreen> {
  // Inputs
  final TextEditingController _nCtrl = TextEditingController(text: "1000");
  final TextEditingController _muCtrl = TextEditingController(text: "70");
  final TextEditingController _sigmaCtrl = TextEditingController(text: "25");
  final TextEditingController _lambdaCtrl = TextEditingController(text: "1.0");

  // Results
  List<double> _normData = [];
  List<double> _expData = [];
  
  Map<String, dynamic>? _normStats;
  Map<String, dynamic>? _expStats;
  
  bool _hasRun = false;

  void _runSimulation() {
    int n = int.tryParse(_nCtrl.text) ?? 100;
    double mu = double.tryParse(_muCtrl.text) ?? 70;
    double sigma = double.tryParse(_sigmaCtrl.text) ?? 25;
    double lambda = double.tryParse(_lambdaCtrl.text) ?? 1.0;

    // Generate
    List<double> norm = MathUtils.generateNormal(n, mu, sigma);
    List<double> exp = MathUtils.generateExponential(n, lambda);

    // Calculate Stats
    setState(() {
      _normData = norm;
      _expData = exp;
      _normStats = _calculateStats(norm);
      _expStats = _calculateStats(exp);
      _hasRun = true;
    });
  }

  Map<String, dynamic> _calculateStats(List<double> data) {
    if (data.isEmpty) return {};
    double mean = MathUtils.mean(data);
    double std = MathUtils.stdDev(data, isSample: true);
    double min = data.reduce(math.min);
    double max = data.reduce(math.max);
    return {
      "mean": mean,
      "std": std,
      "min": min,
      "max": max,
      "count": data.length
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulación Monte Carlo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              child: const Text("EJECUTAR SIMULACIÓN"),
            ),
            if (_hasRun) ...[
              const SizedBox(height: 20),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text("Resultados", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              
              const SizedBox(height: 20),
              _buildReportCard("Distribución Normal", _normStats!, isNormal: true),
              const SizedBox(height: 20),
              _buildChart("Histograma Normal", _normData, Colors.blue),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              
              _buildReportCard("Distribución Exponencial", _expStats!, isNormal: false),
              const SizedBox(height: 20),
              _buildChart("Histograma Exponencial", _expData, Colors.green),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Configuración", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nCtrl,
              decoration: const InputDecoration(labelText: "Número de muestras (N)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _muCtrl, decoration: const InputDecoration(labelText: "Media (Normal)", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _sigmaCtrl, decoration: const InputDecoration(labelText: "Desv. Std (Normal)", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lambdaCtrl,
              decoration: const InputDecoration(labelText: "Lambda (Exponencial)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, Map<String, dynamic> stats, {required bool isNormal}) {
    double theoreticalMean = isNormal 
        ? (double.tryParse(_muCtrl.text) ?? 0) 
        : 1.0 / (double.tryParse(_lambdaCtrl.text) ?? 1);
        
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 10),
            _row("Media Muestral:", stats['mean'].toStringAsFixed(4)),
            _row("Media Teórica:", theoreticalMean.toStringAsFixed(4)),
            if (isNormal) _row("Desv. Std:", stats['std'].toStringAsFixed(4)),
            if (!isNormal) _row("Lambda Calculado:", (1/stats['mean']).toStringAsFixed(4)),
            _row("Rango:", "${stats['min'].toStringAsFixed(2)} - ${stats['max'].toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildChart(String title, List<double> data, Color color) {
    // Simple binning
    if (data.isEmpty) return const SizedBox();
    
    double min = data.reduce(math.min);
    double max = data.reduce(math.max);
    int bins = 15;
    double binWidth = (max - min) / bins;
    
    List<int> counts = List.filled(bins, 0);
    for (var x in data) {
      int idx = ((x - min) / binWidth).floor();
      if (idx >= bins) idx = bins - 1;
      counts[idx]++;
    }
    
    // Normalize to density-like or just freq
    double maxY = counts.reduce(math.max).toDouble();

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < bins; i++) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: counts[i].toDouble(),
                color: color.withOpacity(0.7),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ]
          )
        );
    }

    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY * 1.1,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                       int idx = val.toInt();
                       if (idx < 0 || idx >= bins) return const Text("");
                       if (idx % 3 != 0) return const Text(""); // Skip some labels
                       double binCenter = min + (idx + 0.5) * binWidth;
                       return Text(binCenter.toStringAsFixed(1), style: const TextStyle(fontSize: 10));
                    }
                  )
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
              barGroups: barGroups,
            )
          ),
        ),
      ],
    );
  }
}
