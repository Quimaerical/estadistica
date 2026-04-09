import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../domain/usecases/hypothesis_orchestrator.dart';
import '../domain/entities/test_result.dart';
import '../widgets/hypothesis_graph.dart';
import '../../../core/utils/number_formatter.dart';

class AdvancedHypothesisScreen extends StatefulWidget {
  const AdvancedHypothesisScreen({super.key});
  @override
  State<AdvancedHypothesisScreen> createState() => _AdvancedHypothesisScreenState();
}

class _AdvancedHypothesisScreenState extends State<AdvancedHypothesisScreen> {
  final HypothesisOrchestrator _orchestrator = HypothesisOrchestrator();
  TailType _tailType = TailType.twoSided;
  bool _isPopStdDevKnown = true;

  // 1 Sample
  final _s1MeanCtrl = TextEditingController(text: "15.5");
  final _s1H0Ctrl = TextEditingController(text: "15.0");
  final _s1nCtrl = TextEditingController(text: "40");
  final _s1sdCtrl = TextEditingController(text: "2.1");
  final _s1alphaCtrl = TextEditingController(text: "0.05");

  // 2 Samples
  final _dMean1Ctrl = TextEditingController(text: "15.5");
  final _dn1Ctrl = TextEditingController(text: "40");
  final _dsd1Ctrl = TextEditingController(text: "2.1");
  final _dMean2Ctrl = TextEditingController(text: "14.2");
  final _dn2Ctrl = TextEditingController(text: "35");
  final _dsd2Ctrl = TextEditingController(text: "1.9");
  final _dDeltaCtrl = TextEditingController(text: "0");
  final _dAlphaCtrl = TextEditingController(text: "0.05");

  HypothesisTestResult? _result;
  double _graphMeanH0 = 0.0;
  double _graphMeanH1 = 0.0;
  double _graphSE = 1.0;

  void _calculateOneSample() {
    final double? m = double.tryParse(_s1MeanCtrl.text);
    final double? h0 = double.tryParse(_s1H0Ctrl.text);
    final int? n = int.tryParse(_s1nCtrl.text);
    final double? sd = double.tryParse(_s1sdCtrl.text);
    final double? a = double.tryParse(_s1alphaCtrl.text);
    if (m!=null && h0!=null && n!=null && sd!=null && a!=null && n>0 && sd>0) {
      setState(() {
        _result = _orchestrator.evaluateOneSampleMean(
          sampleMean: m, popMeanH0: h0, n: n, sampleStdDev: sd,
          isPopStdDevKnown: _isPopStdDevKnown, alpha: a, tail: _tailType
        );
        _graphMeanH0 = h0;
        _graphMeanH1 = m;
        _graphSE = sd / math.sqrt(n);
      });
    }
  }

