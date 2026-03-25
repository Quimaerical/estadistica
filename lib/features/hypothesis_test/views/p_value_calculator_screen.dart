import 'package:flutter/material.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../services/stat_engine_ffi.dart';

/// Pantalla que implementa el requerimiento modular: Calculadora de Valor p.
/// Utiliza FFI de forma transparente y NumberFormatter para formateos extremos visualizados.
class PValueCalculatorScreen extends StatefulWidget {
  @override
  _PValueCalculatorScreenState createState() => _PValueCalculatorScreenState();
}

class _PValueCalculatorScreenState extends State<PValueCalculatorScreen> {
  final TextEditingController _zController = TextEditingController();
  final StatEngineFFI _engine = StatEngineFFI();

  // Estados
  int _tailType = 2; // -1: Cola izquierda, 1: Cola derecha, 2: Dos colas (Bilateral)
  String _resultPValue = '';
  double? _rawPValue;

  void _calculate() {
    // Removiendo espacios o comas
    final String cleanInput = _zController.text.replaceAll(',', '.');
    final double? zStat = double.tryParse(cleanInput);

    if (zStat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un número válido.')),
      );
      return;
    }
    
    try {
      // Usamos el motor C++ consumiendo 'stat_pvalue_z' que retorna un `double` IEEE 754 limpio
      final pValue = _engine.statPValueZ(zStat, _tailType);
      
      setState(() {
        _rawPValue = pValue;
        // Aplicamos la utilería NumberFormatter creada para notación científica si es muy pequeño/grande
        _resultPValue = NumberFormatter.format(pValue, precision: 6);
      });
    } catch (e) {
      setState(() {
        _resultPValue = 'Error de cálculo nativo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Un diseño elegante y minimalista adaptado al paradigma de Flutter
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Valor p (Normal Z)'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Obtén la probabilidad o área bajo la curva asumiendo una distribución Normal Estándar.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 32),
            
            // Input Estadístico Z
            TextField(
              controller: _zController,
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Estadístico de Prueba (Z)',
                hintText: 'Ej. 4.51',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.calculate_outlined),
              ),
            ),
            SizedBox(height: 24),
            
            // Dropdown de Tipo de Cola
            DropdownButtonFormField<int>(
              value: _tailType,
              decoration: InputDecoration(
                labelText: 'Dirección de la Prueba',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.compare_arrows_outlined),
              ),
              items: [
                DropdownMenuItem(value: -1, child: Text('Cola Izquierda ( P(Z < z) )')),
                DropdownMenuItem(value: 1, child: Text('Cola Derecha ( P(Z > z) )')),
                DropdownMenuItem(value: 2, child: Text('Dos Colas ( P(|Z| > z) )')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _tailType = val);
              },
            ),
            
            SizedBox(height: 48),
            
            // Botón Calcular
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Calcular Valor p', style: TextStyle(fontSize: 18)),
            ),
            
            SizedBox(height: 32),
            
            // Resultado Mostrado (NumberFormatter Actuando)
            if (_resultPValue.isNotEmpty)
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.shade900.withOpacity(0.3), blurRadius: 10, offset: Offset(0,5))
                  ]
                ),
                child: Column(
                  children: [
                    Text(
                      'Probabilidad Encontrada',
                      style: TextStyle(color: Colors.blue.shade100, fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _resultPValue, // Notación científica o decimal limpia
                      style: TextStyle(
                        fontSize: _rawPValue != null && (_rawPValue! < 0.0001 || _rawPValue! >= 10000) ? 36 : 42, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
