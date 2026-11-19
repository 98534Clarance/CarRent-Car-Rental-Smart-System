import 'dart:async';
import 'package:flutter/material.dart';

enum OcrViewState { scanning20s, aiVerified, manualFallback }

class ScanCustomerScreen extends StatefulWidget {
  const ScanCustomerScreen({super.key});

  @override
  State<ScanCustomerScreen> createState() => _ScanCustomerScreenState();
}

class _ScanCustomerScreenState extends State<ScanCustomerScreen> {
  static const Color _primary = Color(0xFF0E4D64);
  static const Color _primaryLight = Color(0xFFEAF3F6);
  static const Color _accentAmber = Color(0xFFF2A900);
  static const Color _textDark = Color(0xFF1B2630);
  static const Color _border = Color(0xFFB7C2C9);
  static const Color _maintAmberBg = Color(0xFFFCEBC2);
  static const Color _maintAmberText = Color(0xFF7A5300);
  static const Color _dangerRed = Color(0xFFC0392B);
  static const Color _dangerBg = Color(0xFFFDF2F2);

  OcrViewState _state = OcrViewState.aiVerified;
  bool _pdpaConsent = true;
  int _secondsRemaining = 20;
  Timer? _timer;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _icCtrl;
  late final TextEditingController _licNoCtrl;
  late final TextEditingController _licExpCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addrCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Ahmad Faiz bin Hassan');
    _icCtrl = TextEditingController(text: '990412-13-5521');
    _licNoCtrl = TextEditingController(text: '990412-13-5521');
    _licExpCtrl = TextEditingController(text: '2028-03-18');
    _phoneCtrl = TextEditingController(text: '012-345 6789');
    _addrCtrl =
        TextEditingController(text: 'Taman Desa Ilmu, 94300 Kota Samarahan');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameCtrl.dispose();
    _icCtrl.dispose();
    _licNoCtrl.dispose();
    _licExpCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  void _start20sCountdown() {
    if (!_pdpaConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDPA 2010 consent is required before scanning ID.'),
        ),
      );
      return;
    }
    _timer?.cancel();
    setState(() {
      _state = OcrViewState.scanning20s;
      _secondsRemaining = 20;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _triggerManualFallback();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _triggerAiVerified() {
    _timer?.cancel();
    setState(() {
      _state = OcrViewState.aiVerified;
      _nameCtrl.text = 'Ahmad Faiz bin Hassan';
      _icCtrl.text = '990412-13-5521';
      _licNoCtrl.text = '990412-13-5521';
      _licExpCtrl.text = '2028-03-18';
      _addrCtrl.text = 'Taman Desa Ilmu, 94300 Kota Samarahan';
    });
  }

  void _triggerManualFallback() {
    _timer?.cancel();
    setState(() {
      _state = OcrViewState.manualFallback;
      _licNoCtrl.clear();
      _licExpCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAiMode = _state == OcrViewState.aiVerified;
    final isFallbackMode = _state == OcrViewState.manualFallback;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _state == OcrViewState.scanning20s
                      ? 'Scanning IC (FR-AI-03)'
                      : isFallbackMode
                          ? 'Enter customer details'
                          : 'Check customer details',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: _start20sCountdown,
                child: const Text('Test 20s Timer'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 118,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF26343E),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 245,
              height: 86,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: _accentAmber, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'IC photo from WhatsApp / Camera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _accentAmber,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _state == OcrViewState.scanning20s
                        ? 'FR-AI-01: 1280px JPEG · ${_secondsRemaining}s / 20s limit'
                        : '1280px JPEG · EXIF stripped (FR-AI-01)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_state == OcrViewState.scanning20s) ...[
            LinearProgressIndicator(
              value: (20 - _secondsRemaining) / 20,
              backgroundColor: const Color(0xFFDCE2E4),
              color: _primary,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _triggerAiVerified,
                    child: const Text('Simulate AI Success'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _triggerManualFallback,
                    child: const Text('Simulate 20s Timeout'),
                  ),
                ),
              ],
            ),
          ] else if (isAiMode) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _accentAmber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Read by AI (94% confidence · entry_method: ocr). Check each field.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A2900),
                ),
              ),
            ),
          ] else if (isFallbackMode) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _maintAmberBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accentAmber),
              ),
              child: const Text(
                'FR-AI-04: Timed out after 20s (or low legibility). Switched to manual input (entry_method: manual_fallback).',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _maintAmberText,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _fieldLabel(isAiMode ? 'Full name (AI)' : 'Full name *'),
          _inputBox(_nameCtrl, aiFilled: isAiMode),
          const SizedBox(height: 10),
          _fieldLabel(isAiMode
              ? 'IC / Passport number (AI)'
              : 'IC / Passport number *'),
          _inputBox(_icCtrl, aiFilled: isAiMode),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Licence no. *'),
                    _inputBox(
                      _licNoCtrl,
                      aiFilled: isAiMode,
                      hasError: isFallbackMode && _licNoCtrl.text.isEmpty,
                      hint: 'Add manually',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Licence expiry *'),
                    _inputBox(
                      _licExpCtrl,
                      aiFilled: isAiMode,
                      hasError: isFallbackMode && _licExpCtrl.text.isEmpty,
                      hint: 'YYYY-MM-DD',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _fieldLabel('Phone *'),
          _inputBox(_phoneCtrl),
          const SizedBox(height: 10),
          _fieldLabel(isAiMode ? 'Address (AI)' : 'Address'),
          _inputBox(_addrCtrl, aiFilled: isAiMode),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _pdpaConsent,
                activeColor: _primary,
                onChanged: (v) => setState(() => _pdpaConsent = v ?? false),
              ),
              const Expanded(
                child: Text(
                  'Customer agreed to our PDPA 2010 personal data notice',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Saved customer (${isAiMode ? "entry_method: ocr" : "entry_method: manual_fallback"})',
                    ),
                  ),
                );
              },
              child: Text(
                isFallbackMode ? 'Save manual customer' : 'Save customer',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed:
                  isFallbackMode ? _triggerAiVerified : _triggerManualFallback,
              child: Text(
                isFallbackMode
                    ? 'Switch back to AI Verified view'
                    : 'Enter details by hand (FR-AI-04)',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF44545F),
        ),
      ),
    );
  }

  Widget _inputBox(
    TextEditingController ctrl, {
    bool aiFilled = false,
    bool hasError = false,
    String? hint,
  }) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 14, color: _textDark),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: hasError
              ? _dangerBg
              : aiFilled
                  ? _primaryLight
                  : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasError
                  ? _dangerRed
                  : aiFilled
                      ? _primary
                      : _border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
        ),
      ),
    );
  }
}
