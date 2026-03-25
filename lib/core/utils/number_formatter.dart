class NumberFormatter {
  static const Map<String, String> _superscriptMap = {
    '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
    '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
    '-': '⁻', '+': '⁺'
  };

  static String _toSuperscriptTokens(String exponentStr) {
    return exponentStr.split('').map((char) => _superscriptMap[char] ?? char).join('');
  }

  /// Formatea un double garantizando máxima precisión visual.
  /// Intercepta p-valores muy pequeños (< 0.0001) o estatísticos grandes (>= 10000)
  /// y los retorna en formato amigable de notación científica con superíndices.
  static String format(double value, {int precision = 4}) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value.isNegative ? '-∞' : '∞';
    if (value == 0.0) return '0';

    final double absVal = value.abs();

    if (absVal < 0.0001 || absVal >= 10000) {
      final String sciStr = value.toStringAsExponential(precision);
      final List<String> parts = sciStr.split('e');
      
      if (parts.length == 2) {
        final double base = double.parse(parts[0]);
        final int exponent = int.parse(parts[1]);
        
        String baseStr = base.toStringAsFixed(precision);
        baseStr = baseStr.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
        if (baseStr.endsWith('.')) baseStr = baseStr.substring(0, baseStr.length - 1);

        final String superscriptExp = _toSuperscriptTokens(exponent.toString());
        return '$baseStr × 10$superscriptExp';
      }
      return sciStr; 
    } else {
      String str = value.toStringAsFixed(precision);
      if (str.contains('.')) {
        str = str.replaceAll(RegExp(r'0*$'), '');
        str = str.replaceAll(RegExp(r'\.$'), '');
      }
      return str;
    }
  }
}
