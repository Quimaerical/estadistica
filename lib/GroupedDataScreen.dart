import 'package:flutter/material.dart';
import 'Calculator.dart'; // Import MathUtils
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class GroupedDataScreen extends StatefulWidget {
  const GroupedDataScreen({super.key});

  @override
  State<GroupedDataScreen> createState() => _GroupedDataScreenState();
}

class _GroupedDataScreenState extends State<GroupedDataScreen> {
  final TextEditingController _minCtrl = TextEditingController();
  final TextEditingController _maxCtrl = TextEditingController();
  final TextEditingController _freqCtrl = TextEditingController();

  final List<Map<String, dynamic>> _intervals = [];
  
  String _result = "";
  // State variables for visualization
  List<double> _qs = [0, 0, 0];
  double _mean = 0;
  double _stdDev = 0;


  void _addInterval() {
    double? min = double.tryParse(_minCtrl.text);
    double? max = double.tryParse(_maxCtrl.text);
    int? freq = int.tryParse(_freqCtrl.text);

    if (min != null && max != null && freq != null && freq > 0 && min < max) {
      setState(() {
        _intervals.add({
          'min': min,
          'max': max,
          'freq': freq,
          'mid': (min + max) / 2,
        });
        _intervals.sort((a, b) => a['min'].compareTo(b['min']));
      });
      _minCtrl.clear();
      _maxCtrl.clear();
      _freqCtrl.clear();
      _calculateStats();
    }
  }

  void _calculateStats() {
    if (_intervals.isEmpty) {
      setState(() => _result = "");
      return;
    }

    int n = _intervals.fold(0, (sum, item) => sum + (item['freq'] as int));
    double sumFx = _intervals.fold(0.0, (sum, item) => sum + (item['mid'] * item['freq']));
    double mean = sumFx / n;
    _mean = mean; // Update state

    double sumFx2 = _intervals.fold(0.0, (sum, item) => sum + (item['freq'] * math.pow(item['mid'] - mean, 2)));
    double variance = sumFx2 / (n - 1);
    double stdDev = math.sqrt(variance);
    _stdDev = stdDev; // Update state
    
    // Asimetría and Kurtosis for Grouped Data
    // We treat 'intervals' as the structure needed for MathUtils.skewnessGrouped
    double skew = MathUtils.skewnessGrouped(_intervals, mean, stdDev);
    double kurt = MathUtils.kurtosisGrouped(_intervals, mean, stdDev);
    
    // Empirical Rule Check
    double rangeMin = _intervals.first['min'];
    double rangeMax = _intervals.last['max'];
    
    String ruleCheck = "";
    double limitLow = mean - 3 * stdDev;
    double limitHigh = mean + 3 * stdDev;
    
    if (rangeMin < limitLow || rangeMax > limitHigh) {
      ruleCheck = "Atención: El rango de datos excede 3σ. Posibles valores atípicos.";
    } else {
      ruleCheck = "El rango de datos está dentro de los límites esperados (3σ).";
    }

    // Quartiles (Interpolation)
    // Position: Qk = k(n/4)
    // L_i + ((Pos - F_prev) / f_i) * c
    
    List<double> qs = [];
    List<int> cumFreq = [];
    int running = 0;
    for (var item in _intervals) {
      running += (item['freq'] as int);
      cumFreq.add(running);
    }

    for (int k = 1; k <= 3; k++) {
      double pos = k * n / 4;
      int idx = -1;
      for (int i = 0; i < cumFreq.length; i++) {
        if (cumFreq[i] >= pos) {
          idx = i;
          break;
        }
      }
      
      if (idx != -1) {
        double L = _intervals[idx]['min'];
        double c = _intervals[idx]['max'] - _intervals[idx]['min'];
        double Fprev = (idx == 0) ? 0 : cumFreq[idx - 1].toDouble();
        double f = (_intervals[idx]['freq'] as int).toDouble();
        
        double q = L + ((pos - Fprev) / f) * c;
        qs.add(q);
      } else {
        qs.add(0);
      }
    }
    _qs = qs; // Update state

    setState(() {
      _result = """
Resultados (Datos Agrupados):
Total Datos (n): $n
Media: ${mean.toStringAsFixed(4)}
Varianza: ${variance.toStringAsFixed(4)}
Desviación Estándar: ${stdDev.toStringAsFixed(4)}

Cuartiles (Interpolados):
Q1: ${qs[0].toStringAsFixed(4)}
Q2 (Mediana): ${qs[1].toStringAsFixed(4)}
Q3: ${qs[2].toStringAsFixed(4)}

Coeficientes:
Asimetría: ${skew.toStringAsFixed(4)}
Curtosis: ${kurt.toStringAsFixed(4)}

Regla Empírica [μ ± 3σ]:
[${limitLow.toStringAsFixed(2)}, ${limitHigh.toStringAsFixed(2)}]
$ruleCheck
""";
    });
  }

