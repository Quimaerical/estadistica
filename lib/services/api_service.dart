import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const platform = MethodChannel('com.example.calculadora_estadistica/inference');

  static Future<Map<String, dynamic>> analyzeDistribution(String distribution, {List<double>? sampleData}) async {
    // 1. Android Offline Mode (Chaquopy)
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final String? sampleDataJson = sampleData != null ? jsonEncode(sampleData) : null;
        final String resultJson = await platform.invokeMethod('analyze', {
          'distribution': distribution,
          'sample_data': sampleDataJson,
        });
        return jsonDecode(resultJson);
      } on PlatformException catch (e) {
        throw Exception("Android Offline Error: ${e.message}");
      }
    }

    // 2. HTTP Mode for Web/Windows/iOS
    final url = Uri.parse('$baseUrl/analyze');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'distribution': distribution,
          'sample_data': sampleData,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to analyze distribution: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to API ($baseUrl): $e');
    }
  }
}
