import 'package:flutter/material.dart';

class DistributionsGuideScreen extends StatelessWidget {
  const DistributionsGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de Distribuciones'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDistCard(
            context,
            "Normal (Gaussiana)",
            "X ~ N(μ, σ²)",
            "f(x) = (1 / (σ√(2π))) · e^(-0.5((x-μ)/σ)²)",
            "Media: μ\nVarianza: σ²",
          ),
          _buildDistCard(
            context,
            "Binomial",
            "X ~ B(n, p)",
            "P(X=k) = (nCk) · p^k · (1-p)^(n-k)",
            "Media: n·p\nVarianza: n·p·(1-p)",
          ),
          _buildDistCard(
            context,
            "Poisson",
            "X ~ Poi(λ)",
            "P(X=k) = (e^(-λ) · λ^k) / k!",
            "Media: λ\nVarianza: λ",
          ),
          _buildDistCard(
            context,
            "Exponencial",
            "X ~ Exp(λ)",
            "f(x) = λ · e^(-λx), x ≥ 0",
            "Media: 1/λ\nVarianza: 1/λ²",
          ),
          _buildDistCard(
            context,
            "Uniforme (Continua)",
            "X ~ U(a, b)",
            "f(x) = 1 / (b-a), a ≤ x ≤ b",
            "Media: (a+b)/2\nVarianza: (b-a)²/12",
          ),
          _buildDistCard(
            context,
            "Geométrica",
            "X ~ Geo(p)",
            "P(X=k) = (1-p)^(k-1) · p",
            "Media: 1/p\nVarianza: (1-p)/p²",
          ),
          _buildDistCard(
            context,
            "Chi-Cuadrado",
            "X ~ χ²(k)",
            "f(x) = (x^(k/2 - 1) · e^(-x/2)) / (2^(k/2) · Γ(k/2))",
            "Media: k\nVarianza: 2k",
          ),
          _buildDistCard(
            context,
            "t-Student",
            "X ~ t(ν)",
            "f(x) ∝ (1 + x²/ν)^(-(ν+1)/2)",
            "Media: 0 (ν > 1)\nVarianza: ν/(ν-2) (ν > 2)",
          ),
          _buildDistCard(
            context,
            "F-Snedecor",
            "X ~ F(d₁, d₂)",
            "Compleja (involucra funciones Beta)",
            "Media: d₂/(d₂-2) (d₂ > 2)\nVarianza: Compleja",
          ),
        ],
      ),
    );
  }

  Widget _buildDistCard(BuildContext context, String title, String notation, String pdf, String moments) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 4),
            Text(notation, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600], fontStyle: FontStyle.italic)),
            const Divider(),
            const SizedBox(height: 8),
            _buildLabel("Función (PDF/PMF):"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(pdf, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
            ),
            const SizedBox(height: 8),
            _buildLabel("Momentos:"),
            Text(moments, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey));
  }
}