  void _clearData() {
    setState(() {
      _intervals.clear();
      _result = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis Datos Agrupados'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Agregar Intervalo", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _minCtrl, decoration: const InputDecoration(labelText: "Límite Inf."), keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _maxCtrl, decoration: const InputDecoration(labelText: "Límite Sup."), keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _freqCtrl, decoration: const InputDecoration(labelText: "Frecuencia"), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: _clearData, child: const Text("Limpiar Todo", style: TextStyle(color: Colors.red))),
                        ElevatedButton(onPressed: _addInterval, child: const Text("Agregar")),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_intervals.isNotEmpty) ...[
              const Text("Tabla de Frecuencias", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Intervalo')),
                  DataColumn(label: Text('Marca (xi)')),
                  DataColumn(label: Text('Freq (fi)')),
                ],
                rows: _intervals.map((e) => DataRow(cells: [
                  DataCell(Text("[${e['min']} - ${e['max']})")),
                  DataCell(Text(e['mid'].toString())),
                  DataCell(Text(e['freq'].toString())),
                ])).toList(),
              ),
              const SizedBox(height: 20),
              if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(_result, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ),
              const SizedBox(height: 20),
              // BOX PLOT
              const Text("Diagrama de Vela (Caja y Bigotes)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3))
                ),
                child: CustomPaint(
                    painter: BoxPlotPainter(
                      min: _intervals.isEmpty ? 0 : _intervals.first['min'],
                      q1: _qs.isNotEmpty ? _qs[0] : 0,
                      median: _qs.isNotEmpty ? _qs[1] : 0,
                      q3: _qs.isNotEmpty ? _qs[2] : 0,
                      max: _intervals.isEmpty ? 0 : _intervals.last['max'],
                      isDark: Theme.of(context).brightness == Brightness.dark
                    ),
                ),
              ),
              const SizedBox(height: 20),

              // HISTOGRAM & CURVE
              const Text("Histograma y Curva Normal", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.white, 
                  borderRadius: BorderRadius.circular(12)
                ),
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _intervals.isEmpty ? 10 : _intervals.map((e) => (e['freq'] as int).toDouble()).reduce(math.max) * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int idx = value.toInt();
                                if (idx >= 0 && idx < _intervals.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(_intervals[idx]['mid'].toString(), style: const TextStyle(fontSize: 10)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _intervals.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(toY: (e.value['freq'] as int).toDouble(), color: Colors.indigo.withOpacity(0.5), width: 20, borderRadius: BorderRadius.circular(4))
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    // Normal Curve Overlay
                    if (_intervals.isNotEmpty && _stdDev > 0)
                      LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getNormalCurveSpots(_mean, _stdDev, _intervals),
                              isCurved: true,
                              color: Colors.redAccent,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            )
                          ],
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          // Align Min/MaxX to Indices roughly
                          minX: -0.5,
                          maxX: _intervals.length - 0.5,
                          minY: 0,
                          maxY: _intervals.map((e) => (e['freq'] as int).toDouble()).reduce(math.max) * 1.2,
                        )
                      ),
                  ]
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
  List<FlSpot> _getNormalCurveSpots(double mean, double stdDev, List<Map<String, dynamic>> intervals) {
    if (stdDev == 0 || intervals.isEmpty) return [];
    
    double firstStart = intervals.first['min'];
    double lastEnd = intervals.last['max'];
    double totalWidth = lastEnd - firstStart;
    
    double n = intervals.fold(0.0, (sum, item) => sum + (item['freq'] as int));
    List<FlSpot> spots = [];
    double step = totalWidth / 50;
    
    for (double x = firstStart; x <= lastEnd; x += step) {
      double pdf = MathUtils.pdfNormal(x, mean, stdDev);
      double w = totalWidth / intervals.length; 
      double y = pdf * n * w;
      
      spots.add(FlSpot((x - firstStart) / w - 0.5, y)); 
    }
    return spots;
  }
}
