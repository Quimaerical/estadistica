import 'package:flutter/material.dart';

class MGFGuideScreen extends StatelessWidget {
  const MGFGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía F.G.M.'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Definición'),
            _buildCard(
              children: [
                _buildMathText('M_X(t) = E[e^{tX}]'),
                const SizedBox(height: 8),
                const Text(
                  'Es la esperanza matemática de la exponencial de la variable aleatoria. '
                  'Si existe en un entorno de t=0, determina unívocamente la distribución.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('Caso Discreto (Series)'),
            _buildCard(
              children: [
                _buildMathText('M_X(t) = ∑ e^{tx} · P(X=x)'),
                const Divider(),
                const Text('Series Útiles:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildMathLabel('Serie Geométrica:', '∑ r^k = 1 / (1-r),  |r| < 1'),
                _buildMathLabel('Exponencial (Taylor):', 'e^x = ∑ x^k / k!'),
                _buildMathLabel('Binomial:', '(a+b)^n = ∑ (nCk) a^k b^{n-k}'),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Caso Continuo (Integrales)'),
            _buildCard(
              children: [
                _buildMathText('M_X(t) = ∫ e^{tx} · f(x) dx'),
                const Divider(),
                const Text('Integrales Útiles:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildMathLabel('Función Gamma:', '∫ x^{α-1} e^{-βx} dx = Γ(α) / β^α'),
                const Text('(Integrar de 0 a ∞)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                _buildMathLabel('Integral Gaussiana:', '∫ e^{-x^2} dx = √π'),
                const Text('(Integrar de -∞ a ∞)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('Relación con Momentos'),
             _buildCard(
              children: [
                const Text(
                  'El n-ésimo momento se obtiene derivando n veces y evaluando en t=0:',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                 _buildMathText('E[X^n] = M_X^{(n)}(0)'),
              ]
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildMathText(String text) {
    // Get context from the widget tree is problematic inside a helper method if not passed, 
    // but here we are inside a class method so we need 'context' or to make it a widget.
    // Since this is a StatelessWidget method, it doesn't have 'context' in scope unless passed.
    // However, I will change this to be built inside the 'build' method or use a Builder.
    // Actually, let's just use a Builder or extract specific widgets locally.
    // Wait, the original code had 'build(BuildContext context)'. 
    // The methods _buildMathText etc are just helper methods on the class. They CANNOT access 'context' 
    // because it's not a field of StatelessWidget.
    // I need to change the signature to accept context or move the logic.
    
    // Changing approach: I will rewrite the class to pass context or use Theme directly where context is available.
    // Since I am replacing the whole file content helper methods, I'll update signatures.
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18, 
                fontFamily: 'monospace', 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    );
  }

  Widget _buildMathLabel(String label, String formula) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
               Text(
                formula,
                style: TextStyle(
                  fontFamily: 'monospace', 
                  fontSize: 15, 
                  color: isDark ? Colors.grey[300] : Colors.black87
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
