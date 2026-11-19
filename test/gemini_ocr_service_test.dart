import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:carrent_smart_system/services/gemini_ocr_service.dart';

void main() {
  group('Issue #7 GeminiOcrService Guardrails', () {
    test('Blocks scan and triggers manual_fallback when PDPA consent is false',
        () async {
      final result = await GeminiOcrService.scanCustomerId(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        pdpaConsentConfirmed: false,
        geminiApiKey: 'dummy-key',
      );

      expect(result.success, isFalse);
      expect(result.fallbackToManual, isTrue);
      expect(result.entryMethod, equals('manual_fallback'));
      expect(result.message, contains('PDPA 2010'));
    });

    test('Parses valid OCR JSON payload into CustomerOcrData', () {
      final data = CustomerOcrData.fromJson({
        'full_name': 'AHMAD FAIZ BIN HASSAN',
        'ic_or_passport': '990412-13-5521',
        'license_number': '990412-13-5521',
        'license_expiry': '2028-03-18',
        'address': 'Taman Desa Ilmu, 94300 Kota Samarahan',
        'confidence_score': 0.94,
      });

      expect(data.fullName, equals('AHMAD FAIZ BIN HASSAN'));
      expect(data.confidenceScore, equals(0.94));
    });
  });
}
