// Basic Gemini Flash OCR draft by @eidraky
// Issue #7: Extract customer NRIC and driving license details

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CustomerOcrData {
  final String fullName;
  final String icOrPassport;
  final String licenseNumber;
  final String licenseExpiry;
  final String address;

  CustomerOcrData({
    this.fullName = '',
    this.icOrPassport = '',
    this.licenseNumber = '',
    this.licenseExpiry = '',
    this.address = '',
  });

  factory CustomerOcrData.fromJson(Map<String, dynamic> json) {
    return CustomerOcrData(
      fullName: (json['full_name'] ?? '').toString(),
      icOrPassport: (json['ic_or_passport'] ?? '').toString(),
      licenseNumber: (json['license_number'] ?? '').toString(),
      licenseExpiry: (json['license_expiry'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }
}

class GeminiOcrService {
  static Future<CustomerOcrData?> scanCustomerId({
    required Uint8List imageBytes,
    required String geminiApiKey,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey',
      );

      const prompt =
          'Extract full_name, ic_or_passport, license_number, license_expiry (YYYY-MM-DD), and address from this Malaysian IC or driving license in JSON.';

      final response = await http.post(
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
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text = body['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text == null) return null;

      return CustomerOcrData.fromJson(
        jsonDecode(text.toString()) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
