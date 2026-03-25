import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// Módulo 1: Valores Críticos (Z, T, Chi2, F)
typedef StatCriticalNative = Double Function(Double alpha, Bool twoTailed);
typedef StatCriticalDart = double Function(double alpha, bool twoTailed);

typedef StatCriticalTNative = Double Function(Double alpha, Int32 df, Bool twoTailed);
typedef StatCriticalTDart = double Function(double alpha, int df, bool twoTailed);

typedef StatCriticalChi2FNative = Double Function(Double alpha, Int32 df, Bool upperTail);
typedef StatCriticalChi2FDart = double Function(double alpha, int df, bool upperTail);

typedef StatCriticalFFNative = Double Function(Double alpha, Int32 df1, Int32 df2, Bool upperTail);
typedef StatCriticalFFDart = double Function(double alpha, int df1, int df2, bool upperTail);

// Módulo 2: Valores p (Z, T, Chi2, F)
typedef StatPValueNative = Double Function(Double stat, Int32 tailType);
typedef StatPValueDart = double Function(double stat, int tailType);

typedef StatPValueTDartNative = Double Function(Double stat, Int32 df, Int32 tailType);
typedef StatPValueTDart = double Function(double stat, int df, int tailType);

typedef StatPValueFDartNative = Double Function(Double stat, Int32 df1, Int32 df2, Int32 tailType);
typedef StatPValueFDart = double Function(double stat, int df1, int df2, int tailType);

class StatEngineFFI {
  static final StatEngineFFI _instance = StatEngineFFI._internal();
  factory StatEngineFFI() => _instance;
  
  late DynamicLibrary _lib;

  // Valores p
  late StatPValueDart statPValueZ;
  late StatPValueTDart statPValueT;
  late StatPValueTDart statPValueChi2;
  late StatPValueFDart statPValueF;

  // Valores críticos
  late StatCriticalDart statCriticalZ;
  late StatCriticalTDart statCriticalT;
  late StatCriticalChi2FDart statCriticalChi2;
  late StatCriticalFFDart statCriticalF;

  StatEngineFFI._internal() {
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libestadistica_native.so');
    } else if (Platform.isWindows) {
      _lib = DynamicLibrary.open('estadistica_native.dll');
    } else if (Platform.isIOS || Platform.isMacOS) {
      _lib = DynamicLibrary.process();
    } else {
      _lib = DynamicLibrary.open('libestadistica_native.so');
    }

    // P-Values
    statPValueZ = _lib.lookupFunction<StatPValueNative, StatPValueDart>('stat_pvalue_z');
    statPValueT = _lib.lookupFunction<StatPValueTDartNative, StatPValueTDart>('stat_pvalue_t');
    statPValueChi2 = _lib.lookupFunction<StatPValueTDartNative, StatPValueTDart>('stat_pvalue_chi2');
    statPValueF = _lib.lookupFunction<StatPValueFDartNative, StatPValueFDart>('stat_pvalue_f');

    // Valores Críticos
    statCriticalZ = _lib.lookupFunction<StatCriticalNative, StatCriticalDart>('stat_critical_z');
    statCriticalT = _lib.lookupFunction<StatCriticalTNative, StatCriticalTDart>('stat_critical_t');
    statCriticalChi2 = _lib.lookupFunction<StatCriticalChi2FNative, StatCriticalChi2FDart>('stat_critical_chi2');
    statCriticalF = _lib.lookupFunction<StatCriticalFFNative, StatCriticalFFDart>('stat_critical_f');
  }
}
