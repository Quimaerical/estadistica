import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'GroupedDataScreen.dart';
import 'MomentsScreen.dart';
import 'TheoreticalDistributionsScreen.dart';
import 'MGFGuideScreen.dart';
import 'MonteCarloScreen.dart';
import 'DistributionsGuideScreen.dart';
import 'views/inference_calculator_screen.dart';
import 'features/hypothesis_test/views/advanced_hypothesis_screen.dart';
import 'features/hypothesis_test/views/p_value_calculator_screen.dart';
import 'features/hypothesis_test/views/critical_value_screen.dart';
import 'features/project_defense/ui/ProyectoParte1ANOVA.dart';
import 'features/project_defense/ui/ProyectoParte2RLM.dart';

void main() {
  runApp(const StatApp());
}

class StatApp extends StatefulWidget {
  const StatApp({super.key});

  @override
  State<StatApp> createState() => _StatAppState();
}

class _StatAppState extends State<StatApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estadística Pro',
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardThemeData(
          elevation: 2,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardThemeData(
          elevation: 2,
          surfaceTintColor: const Color(0xFF1E1E1E),
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      home: MenuScreen(
        onThemeToggle: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const MenuScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Herramientas Estadísticas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _MenuButton(
            icon: Icons.stars,
            title: 'Proyecto Final - Parte 1 (ANOVA)',
            subtitle: 'Análisis de Red SwiftPay',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProyectoParte1ANOVA()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.timeline,
            title: 'Proyecto Final - Parte 2 (RLM CPU)',
            subtitle: 'Predicción de Telemetría (OLS)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProyectoParte2RLM()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.analytics,
            title: 'Analizador Estadístico Definitivo',
            subtitle: 'Media, Varianza, Histogramas, etc.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DescriptiveStatsScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.computer,
            title: 'Calculadora de Inferencia (MLE/MM)',
            subtitle: 'Estimación Puntual Simbólica',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InferenceCalculatorScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.functions,
            title: 'Calculadora de Distribuciones',
            subtitle: 'Normal, t-Student, Chi-Cuadrado, F',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DistributionCalculatorScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.biotech,
            title: 'Inferencia (Motor C++)',
            subtitle: 'Metodología FFI de 8 Pasos',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdvancedHypothesisScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.calculate_outlined,
            title: 'Calculadora de Valor p (Z)',
            subtitle: 'Integral exacta Z (C++ Nativo)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PValueCalculatorScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.table_chart_outlined,
            title: 'Valores Críticos (Inversas)',
            subtitle: 'Z, T, Chi² (C++ Nativo)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CriticalValueScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.science,
            title: 'Prueba T Estadística',
            subtitle: 'Prueba t para una muestra',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HypothesisTestScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.bar_chart,
            title: 'Analizador Estadístico (Datos Agrupados)',
            subtitle: 'Media, Varianza, Histograma (Intervalos)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GroupedDataScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.calculate,
            title: 'Calculadora de Momentos',
            subtitle: 'Momentos, Asimetría, Curtosis',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MomentsScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.school,
            title: 'Momentos Teóricos',
            subtitle: 'Resultados exactos por distribución',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TheoreticalDistributionsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.menu_book,
            title: 'Guía Función Generadora de Momentos',
            subtitle: 'Series e Integrales útiles',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MGFGuideScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.casino,
            title: 'Simulación Monte Carlo',
            subtitle: 'Estimación de Pi y Teorema Central',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MonteCarloScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: Icons.list_alt,
            title: 'Guía de Distribuciones',
            subtitle: 'Fórmulas y Propiedades',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DistributionsGuideScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.indigo.shade50,
                child: Icon(icon, size: 30, color: Colors.indigo),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MATH ENGINE
// ==========================================

class MathUtils {
  static double mean(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  static double variance(List<double> data, {bool isSample = true}) {
    if (data.length < 2) return 0;
    double m = mean(data);
    double sumSquaredDiff = data
        .map((x) => math.pow(x - m, 2))
        .reduce((a, b) => a + b)
        .toDouble();
    return sumSquaredDiff / (data.length - (isSample ? 1 : 0));
  }

  static double stdDev(List<double> data, {bool isSample = true}) {
    return math.sqrt(variance(data, isSample: isSample));
  }

  static double skewness(List<double> data, {bool isSample = true}) {
    if (data.length < 3) return 0;
    double m = mean(data);
    double s = stdDev(data, isSample: isSample);
    if (s == 0) return 0;
    double n = data.length.toDouble();
    double sumCubedDiff = data
        .map((x) => math.pow((x - m) / s, 3))
        .reduce((a, b) => a + b)
        .toDouble();

    if (isSample) {
      return (n / ((n - 1) * (n - 2))) *
          sumCubedDiff; // Fisher-Pearson adjusted
    } else {
      return sumCubedDiff / n;
    }
  }

  static double kurtosis(List<double> data, {bool isSample = true}) {
    if (data.length < 4) return 0;
    double m = mean(data);
    double s = stdDev(data, isSample: isSample);
    if (s == 0) return 0;
    double n = data.length.toDouble();
    double sumQuarticDiff = data
        .map((x) => math.pow((x - m) / s, 4))
        .reduce((a, b) => a + b)
        .toDouble();

    if (isSample) {
      // Excess kurtosis for sample
      double k = (n * (n + 1)) / ((n - 1) * (n - 2) * (n - 3));
      double term2 = (3 * math.pow(n - 1, 2)) / ((n - 2) * (n - 3));
      return (k * sumQuarticDiff) - term2;
    } else {
      return (sumQuarticDiff / n) - 3; // Excess kurtosis
    }
  }

  static List<double> quartiles(List<double> data) {
    if (data.isEmpty) return [0, 0, 0];
    List<double> sorted = List.from(data)..sort();
    return [
      _percentile(sorted, 25),
      _percentile(sorted, 50),
      _percentile(sorted, 75),
    ];
  }

  static double _percentile(List<double> sortedData, double percentile) {
    int n = sortedData.length;
    if (n == 0) return 0;
    double pos = (percentile / 100) * (n + 1);
    int k = pos.floor();
    double d = pos - k;

    if (k <= 0) return sortedData.first;
    if (k >= n) return sortedData.last;

    return sortedData[k - 1] + d * (sortedData[k] - sortedData[k - 1]);
  }

  static double mode(List<double> data) {
    if (data.isEmpty) return 0;
    Map<double, int> counts = {};
    for (var x in data) counts[x] = (counts[x] ?? 0) + 1;
    int maxCount = counts.values.reduce(math.max);
    // Return the first one found (simple mode), or could return list if multimodal
    return counts.entries.firstWhere((e) => e.value == maxCount).key;
  }

  static double skewnessGrouped(
    List<Map<String, dynamic>> intervals,
    double mean,
    double stdDev,
  ) {
    if (intervals.isEmpty || stdDev == 0) return 0;
    double n = intervals.fold(0, (sum, item) => sum + (item['freq'] as int));
    double sumCubed = intervals.fold(0.0, (sum, item) {
      double mid = item['mid'];
      int freq = item['freq'];
      return sum + freq * math.pow(mid - mean, 3);
    });
    // Population skewness for grouped data usually just divides by N*sigma^3
    return sumCubed / (n * math.pow(stdDev, 3));
  }

  static double kurtosisGrouped(
    List<Map<String, dynamic>> intervals,
    double mean,
    double stdDev,
  ) {
    if (intervals.isEmpty || stdDev == 0) return 0;
    double n = intervals.fold(0, (sum, item) => sum + (item['freq'] as int));
    double sumQuartic = intervals.fold(0.0, (sum, item) {
      double mid = item['mid'];
      int freq = item['freq'];
      return sum + freq * math.pow(mid - mean, 4);
    });
    return (sumQuartic / (n * math.pow(stdDev, 4))) - 3;
  }

  // --- SPECIAL FUNCTIONS ---

  static double logGamma(double x) {
    // Lanczos approximation for log(gamma(x))
    List<double> p = [
      0.99999999999980993,
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7,
    ];
    if (x < 0.5)
      return math.log(math.pi / math.sin(math.pi * x)) - logGamma(1 - x);
    x -= 1;
    double a = p[0];
    double t = x + 7.5;
    for (int i = 1; i < p.length; i++) a += p[i] / (x + i);
    return math.log(math.sqrt(2 * math.pi) * a) + (x + 0.5) * math.log(t) - t;
  }

  static double gamma(double x) => math.exp(logGamma(x));

  static double incompleteGamma(double s, double x) {
    // Regularized Lower Incomplete Gamma Function P(s,x)
    if (x < 0) return 0;
    if (x == 0) return 0;
    if (s <= 0) return 0; // Should not happen for our use cases

    // Series representation for small x or s
    if (x < s + 1.0) {
      double ap = s;
      double del = 1.0 / s;
      double sum = del;
      for (int n = 1; n < 100; n++) {
        ap += 1.0;
        del *= x / ap;
        sum += del;
        if (del.abs() < sum.abs() * 1e-7) {
          return sum * math.exp(-x + s * math.log(x) - logGamma(s));
        }
      }
    }
    // Continued fraction for large x
    else {
      double gln = logGamma(s);
      double b = x + 1.0 - s;
      double c = 1.0 / 1.0e-30;
      double d = 1.0 / b;
      double h = d;
      for (int i = 1; i < 100; i++) {
        double an = -i * (i - s);
        b += 2.0;
        d = an * d + b;
        if (d.abs() < 1e-30) d = 1e-30;
        c = b + an / c;
        if (c.abs() < 1e-30) c = 1e-30;
        d = 1.0 / d;
        double del = d * c;
        h *= del;
        if ((del - 1.0).abs() < 1e-7) break;
      }
      return 1.0 - math.exp(-x + s * math.log(x) - gln) * h;
    }
    return 0.0; // Fallback
  }

  static double incompleteBeta(double x, double a, double b) {
    // Regularized Incomplete Beta Function Ix(a,b)
    if (x < 0 || x > 1) return 0; // Error domain
    if (x == 0) return 0;
    if (x == 1) return 1;

    double bt = (x == 0.0 || x == 1.0)
        ? 0.0
        : math.exp(
            logGamma(a + b) -
                logGamma(a) -
                logGamma(b) +
                a * math.log(x) +
                b * math.log(1.0 - x),
          );

    if (x < (a + 1.0) / (a + b + 2.0)) {
      return bt * _betacf(x, a, b) / a;
    } else {
      return 1.0 - bt * _betacf(1.0 - x, b, a) / b;
    }
  }

  static double _betacf(double x, double a, double b) {
    // Continued fraction for Incomplete Beta
    int maxIt = 100;
    double epsilon = 1e-7;
    double am = 1.0;
    double bm = 1.0;
    double az = 1.0;
    double qab = a + b;
    double qap = a + 1.0;
    double qam = a - 1.0;
    double bz = 1.0 - qab * x / qap;

    for (int m = 1; m <= maxIt; m++) {
      double em = m.toDouble();
      double tem = em + em;
      double d = em * (b - m) * x / ((qam + tem) * (a + tem));
      double ap = az + d * am;
      double bp = bz + d * bm;
      d = -(a + em) * (qab + em) * x / ((a + tem) * (qap + tem));
      app = ap + d * az;
      bpp = bp + d * bz;
      double aold = az;
      am = ap / bpp;
      bm = bp / bpp;
      az = app / bpp;
      bz = 1.0;
      if ((az - aold).abs() < epsilon * az.abs()) return az;
    }
    return az;
  }

  // Helper variables for _betacf
  static double app = 0;
  static double bpp = 0;

  // --- DISTRIBUTIONS (CDF & PPF) ---

  // 1. Normal Distribution
  static double normalCdf(double x, double mean, double stdDev) {
    return 0.5 * (1 + _erf((x - mean) / (stdDev * math.sqrt(2))));
  }

  static double _erf(double x) {
    double a1 = 0.254829592;
    double a2 = -0.284496736;
    double a3 = 1.421413741;
    double a4 = -1.453152027;
    double a5 = 1.061405429;
    double p = 0.3275911;
    int sign = 1;
    if (x < 0) sign = -1;
    x = x.abs();
    double t = 1.0 / (1.0 + p * x);
    double y =
        1.0 -
        (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-x * x);
    return sign * y;
  }

  static double normalPpf(double p, double mean, double stdDev) {
    if (p <= 0 || p >= 1) return 0;
    return mean + stdDev * _stdNormalPpf(p);
  }

  static double _stdNormalPpf(double p) {
    // Beasley-Springer-Moro Algorithm
    double a0 = 2.50662823884;
    double a1 = -18.61500062529;
    double a2 = 41.39119773534;
    double a3 = -25.44106049637;
    double b1 = -8.47351093090;
    double b2 = 23.08336743743;
    double b3 = -21.06224101826;
    double b4 = 3.13082909833;
    double c0 = -2.78718931138;
    double c1 = -2.29796479134;
    double c2 = 4.85014127135;
    double c3 = 2.32121276858;
    double d1 = 3.54388924762;
    double d2 = 1.63706781897;
    double y = p - 0.5;
    if (y.abs() < 0.42) {
      double r = y * y;
      return y *
          (((a3 * r + a2) * r + a1) * r + a0) /
          ((((b4 * r + b3) * r + b2) * r + b1) * r + 1.0);
    } else {
      double r = p;
      if (y > 0) r = 1.0 - p;
      r = math.log(-math.log(r));
      double x = c0 + r * (c1 + r * (c2 + r * c3)) / (1.0 + r * (d1 + r * d2));
      return (y < 0) ? -x : x;
    }
  }

  // 2. Student's t Distribution
  static double tCdf(double t, double df) {
    double x = df / (df + t * t);
    double p = 0.5 * incompleteBeta(x, df / 2, 0.5);
    return t > 0 ? 1 - p : p;
  }

  static double tPpf(double p, double df) {
    // Inverse CDF using Bisection method
    return _solvePpf((val) => tCdf(val, df), p, -100, 100);
  }

  // 3. Chi-Squared Distribution
  static double chi2Cdf(double x, double k) {
    if (x < 0) return 0;
    return incompleteGamma(k / 2, x / 2);
  }

  static double chi2Ppf(double p, double k) {
    return _solvePpf(
      (val) => chi2Cdf(val, k),
      p,
      0,
      200,
    ); // Chi2 is always positive
  }

  // 4. F-Snedecor Distribution
  static double fCdf(double x, double d1, double d2) {
    if (x < 0) return 0;
    double val = (d1 * x) / (d1 * x + d2);
    return incompleteBeta(val, d1 / 2, d2 / 2);
  }

  static double fPpf(double p, double d1, double d2) {
    return _solvePpf(
      (val) => fCdf(val, d1, d2),
      p,
      0,
      200,
    ); // F is always positive
  }

  // 5. Gamma Distribution
  static double gammaCdf(double x, double alpha, double beta) {
    if (x < 0) return 0;
    return incompleteGamma(alpha, x / beta);
  }

  static double gammaPpf(double p, double alpha, double beta) {
    return _solvePpf((val) => gammaCdf(val, alpha, beta), p, 0, 200);
  }

  // --- UTILS ---
  static double _solvePpf(
    double Function(double) cdf,
    double targetP,
    double min,
    double max,
  ) {
    // Bisection method to find x such that cdf(x) = targetP
    if (targetP <= 0) return min;
    if (targetP >= 1) return max;

    double low = min;
    double high = max;
    double mid = 0;

    for (int i = 0; i < 100; i++) {
      mid = (low + high) / 2;
      double p = cdf(mid);
      if ((p - targetP).abs() < 1e-6) return mid;
      if (p < targetP) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return mid;
  }

  // --- DISCRETE DISTRIBUTIONS ---

  static double combinations(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    if (k > n / 2) k = n - k;
    double res = 1;
    for (int i = 1; i <= k; i++) {
      res = res * (n - i + 1) / i;
    }
    return res;
  }

  // Binomial
  static double binomialPmf(int k, int n, double p) {
    if (k < 0 || k > n) return 0;
    return combinations(n, k) * math.pow(p, k) * math.pow(1 - p, n - k);
  }

  static double binomialCdf(int k, int n, double p) {
    if (k < 0) return 0;
    if (k >= n) return 1;
    double sum = 0;
    for (int i = 0; i <= k; i++) {
      sum += binomialPmf(i, n, p);
    }
    return sum;
  }

  // Poisson
  static double poissonPmf(int k, double lambda) {
    if (k < 0) return 0;
    return (math.exp(-lambda) * math.pow(lambda, k)) / _factorial(k);
  }

  static double poissonCdf(int k, double lambda) {
    if (k < 0) return 0;
    double sum = 0;
    for (int i = 0; i <= k; i++) {
      sum += poissonPmf(i, lambda);
    }
    return sum;
  }

  static double _factorial(int n) {
    if (n <= 1) return 1;
    double res = 1;
    for (int i = 2; i <= n; i++) res *= i;
    return res;
  }

  // Geometric (on {1, 2, ...}) P(X=k) = (1-p)^(k-1) * p
  static double geometricPmf(int k, double p) {
    if (k < 1) return 0;
    return math.pow(1 - p, k - 1) * p;
  }

  static double geometricCdf(int k, double p) {
    if (k < 1) return 0;
    return 1 - math.pow(1 - p, k).toDouble();
  }

  // --- RANDOM GENERATION (Monte Carlo) ---

  static List<double> generateNormal(int n, double mean, double stdDev) {
    List<double> samples = [];
    var rng = math.Random();

    // Box-Muller transform
    for (int i = 0; i < n; i++) {
      double u1 = rng.nextDouble();
      double u2 = rng.nextDouble();

      // Handle potential exact 0 which is problematic for log
      while (u1 <= 0) u1 = rng.nextDouble();

      double z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
      // z1 not used here, could buffer it for efficiency but simple loop for now
      samples.add(mean + stdDev * z0);
    }
    return samples;
  }

  static List<double> generateExponential(int n, double lambda) {
    List<double> samples = [];
    var rng = math.Random();

    // Inverse Transform Sampling
    // F(x) = 1 - e^(-lambda * x)  =>  u = 1 - e^(-lambda * x)
    // 1 - u = e^(-lambda * x) => ln(1-u) = -lambda * x => x = -ln(1-u)/lambda
    // Since 1-u is also U(0,1), we can just use -ln(u)/lambda

    for (int i = 0; i < n; i++) {
      double u = rng.nextDouble();
      while (u <= 0) u = rng.nextDouble();
      samples.add(-math.log(u) / lambda);
    }
    return samples;
  }
  // --- PDF FUNCTIONS & FITTING ---

  static double pdfNormal(double x, double mean, double stdDev) {
    if (stdDev <= 0) return 0;
    return (1 / (stdDev * math.sqrt(2 * math.pi))) *
        math.exp(-0.5 * math.pow((x - mean) / stdDev, 2));
  }

  static double pdfExponential(double x, double lambda) {
    if (x < 0) return 0;
    return lambda * math.exp(-lambda * x);
  }

  static double exponentialCdf(double x, double lambda) {
    if (x < 0) return 0;
    return 1 - math.exp(-lambda * x);
  }

  static double pdfUniform(double x, double min, double max) {
    if (x < min || x > max) return 0;
    return 1 / (max - min);
  }

  static double uniformCdf(double x, double min, double max) {
    if (x < min) return 0;
    if (x > max) return 1;
    return (x - min) / (max - min);
  }

  static double tPdf(double x, double df) {
    return (gamma((df + 1) / 2) / (math.sqrt(df * math.pi) * gamma(df / 2))) *
        math.pow(1 + (x * x) / df, -(df + 1) / 2);
  }

  static double chi2Pdf(double x, double k) {
    if (x <= 0) return 0;
    return (1 / (math.pow(2, k / 2) * gamma(k / 2))) *
        math.pow(x, k / 2 - 1) *
        math.exp(-x / 2);
  }

  static double fPdf(double x, double d1, double d2) {
    if (x <= 0) return 0;
    double num = math.sqrt(
      math.pow(d1 * x, d1) * math.pow(d2, d2) / math.pow(d1 * x + d2, d1 + d2),
    );
    return num / (x * _beta(d1 / 2, d2 / 2));
  }

  static double gammaPdf(double x, double alpha, double beta) {
    if (x <= 0) return 0;
    return (math.pow(x, alpha - 1) * math.exp(-x / beta)) /
        (math.pow(beta, alpha) * gamma(alpha));
  }

  static double _beta(double a, double b) {
    return (gamma(a) * gamma(b)) / gamma(a + b);
  }

  static Map<String, dynamic> fitDistribution(List<double> data) {
    if (data.isEmpty || data.length < 2) return {'type': 'None', 'params': {}};

    double mean = MathUtils.mean(data);
    double stdDev = MathUtils.stdDev(data);
    double min = data.reduce(math.min);
    double max = data.reduce(math.max);

    // Create Histogram Bins for SSE calculation
    int bins = 10;
    double range = max - min;
    if (range == 0) return {'type': 'None', 'params': {}};
    double width = range / bins;

    List<int> observed = List.filled(bins, 0);
    for (var x in data) {
      int idx = ((x - min) / width).floor();
      if (idx >= bins) idx = bins - 1;
      observed[idx]++;
    }

    // Calculate SSE for each
    double sseNormal = 0;
    double sseExp = 0;
    double sseUnif = 0;

    double lambda = 1 / mean; // MLE for Exponential

    for (int i = 0; i < bins; i++) {
      double binMid = min + (i + 0.5) * width;
      double obsFreq = observed[i].toDouble();

      // Expected Prob * Total N * BinWidth ?
      // Actually PDF value * Total N * BinWidth gives expected count approx
      double probNorm = pdfNormal(binMid, mean, stdDev);
      double expNorm = probNorm * data.length * width;
      sseNormal += math.pow(obsFreq - expNorm, 2);

      double probExp = pdfExponential(binMid, lambda);
      double expExp = probExp * data.length * width;
      sseExp += math.pow(obsFreq - expExp, 2);

      double probUnif = pdfUniform(binMid, min, max);
      double expUnif = probUnif * data.length * width;
      sseUnif += math.pow(obsFreq - expUnif, 2);
    }

    // Find min SSE
    String best = 'Normal';
    double minSSE = sseNormal;

    // Only consider Exponential if data is positive
    if (min >= 0 && sseExp < minSSE) {
      best = 'Exponencial';
      minSSE = sseExp;
    }
    if (sseUnif < minSSE) {
      best = 'Uniforme';
      minSSE = sseUnif;
    }

    return {
      'type': best,
      'params': best == 'Normal'
          ? {'mean': mean, 'stdDev': stdDev}
          : best == 'Exponencial'
          ? {'lambda': lambda}
          : {'min': min, 'max': max},
    };
  }
}

// ==========================================
// CUSTOM PAINTERS
// ==========================================

class BoxPlotPainter extends CustomPainter {
  final double min;
  final double q1;
  final double median;
  final double q3;
  final double max;
  final Color color;
  final bool isDark;

  BoxPlotPainter({
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    this.color = Colors.indigo,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (min > max) return; // Invalid data

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Paint medianPaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..strokeWidth = 3;

    double range = max - min;
    if (range == 0) range = 1;

    double normalize(double val) {
      return ((val - min) / range) * size.width;
    }

    double yCenter = size.height / 2;
    double boxHeight = size.height * 0.6;
    double top = yCenter - boxHeight / 2;
    double bottom = yCenter + boxHeight / 2;

    double xMin = normalize(min);
    double xQ1 = normalize(q1);
    double xMed = normalize(median);
    double xQ3 = normalize(q3);
    double xMax = normalize(max);

    // Whiskers
    canvas.drawLine(
      Offset(xMin, yCenter),
      Offset(xQ1, yCenter),
      paint,
    ); // Left whisker
    canvas.drawLine(
      Offset(xQ3, yCenter),
      Offset(xMax, yCenter),
      paint,
    ); // Right whisker

    // Whisker caps
    canvas.drawLine(Offset(xMin, top + 5), Offset(xMin, bottom - 5), paint);
    canvas.drawLine(Offset(xMax, top + 5), Offset(xMax, bottom - 5), paint);

    // Box
    Rect box = Rect.fromLTRB(xQ1, top, xQ3, bottom);
    canvas.drawRect(box, fillPaint);
    canvas.drawRect(box, paint);

    // Median
    canvas.drawLine(Offset(xMed, top), Offset(xMed, bottom), medianPaint);

    // Labels
    drawText(canvas, min.toStringAsFixed(1), Offset(xMin, bottom + 5));
    drawText(canvas, q1.toStringAsFixed(1), Offset(xQ1, bottom + 5));
    drawText(canvas, median.toStringAsFixed(1), Offset(xMed, top - 20));
    drawText(canvas, q3.toStringAsFixed(1), Offset(xQ3, bottom + 5));
    drawText(canvas, max.toStringAsFixed(1), Offset(xMax, bottom + 5));
  }

  void drawText(Canvas canvas, String text, Offset offset) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.black54,
        fontSize: 10,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 1. DESCRIPTIVE STATISTICS
// ==========================================

class DescriptiveStatsScreen extends StatefulWidget {
  const DescriptiveStatsScreen({super.key});

  @override
  State<DescriptiveStatsScreen> createState() => _DescriptiveStatsScreenState();
}

class _DescriptiveStatsScreenState extends State<DescriptiveStatsScreen> {
  final TextEditingController _rawCtrl = TextEditingController();
  List<double> _data = [];
  bool _isGroupedInput = false; // Toggle between raw list and grouped input

  // Grouped input controllers
  final TextEditingController _valCtrl = TextEditingController();
  final TextEditingController _freqCtrl = TextEditingController();
  final List<Map<String, dynamic>> _groupedData = [];

  void _processRawData() {
    String text = _rawCtrl.text;
    // Replace commas with spaces to handle both
    text = text.replaceAll(',', ' ');
    List<double> parsed = [];
    for (var item in text.split(' ')) {
      if (item.trim().isNotEmpty) {
        double? val = double.tryParse(item.trim());
        if (val != null) parsed.add(val);
      }
    }
    setState(() {
      _data = parsed;
    });
  }

  void _addGroupedPoint() {
    double? val = double.tryParse(_valCtrl.text);
    int? freq = int.tryParse(_freqCtrl.text);
    if (val != null && freq != null && freq > 0) {
      setState(() {
        _groupedData.add({'val': val, 'freq': freq});
        _groupedData.sort((a, b) => a['val'].compareTo(b['val']));
        _expandGroupedData();
      });
      _valCtrl.clear();
      _freqCtrl.clear();
    }
  }

  void _expandGroupedData() {
    List<double> expanded = [];
    for (var item in _groupedData) {
      for (int i = 0; i < item['freq']; i++) {
        expanded.add(item['val']);
      }
    }
    _data = expanded;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    double mean = MathUtils.mean(_data);
    double stdDev = MathUtils.stdDev(_data);
    double variance = MathUtils.variance(_data);
    double skew = MathUtils.skewness(_data);
    double kurt = MathUtils.kurtosis(_data);
    double mode = MathUtils.mode(_data);
    List<double> quartiles = MathUtils.quartiles(_data);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Análisis Descriptivo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // INPUT SECTION
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Entrada de Datos",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: _isGroupedInput,
                          onChanged: (v) => setState(() => _isGroupedInput = v),
                        ),
                      ],
                    ),
                    if (!_isGroupedInput)
                      TextField(
                        controller: _rawCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              "Ej: 10.5, 20, 15.2 (separado por comas o espacios)",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _processRawData(),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _valCtrl,
                              decoration: const InputDecoration(
                                labelText: "Valor",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _freqCtrl,
                              decoration: const InputDecoration(
                                labelText: "Frecuencia",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            onPressed: _addGroupedPoint,
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_data.isNotEmpty) ...[
              // STATS CARDS
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatChip("Media", mean.toStringAsFixed(2)),
                  _StatChip("Mediana", quartiles[1].toStringAsFixed(2)),
                  _StatChip("Moda", mode.toStringAsFixed(2)),
                  _StatChip("Desv. Est.", stdDev.toStringAsFixed(2)),
                  _StatChip("Varianza", variance.toStringAsFixed(2)),
                  _StatChip("Asimetría", skew.toStringAsFixed(2)),
                  _StatChip("Curtosis", kurt.toStringAsFixed(2)),
                  _StatChip("Q1", quartiles[0].toStringAsFixed(2)),
                  _StatChip("Q3", quartiles[2].toStringAsFixed(2)),
                  _StatChip("Min", _data.reduce(math.min).toStringAsFixed(2)),
                  _StatChip("Max", _data.reduce(math.max).toStringAsFixed(2)),
                ],
              ),

              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showFreqTable(context, _data),
                icon: const Icon(Icons.table_chart),
                label: const Text("Ver Tabla de Frecuencias"),
              ),
              const SizedBox(height: 20),

              // GRAPH
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      // Histogram (approximated by points for now)
                      LineChartBarData(
                        spots: _getHistogramSpots(_data),
                        isCurved: false,
                        color: Colors.indigo.withOpacity(0.5),
                        barWidth: 2,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.indigo.withOpacity(0.2),
                        ),
                      ),
                      // Normal Curve
                      LineChartBarData(
                        spots: _getNormalCurveSpots(mean, stdDev, _data),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getHistogramSpots(List<double> data) {
    if (data.isEmpty) return [];
    data.sort();
    // Simple frequency count
    Map<double, int> freqs = {};
    for (var x in data) {
      freqs[x] = (freqs[x] ?? 0) + 1;
    }
    return freqs.entries.map((e) => FlSpot(e.key, e.value.toDouble())).toList();
  }

  List<FlSpot> _getNormalCurveSpots(
    double mean,
    double stdDev,
    List<double> data,
  ) {
    if (stdDev == 0) return [];
    double min = data.first;
    double max = data.last;
    double range = max - min;
    double step = range / 50;
    if (step == 0) step = 0.1;

    List<FlSpot> spots = [];
    double maxFreq = 0; // To scale the curve
    // Find max freq roughly
    Map<double, int> freqs = {};
    for (var x in data) freqs[x] = (freqs[x] ?? 0) + 1;
    if (freqs.isNotEmpty) maxFreq = freqs.values.reduce(math.max).toDouble();

    // Normal PDF max value is roughly 0.4 / stdDev
    double pdfMax = 1 / (stdDev * math.sqrt(2 * math.pi));
    double scaleFactor = maxFreq / pdfMax;

    for (double x = min - range * 0.2; x <= max + range * 0.2; x += step) {
      double y =
          (1 / (stdDev * math.sqrt(2 * math.pi))) *
          math.exp(-0.5 * math.pow((x - mean) / stdDev, 2));
      spots.add(FlSpot(x, y * scaleFactor));
    }
    return spots;
  }

  void _showFreqTable(BuildContext context, List<double> data) {
    Map<double, int> counts = {};
    for (var x in data) counts[x] = (counts[x] ?? 0) + 1;
    var sortedKeys = counts.keys.toList()..sort();

    int n = data.length;
    int cumFreq = 0;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Tabla de Frecuencias",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('xi')),
                      DataColumn(label: Text('fi')),
                      DataColumn(label: Text('fr')),
                      DataColumn(label: Text('Fi')),
                      DataColumn(label: Text('Fr')),
                    ],
                    rows: sortedKeys.map((k) {
                      int f = counts[k]!;
                      double fr = f / n;
                      cumFreq += f;
                      double Fr = cumFreq / n;
                      return DataRow(
                        cells: [
                          DataCell(Text(k.toString())),
                          DataCell(Text(f.toString())),
                          DataCell(Text(fr.toStringAsFixed(3))),
                          DataCell(Text(cumFreq.toString())),
                          DataCell(Text(Fr.toStringAsFixed(3))),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. DISTRIBUTION CALCULATOR
// ==========================================

class DistributionCalculatorScreen extends StatefulWidget {
  const DistributionCalculatorScreen({super.key});

  @override
  State<DistributionCalculatorScreen> createState() =>
      _DistributionCalculatorScreenState();
}

class _DistributionCalculatorScreenState
    extends State<DistributionCalculatorScreen> {
  String _selectedDist = 'Normal';
  final TextEditingController _p1Ctrl = TextEditingController();
  final TextEditingController _p2Ctrl = TextEditingController();
  final TextEditingController _valCtrl =
      TextEditingController(); // Can be x or p

  String _result = "";

  // 0: Find Probability (P), 1: Find Critical Value (X)
  int _targetMode = 0;
  // 'eq': =, 'lt': <, 'le': <=, 'gt': >, 'ge': >=
  String _relation = 'le';

  @override
  void dispose() {
    _p1Ctrl.dispose();
    _p2Ctrl.dispose();
    _valCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    double? p1 = double.tryParse(_p1Ctrl.text);
    double? p2 = double.tryParse(_p2Ctrl.text);
    double? val = double.tryParse(_valCtrl.text);

    if (val == null) {
      setState(() => _result = "Por favor ingrese un valor válido.");
      return;
    }

    // Validation for Probability Input
    if (_targetMode == 1 && (val < 0 || val > 1)) {
      setState(() => _result = "La probabilidad debe estar entre 0 y 1.");
      return;
    }

    String resText = "";
    try {
      resText = _compute(p1, p2, val);
      setState(() => _result = resText);
    } catch (e) {
      setState(
        () => _result = "Error: ${e.toString().replaceAll("Exception: ", "")}",
      );
    }
  }

  String _compute(double? p1, double? p2, double val) {
    bool isDiscrete = [
      'Binomial',
      'Poisson',
      'Geométrica',
    ].contains(_selectedDist);
    // Helper to check standard PPF support (inverse)
    bool supportsInverse =
        !isDiscrete && !['Exponencial', 'Uniforme'].contains(_selectedDist);
    // Actually exp/uniform invers moved to MathUtils? Check implementation.
    // In previous steps I saw exp/uniform PPF errors "not supported".
    // I will stick to what is safe or what I can implement easily.

    // For this Turn, I will assume only Normal, t, Chi, F, Gamma support PPF fully in MathUtils safe calls
    // But I will try to support others if logical.

    if (_targetMode == 1) {
      // FIND CRITICAL VALUE (X) given Prob (val)
      if (!supportsInverse)
        return "Cálculo inverso no soportado para $_selectedDist";
      if (_relation == 'eq')
        return "No se puede calcular inverso para igualdad exacta.";

      // Transform P based on relation to Standard Left Tail P(X <= x)
      double targetP = val;
      if (_relation == 'gt' || _relation == 'ge') {
        targetP = 1.0 - val;
      }
      // For Continuous, < and <= are same. > and >= are same.

      double x = 0;
      switch (_selectedDist) {
        case 'Normal':
          x = MathUtils.normalPpf(targetP, p1 ?? 0, p2 ?? 1);
          break;
        case 't-Student':
          x = MathUtils.tPpf(targetP, p1 ?? 1);
          break;
        case 'Chi-Cuadrado':
          x = MathUtils.chi2Ppf(targetP, p1 ?? 1);
          break;
        case 'F-Snedecor':
          x = MathUtils.fPpf(targetP, p1 ?? 1, p2 ?? 1);
          break;
        case 'Gamma':
          x = MathUtils.gammaPpf(targetP, p1 ?? 1, p2 ?? 1);
          break;
      }
      return "Para P = $val ($_relation):\nX ≈ ${x.toStringAsFixed(5)}";
    } else {
      // FIND PROBABILITY (P) given X (val)
      // Logic for relations
      // Continuous: <=, < => CDF. >=, > => 1-CDF. = => PDF.
      // Discrete:
      // <= x  -> cdf(floor(x))
      // < x   -> cdf(ceil(x) - 1)
      // >= x  -> 1 - P(< x)
      // > x   -> 1 - P(<= x)
      // = x   -> pmf(x) if integer, else 0

      if (isDiscrete) {
        return _computeDiscreteP(p1, p2, val);
      } else {
        return _computeContinuousP(p1, p2, val);
      }
    }
  }

  String _computeContinuousP(double? p1, double? p2, double x) {
    double cdf = 0;
    double pdf = 0;

    // Calc CDF/PDF based on dist
    switch (_selectedDist) {
      case 'Normal':
        cdf = MathUtils.normalCdf(x, p1 ?? 0, p2 ?? 1);
        pdf = MathUtils.pdfNormal(x, p1 ?? 0, p2 ?? 1);
        break;
      case 't-Student':
        cdf = MathUtils.tCdf(x, p1 ?? 1);
        pdf = MathUtils.tPdf(x, p1 ?? 1);
        break;
      case 'Chi-Cuadrado':
        cdf = MathUtils.chi2Cdf(x, p1 ?? 1);
        pdf = MathUtils.chi2Pdf(x, p1 ?? 1);
        break;
      case 'F-Snedecor':
        cdf = MathUtils.fCdf(x, p1 ?? 1, p2 ?? 1);
        pdf = MathUtils.fPdf(x, p1 ?? 1, p2 ?? 1);
        break;
      case 'Gamma':
        cdf = MathUtils.gammaCdf(x, p1 ?? 1, p2 ?? 1);
        pdf = MathUtils.gammaPdf(x, p1 ?? 1, p2 ?? 1);
        break;
      case 'Exponencial':
        cdf = MathUtils.exponentialCdf(x, p1 ?? 1);
        pdf = MathUtils.pdfExponential(x, p1 ?? 1);
        break;
      case 'Uniforme':
        cdf = MathUtils.uniformCdf(x, p1 ?? 0, p2 ?? 1);
        pdf = MathUtils.pdfUniform(x, p1 ?? 0, p2 ?? 1);
        break;
    }

    if (_relation == 'eq')
      return "f($x) = ${pdf.toStringAsFixed(5)} (Densidad)";

    double res = 0;
    String sign = "";

    if (_relation == 'le' || _relation == 'lt') {
      res = cdf;
      sign = _relation == 'le' ? "≤" : "<";
    } else {
      res = 1 - cdf;
      sign = _relation == 'ge' ? "≥" : ">";
    }

    String formula = _getFormula(_selectedDist, sign, x, p1, p2);

    return "P(X $sign $x) =\n$formula\n= ${res.toStringAsFixed(5)}";
  }

  String _computeDiscreteP(double? p1, double? p2, double val) {
    int k_le = val.floor();
    int k_lt = val.ceil() - 1;
    bool isInt = (val - val.round()).abs() < 1e-9;

    double getCdf(int k) {
      switch (_selectedDist) {
        case 'Binomial':
          return MathUtils.binomialCdf(k, (p1 ?? 10).toInt(), p2 ?? 0.5);
        case 'Poisson':
          return MathUtils.poissonCdf(k, p1 ?? 1);
        case 'Geométrica':
          return MathUtils.geometricCdf(k, p1 ?? 0.5);
        default:
          return 0;
      }
    }

    double getPmf(int k) {
      switch (_selectedDist) {
        case 'Binomial':
          return MathUtils.binomialPmf(k, (p1 ?? 10).toInt(), p2 ?? 0.5);
        case 'Poisson':
          return MathUtils.poissonPmf(k, p1 ?? 1);
        case 'Geométrica':
          return MathUtils.geometricPmf(k, p1 ?? 0.5);
        default:
          return 0;
      }
    }

    if (_relation == 'eq') {
      if (!isInt) return "P(X = $val) = 0 (No entero)";
      String formula = _getFormula(_selectedDist, "=", val, p1, p2);
      return "P(X = ${val.toInt()}) = $formula\n= ${getPmf(val.round()).toStringAsFixed(5)}";
    }

    double res = 0;
    String sign = "";

    if (_relation == 'le') {
      res = getCdf(k_le);
      sign = "≤";
    } else if (_relation == 'lt') {
      res = getCdf(k_lt);
      sign = "<";
    } else if (_relation == 'ge') {
      res = 1 - getCdf(k_lt);
      sign = "≥";
    } else if (_relation == 'gt') {
      res = 1 - getCdf(k_le);
      sign = ">";
    }

    String formula = _getFormula(_selectedDist, sign, val, p1, p2);

    return "P(X $sign $val) =\n$formula\n= ${res.toStringAsFixed(5)}";
  }

  String _getFormula(
    String dist,
    String sign,
    double val,
    double? p1,
    double? p2,
  ) {
    String p1s = (p1 ?? 0).toString();
    String p2s = (p2 ?? 0).toString();
    String xs = val.toString();

    bool isUpper = sign == '>' || sign == '≥';

    switch (dist) {
      case 'Normal':
        if (isUpper) return "∫($xs to ∞) (1/σ√2π)·e^(-½((t-μ)/σ)²) dt";
        return "∫(-∞ to $xs) (1/σ√2π)·e^(-½((t-μ)/σ)²) dt";

      case 'Exponencial':
        if (isUpper) return "e^(-λ·$xs)";
        return "1 - e^(-λ·$xs)";

      case 'Uniforme':
        if (isUpper) return "(b - $xs) / (b - a)";
        return "($xs - a) / (b - a)";

      case 'Binomial':
        if (sign == '=') return "nCx · p^x · (1-p)^(n-x)";
        if (isUpper) return "Σ(k=$xs to n) [nCk · p^k · (1-p)^(n-k)]";
        return "Σ(k=0 to $xs) [nCk · p^k · (1-p)^(n-k)]";

      case 'Poisson':
        if (sign == '=') return "(e^(-λ) · λ^x) / x!";
        if (isUpper) return "1 - Σ(i=0 to $xs) [(e^(-λ)λ^i)/i!]";
        return "Σ(i=0 to $xs) [(e^(-λ)λ^i)/i!]";

      case 'Geométrica':
        if (sign == '=') return "(1-p)^(x-1) · p";
        if (isUpper) return "(1-p)^$xs";
        return "1 - (1-p)^$xs";

      case 'Gamma':
        return isUpper ? "1 - (1/Γ(α))·γ(α, β·x)" : "(1/Γ(α))·γ(α, β·x)";

      default:
        if (isUpper) return "1 - CDF($xs)";
        return "CDF($xs)";
    }
  }

  String _getP1Label() {
    switch (_selectedDist) {
      case 'Normal':
        return "Media (μ)";
      case 't-Student':
        return "Grados de libertad (df)";
      case 'Chi-Cuadrado':
        return "Grados de libertad (k)";
      case 'F-Snedecor':
        return "Grados libertad num (d1)";
      case 'Gamma':
        return "Forma (α)";
      case 'Binomial':
        return "Ensayos (n)";
      case 'Poisson':
        return "Tasa (λ)";
      case 'Exponencial':
        return "Tasa (λ)";
      case 'Uniforme':
        return "Mínimo (a)";
      case 'Geométrica':
        return "Prob. Éxito (p)";
      default:
        return "Parámetro 1";
    }
  }

  String? _getP2Label() {
    switch (_selectedDist) {
      case 'Normal':
        return "Desviación (σ)";
      case 'F-Snedecor':
        return "Grados libertad den (d2)";
      case 'Gamma':
        return "Escala (β)";
      case 'Binomial':
        return "Prob. Éxito (p)";
      case 'Uniforme':
        return "Máximo (b)";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Distribuciones'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDist,
              items: [
                'Normal',
                't-Student',
                'Chi-Cuadrado',
                'F-Snedecor',
                'Gamma',
                'Binomial',
                'Poisson',
                'Exponencial',
                'Uniforme',
                'Geométrica',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedDist = v!;
                  _result = "";
                });
              },
              decoration: const InputDecoration(
                labelText: "Distribución",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _p1Ctrl,
              decoration: InputDecoration(
                labelText: _getP1Label(),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            if (_getP2Label() != null) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _p2Ctrl,
                decoration: InputDecoration(
                  labelText: _getP2Label(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),

            // Mode Selection
            const Text(
              "Tipo de Cálculo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Probabilidad (P)"),
                    value: 0,
                    groupValue: _targetMode,
                    onChanged: (v) => setState(() => _targetMode = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Valor X (Inverso)"),
                    value: 1,
                    groupValue: _targetMode,
                    onChanged: (v) => setState(() => _targetMode = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                // Inequality Dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _relation,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'eq',
                        child: Text(
                          "Igual a (X = x)",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'le',
                        child: Text(
                          "Menor o Igual (X ≤ x)",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'lt',
                        child: Text(
                          "Menor que (X < x)",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ge',
                        child: Text(
                          "Mayor o Igual (X ≥ x)",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'gt',
                        child: Text(
                          "Mayor que (X > x)",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _relation = v!),
                    decoration: const InputDecoration(
                      labelText: "Relación",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _valCtrl,
                    decoration: InputDecoration(
                      labelText: _targetMode == 0
                          ? "Valor X"
                          : "Probabilidad P",
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Calcular"),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. HYPOTHESIS TEST
// ==========================================

class HypothesisTestScreen extends StatefulWidget {
  const HypothesisTestScreen({super.key});

  @override
  State<HypothesisTestScreen> createState() => _HypothesisTestScreenState();
}

class _HypothesisTestScreenState extends State<HypothesisTestScreen> {
  final TextEditingController _dataCtrl = TextEditingController();
  final TextEditingController _muCtrl = TextEditingController();
  final TextEditingController _alphaCtrl = TextEditingController(text: "0.05");

  String _result = "";

  void _runTest() {
    String text = _dataCtrl.text.replaceAll(',', ' ');
    List<double> data = [];
    for (var item in text.split(' ')) {
      if (item.trim().isNotEmpty) {
        double? val = double.tryParse(item.trim());
        if (val != null) data.add(val);
      }
    }

    double? mu0 = double.tryParse(_muCtrl.text);
    double? alpha = double.tryParse(_alphaCtrl.text);

    if (data.isEmpty || mu0 == null || alpha == null) {
      setState(() => _result = "Por favor ingrese datos válidos.");
      return;
    }

    int n = data.length;
    double xBar = MathUtils.mean(data);
    double s = MathUtils.stdDev(data, isSample: true);
    double se = s / math.sqrt(n);
    double tStat = (xBar - mu0) / se;
    int df = n - 1;

    // P-Value using t-distribution
    double pValue =
        2 * (1 - MathUtils.tCdf(tStat.abs(), df.toDouble())); // Two-tailed

    bool reject = pValue < alpha;

    setState(() {
      _result =
          """
Resultados:
n = $n
Media (x̄) = ${xBar.toStringAsFixed(4)}
Desv. Est (s) = ${s.toStringAsFixed(4)}
t-statistic = ${tStat.toStringAsFixed(4)}
p-value = ${pValue.toStringAsFixed(4)}

Decisión: ${reject ? "RECHAZAR H0" : "NO RECHAZAR H0"}
${reject ? "Hay evidencia suficiente para decir que la media es diferente de $mu0" : "No hay evidencia suficiente."}
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba t (1 muestra)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Datos de la Muestra",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _dataCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Ej: 10, 12, 11.5",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Parámetros de la Prueba",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _muCtrl,
                    decoration: const InputDecoration(
                      labelText: "Media Hipotética (H0)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _alphaCtrl,
                    decoration: const InputDecoration(
                      labelText: "Significancia (α)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Ejecutar Prueba"),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
