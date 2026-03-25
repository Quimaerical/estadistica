import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

// Firmas nativas (C/C++)
typedef CalculateZCriticalC = ffi.Double Function(ffi.Double alpha, ffi.Bool twoTailed);
typedef CalculateZCdfC = ffi.Double Function(ffi.Double z);
typedef CalculateSampleSizeC = ffi.Int32 Function(ffi.Double alpha, ffi.Double power, ffi.Double delta, ffi.Double variance, ffi.Bool twoTailed);

// Firmas expuestas a Dart
typedef CalculateZCriticalDart = double Function(double alpha, bool twoTailed);
typedef CalculateZCdfDart = double Function(double z);
typedef CalculateSampleSizeDart = int Function(double alpha, double power, double delta, double variance, bool twoTailed);

/// Motor numérico estadístico centralizado consumiendo la librería C++ generada
class StatEngine {
  static final StatEngine _instance = StatEngine._internal();
  factory StatEngine() => _instance;

  late final ffi.DynamicLibrary _lib;
  late final CalculateZCriticalDart calculateZCritical;
  late final CalculateZCdfDart calculateZCdf;
  late final CalculateSampleSizeDart calculateSampleSize;

  StatEngine._internal() {
    _loadLibrary();
    _bindFunctions();
  }

  void _loadLibrary() {
    if (Platform.isAndroid || Platform.isLinux) {
      _lib = ffi.DynamicLibrary.open('libstat_engine.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      _lib = ffi.DynamicLibrary.process(); // Usualmente embebido en el dylib/framework principal
    } else if (Platform.isWindows) {
      _lib = ffi.DynamicLibrary.open('stat_engine.dll');
    } else {
      throw UnsupportedError('Plataforma no soportada para motor matemático FFI');
    }
  }

  void _bindFunctions() {
    calculateZCdf = _lib.lookupFunction<CalculateZCdfC, CalculateZCdfDart>(
      'calculate_z_cdf',
    );
    calculateZCritical = _lib.lookupFunction<CalculateZCriticalC, CalculateZCriticalDart>(
      'calculate_z_critical',
    );
    
    calculateSampleSize = _lib.lookupFunction<CalculateSampleSizeC, CalculateSampleSizeDart>(
      'calculate_sample_size',
    );
  }
}
