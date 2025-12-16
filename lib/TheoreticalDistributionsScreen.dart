import 'package:flutter/material.dart';
import 'dart:math' as math;

class TheoreticalDistributionsScreen extends StatefulWidget {
  const TheoreticalDistributionsScreen({super.key});

  @override
  State<TheoreticalDistributionsScreen> createState() => _TheoreticalDistributionsScreenState();
}

class _TheoreticalDistributionsScreenState extends State<TheoreticalDistributionsScreen> {
  String _selectedDist = 'Normal';
  final TextEditingController _p1Ctrl = TextEditingController();
  final TextEditingController _p2Ctrl = TextEditingController();
  
  String _result = "";

  // Formulas logic
  void _calculate() {
    double? p1 = double.tryParse(_p1Ctrl.text);
    double? p2 = double.tryParse(_p2Ctrl.text);
    
    String output = "";
    
    try {
      switch (_selectedDist) {
        case 'Normal':
          // p1=mu, p2=sigma
          double mu = p1 ?? 0;
          double sigma = p2 ?? 1;
          output = """
Resultados (Normal):
Media: ${mu.toStringAsFixed(4)}
Varianza: ${(sigma * sigma).toStringAsFixed(4)}
Asimetría: 0.0000
Curtosis (Exceso): 0.0000
""";
          break;
          
        case 'Binomial':
          // p1=n, p2=p
          double n = p1 ?? 10;
          double p = p2 ?? 0.5;
          if (p < 0 || p > 1) throw Exception("Probabilidad p debe estar entre 0 y 1");
          if (n < 0 || n % 1 != 0) throw Exception("n debe ser entero positivo");
          
          double mean = n * p;
          double var_ = n * p * (1 - p);
          double skew = (1 - 2 * p) / math.sqrt(var_);
          double kurt = (1 - 6 * p * (1 - p)) / var_;
          
           output = """
Resultados (Binomial):
Media: ${mean.toStringAsFixed(4)}
Varianza: ${var_.toStringAsFixed(4)}
Asimetría: ${skew.toStringAsFixed(4)}
Curtosis (Exceso): ${kurt.toStringAsFixed(4)}
""";
          break;
        
        case 'Poisson':
          // p1=lambda
          double lam = p1 ?? 1;
          if (lam <= 0) throw Exception("Lambda debe ser > 0");
          
          output = """
Resultados (Poisson):
Media: ${lam.toStringAsFixed(4)}
Varianza: ${lam.toStringAsFixed(4)}
Asimetría: ${(1 / math.sqrt(lam)).toStringAsFixed(4)}
Curtosis (Exceso): ${(1 / lam).toStringAsFixed(4)}
""";
          break;
          
        case 'Exponencial':
          // p1=lambda
          double lam = p1 ?? 1;
           if (lam <= 0) throw Exception("Lambda debe ser > 0");
           
          output = """
Resultados (Exponencial):
Media: ${(1 / lam).toStringAsFixed(4)}
Varianza: ${(1 / (lam * lam)).toStringAsFixed(4)}
Asimetría: 2.0000
Curtosis (Exceso): 6.0000
""";
          break;
          
        case 'Uniforme':
            // p1=a, p2=b
            double a = p1 ?? 0;
            double b = p2 ?? 1;
            if (a >= b) throw Exception("a debe ser menor que b");
            
            double var_ = math.pow(b - a, 2) / 12;
            
            output = """
Resultados (Uniforme):
Media: ${((a + b) / 2).toStringAsFixed(4)}
Varianza: ${var_.toStringAsFixed(4)}
Asimetría: 0.0000
Curtosis (Exceso): -1.2000
""";
            break;
            
        case 'Geométrica':
           // p1=p
           double pGeo = p1 ?? 0.5;
           if (pGeo <= 0 || pGeo > 1) throw Exception("p debe estar entre 0 y 1");
           
           double mean = 1 / pGeo;
           double varVal = (1 - pGeo) / (pGeo * pGeo);
           double skew = (2 - pGeo) / math.sqrt(1 - pGeo);
           double kurt = 6 + (pGeo * pGeo) / (1 - pGeo);
           
           output = """
Resultados (Geométrica):
Media: ${mean.toStringAsFixed(4)}
Varianza: ${varVal.toStringAsFixed(4)}
Asimetría: ${skew.toStringAsFixed(4)}
Curtosis (Exceso): ${kurt.toStringAsFixed(4)}
""";
           break;
           
        case 'Chi-Cuadrado':
            // p1=k
            double k = p1 ?? 1;
            if (k <= 0) throw Exception("k debe ser > 0");
            
            output = """
Resultados (Chi-Cuadrado):
Media: ${k.toStringAsFixed(4)}
Varianza: ${(2 * k).toStringAsFixed(4)}
Asimetría: ${(math.sqrt(8 / k)).toStringAsFixed(4)}
Curtosis (Exceso): ${(12 / k).toStringAsFixed(4)}
""";
            break;
            
         case 't-Student':
            // p1=nu
            double nu = p1 ?? 1;
            if (nu <= 0) throw Exception("nu debe ser > 0");
            
            String meanStr = (nu > 1) ? "0.0000" : "Indefinida";
            String varStr = (nu > 2) ? (nu / (nu - 2)).toStringAsFixed(4) : "Indefinida";
            String skewStr = (nu > 3) ? "0.0000" : "Indefinida";
            String kurtStr = (nu > 4) ? (6 / (nu - 4)).toStringAsFixed(4) : "Indefinida";
            
             output = """
Resultados (t-Student):
Media: $meanStr
Varianza: $varStr
Asimetría: $skewStr
Curtosis (Exceso): $kurtStr
""";
             break;
      }
      setState(() => _result = output);
    } catch (e) {
      setState(() => _result = "Error: ${e.toString().replaceAll("Exception: ", "")}");
    }
  }

