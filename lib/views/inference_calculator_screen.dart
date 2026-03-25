import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../services/api_service.dart';

class InferenceCalculatorScreen extends StatefulWidget {
  const InferenceCalculatorScreen({super.key});

  @override
  State<InferenceCalculatorScreen> createState() => _InferenceCalculatorScreenState();
}

class _InferenceCalculatorScreenState extends State<InferenceCalculatorScreen> {
  String _selectedDistribution = 'Normal';
  final List<String> _distributions = ['Normal', 'Exponential'];
  final TextEditingController _dataController = TextEditingController(); // Optional data input
  
  bool _isLoading = false;
  Map<String, dynamic>? _results;
  String? _errorMessage;

  Future<void> _analyze() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = null;
    });

    try {
      // Parse data if provided
      List<double>? sampleData;
      if (_dataController.text.isNotEmpty) {
        sampleData = _dataController.text
            .split(',')
            .map((e) => double.tryParse(e.trim()) ?? 0.0)
            .toList();
      }

      final results = await ApiService.analyzeDistribution(_selectedDistribution, sampleData: sampleData);
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inferencia Estadística Simbólica'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedDistribution,
                      decoration: const InputDecoration(
                        labelText: 'Distribución',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.functions),
                      ),
                      items: _distributions.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDistribution = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: 'Datos de Muestra (Opcional)',
                        hintText: 'Ej: 1.2, 3.4, 2.1 (separados por coma)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.data_array),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _analyze,
                        icon: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                            : const Icon(Icons.analytics),
                        label: const Text('Calcular Estimadores'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildResultsArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)));
    }
    
    if (_results == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Selecciona una distribución y presiona Calcular', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    // Build TeX view content
    List<String> steps = List<String>.from(_results!['steps'] ?? []);
    String mleResult = _results!['mle'].toString();
    String mmResult = _results!['mm'].toString();
    String properties = _results!['properties'].toString();

    // Construct a single TeX string or multiple blocks
    return TeXView(
      child: TeXViewColumn(children: [
        _teXCard('Derivación Paso a Paso', steps.join('<br><br>')),
        _teXCard('Resultados Finales', 
          r"$$ \textbf{MLE}: " + mleResult + r" $$ <br> " + 
          r"$$ \textbf{Momentos}: " + mmResult + r" $$"
        ),
        _teXCard('Propiedades', properties),
      ]),
      style: const TeXViewStyle(
        margin: TeXViewMargin.all(10),
        elevation: 5,
        borderRadius: TeXViewBorderRadius.all(10),
      ),
    );
  }

  TeXViewWidget _teXCard(String title, String content) {
    return TeXViewContainer(
      child: TeXViewColumn(children: [
        TeXViewDocument(title, style: TeXViewStyle(textAlign: TeXViewTextAlign.center, fontStyle: TeXViewFontStyle(fontWeight: TeXViewFontWeight.bold, fontSize: 18))),
        TeXViewDocument(content, style: TeXViewStyle(padding: TeXViewPadding.all(10))),
      ]),
      style: const TeXViewStyle(
        margin: TeXViewMargin.only(bottom: 10),
        padding: TeXViewPadding.all(10),
        backgroundColor: Colors.white,
        borderRadius: TeXViewBorderRadius.all(10),
        elevation: 2,
      ),
    );
  }
}
