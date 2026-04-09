import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

// Firmas nativas modulares C/C++ actualizadas al nuevo diseño de stat_engine.h
typedef StatCriticalZNative = ffi.Double Function(ffi.Double alpha, ffi.Bool twoTailed);
typedef StatPValueZNative = ffi.Double Function(ffi.Double stat, ffi.Int32 tailType);
typedef StatSampleSizeNative = ffi.Int32 Function(ffi.Double alpha, ffi.Double power, ffi.Double delta, ffi.Double variance, ffi.Bool twoTailed);

// Firmas expuestas a Dart preservadas para compatibilidad con el viejo HypothesisOrchestrator
typedef CalculateZCriticalDart = double Function(double alpha, bool twoTailed);
typedef CalculateZCdfDart = double Function(double z);
typedef CalculateSampleSizeDart = int Function(double alpha, double power, double delta, double variance, bool twoTailed);

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
      _lib = ffi.DynamicLibrary.process(); 
    } else if (Platform.isWindows) {
      _lib = ffi.DynamicLibrary.open('stat_engine.dll');
    } else {
      throw UnsupportedError('Plataforma no soportada para motor matemático FFI');
    }
  }

  void _bindFunctions() {
    // El Orquestador viejo llamaba a 'calculate_z_cdf' para saber el área a la izquierda del estadístico
    // Nuestra nueva arquitectura usa "stat_pvalue_z", cuyo tag de cola '-1' calcula P(Z < z) exacto
    final pvalueFunc = _lib.lookupFunction<StatPValueZNative, double Function(double, int)>('stat_pvalue_z');
    calculateZCdf = (double z) => pvalueFunc(z, -1);
    
    // El resto cambian 1:1 de acuerdo a los nuevos modulos exportados
    calculateZCritical = _lib.lookupFunction<StatCriticalZNative, CalculateZCriticalDart>(
      'stat_critical_z',
    );
    
    calculateSampleSize = _lib.lookupFunction<StatSampleSizeNative, CalculateSampleSizeDart>(
      'stat_sample_size_mean',
    );
  }
}
