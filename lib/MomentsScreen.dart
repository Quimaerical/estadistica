import 'package:flutter/material.dart';
import 'Calculator.dart'; // Import MathUtils
import 'dart:math' as math;

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  final TextEditingController _dataCtrl = TextEditingController();
  String _result = "";

  void _calculateMoments() {
    String text = _dataCtrl.text.replaceAll(',', ' ');
    List<double> data = [];
    for (var item in text.split(' ')) {
      if (item.trim().isNotEmpty) {
        double? val = double.tryParse(item.trim());
        if (val != null) data.add(val);
      }
    }

    if (data.isEmpty) {
      setState(() => _result = "Ingrese datos válidos.");
      return;
    }

    int n = data.length;
    double mean = MathUtils.mean(data);

    // Raw Moments (about origin 0)
    double m1_raw = mean;
    double m2_raw = data.map((x) => math.pow(x, 2)).reduce((a, b) => a + b) / n;
    double m3_raw = data.map((x) => math.pow(x, 3)).reduce((a, b) => a + b) / n;
    double m4_raw = data.map((x) => math.pow(x, 4)).reduce((a, b) => a + b) / n;

    // Central Moments (about mean)
    double m2_central = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / n; // Variance (population)
    double m3_central = data.map((x) => math.pow(x - mean, 3)).reduce((a, b) => a + b) / n;
    double m4_central = data.map((x) => math.pow(x - mean, 4)).reduce((a, b) => a + b) / n;

    // Skewness and Kurtosis (Fisher-Pearson for sample, but here we use population definition for moments context usually, 
    // but MathUtils uses sample corrections. Let's stick to standard moment definitions here: g1 = m3 / m2^1.5)
    
    double skewness = m3_central / math.pow(m2_central, 1.5);
    double kurtosis = m4_central / math.pow(m2_central, 2) - 3; // Excess kurtosis

    setState(() {
      _result = """
Resultados (n=$n):

Momentos Respecto al Origen:
M1: ${m1_raw.toStringAsFixed(4)} (Media)
M2: ${m2_raw.toStringAsFixed(4)}
M3: ${m3_raw.toStringAsFixed(4)}
M4: ${m4_raw.toStringAsFixed(4)}

Momentos Centrales (Respecto a la Media):
μ2: ${m2_central.toStringAsFixed(4)} (Varianza Pob.)
μ3: ${m3_central.toStringAsFixed(4)}
μ4: ${m4_central.toStringAsFixed(4)}

Coeficientes de Forma:
Asimetría (g1): ${skewness.toStringAsFixed(4)}
Curtosis (g2): ${kurtosis.toStringAsFixed(4)} (Exceso)
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Momentos'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Ingrese los datos de la muestra:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dataCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Ej: 12, 15, 11, 19, 22 (separados por espacio o coma)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateMoments,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text("Calcular Momentos"),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigo.shade100)),
                child: Text(_result, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.indigo)),
              )
          ],
        ),
      ),
    );
  }
}