  void _calculateTwoSamples() {
    final double? m1 = double.tryParse(_dMean1Ctrl.text);
    final double? m2 = double.tryParse(_dMean2Ctrl.text);
    final int? n1 = int.tryParse(_dn1Ctrl.text);
    final int? n2 = int.tryParse(_dn2Ctrl.text);
    final double? s1 = double.tryParse(_dsd1Ctrl.text);
    final double? s2 = double.tryParse(_dsd2Ctrl.text);
    final double? del = double.tryParse(_dDeltaCtrl.text);
    final double? a = double.tryParse(_dAlphaCtrl.text);
    
    if (m1!=null && m2!=null && n1!=null && n2!=null && s1!=null && s2!=null && del!=null && a!=null) {
      setState(() {
        _result = _orchestrator.evaluateTwoSampleMeans(
          mean1: m1, mean2: m2, sd1: s1, sd2: s2, n1: n1, n2: n2, deltaH0: del,
          isPopStdDevKnown: _isPopStdDevKnown, assumeEqualVariances: false, alpha: a, tail: _tailType
        );
        _graphMeanH0 = del;
        _graphMeanH1 = m1 - m2;
        _graphSE = math.sqrt((s1*s1)/n1 + (s2*s2)/n2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inferencia FFI (8 Pasos)'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: "1 Muestra", icon: Icon(Icons.exposure_neg_1)),
              Tab(text: "Dif. Medias", icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(isTwoSample: false),
            _buildTabContent(isTwoSample: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({required bool isTwoSample}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isTwoSample ? _buildTwoSampleInput() : _buildOneSampleInput(),
          const SizedBox(height: 10),
          _buildCommonSettings(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isTwoSample ? _calculateTwoSamples : _calculateOneSample,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            child: const Text("Ejecutar los 8 Pasos (Motor FFI)"),
          ),
          const SizedBox(height: 20),
          if (_result != null) _buildResultSection(),
        ],
      ),
    );
  }

  Widget _buildOneSampleInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [ Expanded(child: TextField(controller: _s1MeanCtrl, decoration: const InputDecoration(labelText: "Media Muestral (x̄)"), keyboardType: TextInputType.number)), const SizedBox(width: 10), Expanded(child: TextField(controller: _s1H0Ctrl, decoration: const InputDecoration(labelText: "Media H0 (μ0)"), keyboardType: TextInputType.number)) ]),
            const SizedBox(height: 8),
            Row(children: [ Expanded(child: TextField(controller: _s1nCtrl, decoration: const InputDecoration(labelText: "Muestra (n)"), keyboardType: TextInputType.number)), const SizedBox(width: 10), Expanded(child: TextField(controller: _s1sdCtrl, decoration: const InputDecoration(labelText: "Desv. Est. (s)"), keyboardType: TextInputType.number)) ]),
            const SizedBox(height: 8),
            TextField(controller: _s1alphaCtrl, decoration: const InputDecoration(labelText: "Significancia (α)"), keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoSampleInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text("Muestra 1 (Grupo A)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            Row(children: [ Expanded(child: TextField(controller: _dMean1Ctrl, decoration: const InputDecoration(labelText: "Media (x̄1)"), keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: TextField(controller: _dn1Ctrl, decoration: const InputDecoration(labelText: "n1"), keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: TextField(controller: _dsd1Ctrl, decoration: const InputDecoration(labelText: "s1"), keyboardType: TextInputType.number)) ]),
            const Divider(height: 24),
            const Text("Muestra 2 (Grupo B)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            Row(children: [ Expanded(child: TextField(controller: _dMean2Ctrl, decoration: const InputDecoration(labelText: "Media (x̄2)"), keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: TextField(controller: _dn2Ctrl, decoration: const InputDecoration(labelText: "n2"), keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: TextField(controller: _dsd2Ctrl, decoration: const InputDecoration(labelText: "s2"), keyboardType: TextInputType.number)) ]),
            const Divider(height: 24),
            Row(children: [ Expanded(child: TextField(controller: _dDeltaCtrl, decoration: const InputDecoration(labelText: "Diferencia H0 (Δ0)"), keyboardType: TextInputType.number)), const SizedBox(width: 10), Expanded(child: TextField(controller: _dAlphaCtrl, decoration: const InputDecoration(labelText: "Significancia (α)"), keyboardType: TextInputType.number)) ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonSettings() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            DropdownButtonFormField<TailType>(
              value: _tailType,
              decoration: const InputDecoration(labelText: "Hipótesis Alternativa", border: InputBorder.none),
              items: const [
                DropdownMenuItem(value: TailType.left, child: Text("Cola Izquierda (< H0)")),
                DropdownMenuItem(value: TailType.right, child: Text("Cola Derecha (> H0)")),
                DropdownMenuItem(value: TailType.twoSided, child: Text("Bilateral (≠ H0)")),
              ],
              onChanged: (v) => setState(() => _tailType = v!),
            ),
            SwitchListTile(
              dense: true,
              title: const Text("Varianza Poblacional Conocida"),
              subtitle: const Text("Fuerza el estadístico a Z estricta"),
              value: _isPopStdDevKnown,
              onChanged: (v) => setState(() => _isPopStdDevKnown = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HypothesisGraph(
          meanH0: _graphMeanH0,
          meanH1: _graphMeanH1,
          stdDev: _graphSE,
          criticalValue: _graphMeanH0 + _result!.step7CriticalValue * _graphSE,
          isRightTailed: _tailType == TailType.right || (_tailType == TailType.twoSided && _result!.step7StatisticValue > 0),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.indigo.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Evaluación Estadística Rigurosa (8 Pasos):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                _StepText("1. Parámetro", _result!.step1Parameter),
                _StepText("2. Hipótesis nula H0", _result!.step2H0),
                _StepText("3. Alternativa H1", _result!.step3H1),
                _StepText("4. Nivel de Riesgo (α)", _result!.step4Alpha.toString()),
                _StepText("5. Distribución", _result!.step5StatisticType.name.toUpperCase()),
                _StepText("6. Criterio de Rechazo", _result!.step6DecisionRule),
                _StepText("7. Calcl FFI (NormalCDF)", "Estadístico = ${NumberFormatter.format(_result!.step7StatisticValue)}\nP-Valor = ${_result!.step7PValue != null ? NumberFormatter.format(_result!.step7PValue!) : 'Pendiente'}"),
                _StepText("8. Conclusión", _result!.step8Conclusion, isBold: true, color: _result!.step8RejectH0 ? Colors.red : Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepText extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final Color? color;
  const _StepText(this.title, this.value, {this.isBold = false, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black87)),
          ],
        ),
      ),
    );
  }
}