  String _getP1Label() {
    switch (_selectedDist) {
      case 'Normal': return "Media (μ)";
      case 'Binomial': return "Ensayos (n)";
      case 'Poisson': return "Tasa (λ)";
      case 'Exponencial': return "Tasa (λ)";
      case 'Uniforme': return "Mínimo (a)";
      case 'Geométrica': return "Prob. Éxito (p)";
      case 'Chi-Cuadrado': return "Grados libertad (k)";
      case 't-Student': return "Grados libertad (ν)";
      default: return "";
    }
  }

  String? _getP2Label() {
    switch (_selectedDist) {
      case 'Normal': return "Desviación (σ)";
      case 'Binomial': return "Prob. Éxito (p)";
      case 'Uniforme': return "Máximo (b)";
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Momentos Teóricos'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDist,
              items: ['Normal', 'Binomial', 'Poisson', 'Exponencial', 'Uniforme', 'Geométrica', 'Chi-Cuadrado', 't-Student']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedDist = v!;
                  _p1Ctrl.clear();
                  _p2Ctrl.clear();
                  _result = "";
                });
              },
              decoration: const InputDecoration(labelText: "Distribución", border: OutlineInputBorder()),
            ),
             const SizedBox(height: 16),
             
             // Info Card
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
               child: const Text(
                 "Calcula los momentos teóricos (poblacionales) exactos basados en los parámetros de la distribución.",
                 style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
               ),
             ),
             
            const SizedBox(height: 16),
            TextField(controller: _p1Ctrl, decoration: InputDecoration(labelText: _getP1Label(), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
            if (_getP2Label() != null) ...[
              const SizedBox(height: 10),
              TextField(controller: _p2Ctrl, decoration: InputDecoration(labelText: _getP2Label(), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              child: const Text("Calcular Momentos"),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.shade100)
                ),
                child: Text(_result, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.indigo)),
              )
          ],
        ),
      ),
    );
  }
}
