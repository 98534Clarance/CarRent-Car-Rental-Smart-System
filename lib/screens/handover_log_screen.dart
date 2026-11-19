import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HandoverLogScreen extends StatefulWidget {
  const HandoverLogScreen({super.key});

  @override
  State<HandoverLogScreen> createState() => _HandoverLogScreenState();
}

class _HandoverLogScreenState extends State<HandoverLogScreen> {
  bool _isPickup = true;
  double _fuelLevel = 75;
  bool _damageFound = true;
  bool _customerAck = true;
  final List<bool> _photoSlots = [true, true, true, false];

  final _odoCtrl = TextEditingController(text: '31,420');
  final _notesCtrl =
      TextEditingController(text: 'Small scratch on rear left bumper');

  @override
  void dispose() {
    _odoCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final labels = ['Front', 'Rear', 'Left', 'Right'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Handover inspection',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'QAA 1111 · Ahmad Faiz · 10 Dec, 10:00',
            style: TextStyle(fontSize: 14, color: AppColors.textSub),
          ),
          const SizedBox(height: 14),

          // Pick-up / Return Segmented Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE7ECEE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                _segmentTab('Pick-up', true),
                _segmentTab('Return', false),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Odometer (km)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF44545F),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _odoCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Fuel level: ${_fuelLevel.round()}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF44545F),
            ),
          ),
          Slider(
            value: _fuelLevel,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _fuelLevel = val),
          ),

          const Text(
            'Condition notes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF44545F),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Checkbox(
                value: _damageFound,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _damageFound = v ?? false),
              ),
              const Text('Damage found', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),

          // Interactive 4-Angle Photo Upload Slots
          Row(
            children: List.generate(4, (i) {
              final uploaded = _photoSlots[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _photoSlots[i] = !_photoSlots[i]),
                  child: Container(
                    height: 72,
                    margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: uploaded
                          ? const Color(0xFFCBD5DA)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: uploaded
                          ? null
                          : Border.all(
                              color: const Color(0xFF8A9AA5),
                              width: 1.5,
                            ),
                    ),
                    child: Text(
                      uploaded ? '✓ ${labels[i]}' : '+ ${labels[i]}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            uploaded ? FontWeight.w700 : FontWeight.w500,
                        color:
                            uploaded ? AppColors.textDark : AppColors.textSub,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(
                value: _customerAck,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _customerAck = v ?? false),
              ),
              const Expanded(
                child: Text(
                  'Customer has seen and acknowledged these details',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                if (!_customerAck) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Customer must acknowledge inspection details first.'),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${_isPickup ? "Pick-up" : "Return"} handover log submitted!',
                    ),
                  ),
                );
              },
              child: const Text(
                'Submit log',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Submitted logs cannot be edited by runners (BR-05).',
            style: TextStyle(fontSize: 12, color: AppColors.textSub),
          ),
        ],
      ),
    );
  }

  Widget _segmentTab(String title, bool pickupValue) {
    final selected = _isPickup == pickupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isPickup = pickupValue),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSub,
            ),
          ),
        ),
      ),
    );
  }
}
