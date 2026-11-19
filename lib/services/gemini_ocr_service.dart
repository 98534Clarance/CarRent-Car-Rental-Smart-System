// Finalized Gemini Flash OCR Integration & Fallback (FR-AI-01 to FR-AI-04)
// Issue #7 — @eidraky

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

class CustomerOcrData {
  final String fullName;
  final String icOrPassport;
  final String licenseNumber;
  final String licenseExpiry;
  final String address;
  final double confidenceScore;

  CustomerOcrData({
    this.fullName = '',
    this.icOrPassport = '',
    this.licenseNumber = '',
    this.licenseExpiry = '',
    this.address = '',
    this.confidenceScore = 0.0,
  });

  factory CustomerOcrData.fromJson(Map<String, dynamic> json) {
    return CustomerOcrData(
      fullName: (json['full_name'] ?? '').toString(),
      icOrPassport: (json['ic_or_passport'] ?? '').toString(),
      licenseNumber: (json['license_number'] ?? '').toString(),
      licenseExpiry: (json['license_expiry'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      confidenceScore: (json['confidence_score'] is num)
          ? (json['confidence_score'] as num).toDouble()
          : 0.0,
    );
  }
}

class OcrScanResult {
  final bool success;
  final bool fallbackToManual;
  final String entryMethod; // 'ocr' or 'manual_fallback'
  final CustomerOcrData? data;
  final String message;
  final int durationMs;

  OcrScanResult({
    required this.success,
    required this.fallbackToManual,
    required this.entryMethod,
    this.data,
    required this.message,
    required this.durationMs,
  });
}

class GeminiOcrService {
  static const Duration ocrTimeout = Duration(seconds: 20); // FR-AI-03
  static const double minConfidence = 0.75;

  /// FR-AI-01: Compress image to 1280px max width, 75% JPEG quality, strip EXIF
  static Future<Uint8List> compressImageForOcr(Uint8List rawBytes) async {
    return await FlutterImageCompress.compressWithList(
      rawBytes,
      minWidth: 1280,
      minHeight: 720,
      quality: 75,
      keepExif: false, // PDPA 2010 data minimization
      format: CompressFormat.jpeg,
    );
  }

  /// FR-AI-02, FR-AI-03, FR-AI-04: Extract NRIC / Licence details with 20s timeout & fallback
  static Future<OcrScanResult> scanCustomerId({
    required Uint8List imageBytes,
    required bool pdpaConsentConfirmed,
    required String geminiApiKey,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (!pdpaConsentConfirmed) {
      stopwatch.stop();
      return OcrScanResult(
        success: false,
        fallbackToManual: true,
        entryMethod: 'manual_fallback',
        message: 'PDPA 2010 consent is required before scanning ID documents.',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    }

    try {
      final compressedBytes = await compressImageForOcr(imageBytes);
      final base64Image = base64Encode(compressedBytes);

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey',
      );

      const prompt = '''
Extract customer identification details from this Malaysian Driving License or NRIC/Passport.
Return a JSON object with:
- full_name (string, uppercase as printed)
- ic_or_passport (string, format XXXXXX-XX-XXXX if Malaysian IC)
- license_number (string, if same as IC, repeat IC number)
- license_expiry (string, YYYY-MM-DD format, or empty string if not visible)
- address (string, full residential address if visible)
- confidence_score (number between 0.0 and 1.0 indicating legibility)
''';

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Image,
                      }
                    }
                  ]
                }
              ],
              'generationConfig': {
                'responseMimeType': 'application/json',
                'temperature': 0.1,
              }
            }),
          )
          .timeout(ocrTimeout);

      stopwatch.stop();

      if (response.statusCode != 200) {
        throw Exception('Gemini HTTP ${response.statusCode}');
      }

      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      final rawText =
          bodyJson['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (rawText == null || rawText.toString().isEmpty) {
        throw Exception('Empty OCR payload');
      }

      final parsed = CustomerOcrData.fromJson(
        jsonDecode(rawText.toString()) as Map<String, dynamic>,
      );

      final hasCoreFields = parsed.fullName.trim().isNotEmpty &&
          parsed.icOrPassport.trim().isNotEmpty;

      if (!hasCoreFields || parsed.confidenceScore < minConfidence) {
        return OcrScanResult(
          success: false,
          fallbackToManual: true,
          entryMethod: 'manual_fallback',
          data: parsed,
          message:
              'Low legibility (<75% confidence). Switched to manual input.',
          durationMs: stopwatch.elapsedMilliseconds,
        );
      }

      return OcrScanResult(
        success: true,
        fallbackToManual: false,
        entryMethod: 'ocr',
        data: parsed,
        message:
            'Read by AI (${(parsed.confidenceScore * 100).round()}% confidence). Check each field.',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } on TimeoutException {
      stopwatch.stop();
      return OcrScanResult(
        success: false,
        fallbackToManual: true,
        entryMethod: 'manual_fallback',
        message:
            'Timed out after 20s. Switched to manual input (entry_method: manual_fallback).',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (_) {
      stopwatch.stop();
      return OcrScanResult(
        success: false,
        fallbackToManual: true,
        entryMethod: 'manual_fallback',
        message: 'OCR service unavailable. Switched to manual input.',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    }
  }
}
