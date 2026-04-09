import 'package:flutter/material.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../services/stat_engine_ffi.dart';

class CriticalValueScreen extends StatefulWidget {
  const CriticalValueScreen({super.key});

  @override
  State<CriticalValueScreen> createState() => _CriticalValueScreenState();
}

class _CriticalValueScreenState extends State<CriticalValueScreen> {
  final StatEngineFFI _engine = StatEngineFFI();
  final _alphaCtrl = TextEditingController(text: "0.05");
  final _dfCtrl = TextEditingController(text: "10"); // Para T, Chi2, F
  
  // 0: Z, 1: T, 2: Chi2
  int _distType = 0; 
  bool _twoTailed = true;
  String _result = '';

  void _calculate() {
    final a = double.tryParse(_alphaCtrl.text.replaceAll(',', '.'));
    final df = int.tryParse(_dfCtrl.text);

    if (a == null || a <= 0 || a >= 1) return;

    double crit = 0.0;
    if (_distType == 0) {
      crit = _engine.statCriticalZ(a, _twoTailed);
    } else if (_distType == 1) {
      if (df == null || df <= 0) return;
      crit = _engine.statCriticalT(a, df, _twoTailed);
    } else if (_distType == 2) {
      if (df == null || df <= 0) return;
      // Chi2 usa cola superior habitualmente para test de varianza
      crit = _engine.statCriticalChi2(a, df, !_twoTailed); 
    }

    setState(() {
      _result = NumberFormatter.format(crit, precision: 6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Valores Críticos')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<int>(
              value: _distType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Distribución Z (Normal)')),
                DropdownMenuItem(value: 1, child: Text('Distribución T-Student')),
                DropdownMenuItem(value: 2, child: Text('Distribución Chi-Cuadrado')),
              ],
              onChanged: (v) => setState(() => _distType = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _alphaCtrl,
              decoration: const InputDecoration(labelText: 'Significancia (Alpha α)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_distType > 0)
              TextField(
                controller: _dfCtrl,
                decoration: const InputDecoration(labelText: 'Grados de Libertad (df)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            SwitchListTile(
              title: const Text("Dos Colas (Bilateral)"),
              value: _twoTailed,
              onChanged: (v) => setState(() => _twoTailed = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _calculate, child: const Text("Calcular")),
            const SizedBox(height: 32),
            if (_result.isNotEmpty && _result != 'NaN')
               Text('Valor Crítico = $_result', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo), textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}
