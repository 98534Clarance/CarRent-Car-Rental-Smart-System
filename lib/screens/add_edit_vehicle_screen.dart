import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final Vehicle? existingVehicle;
  const AddEditVehicleScreen({super.key, this.existingVehicle});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _plateCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _mileageCtrl;
  String _status = 'available';

  @override
  void dispose() {
    _plateCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _rateCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final v = widget.existingVehicle;
    _plateCtrl = TextEditingController(text: v?.plateNumber ?? '');
    _brandCtrl = TextEditingController(text: v?.brand ?? '');
    _modelCtrl = TextEditingController(text: v?.model ?? '');
    _yearCtrl = TextEditingController(text: v?.year.toString() ?? '2024');
    _colorCtrl = TextEditingController(text: v?.color ?? 'Silver');
    _rateCtrl = TextEditingController(
        text: v != null ? v.dailyRate.toStringAsFixed(0) : '130');
    _mileageCtrl =
        TextEditingController(text: v?.currentMileage.toString() ?? '0');
    _status = v?.status ?? 'available';
    
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final vehicle = Vehicle(
      id: widget.existingVehicle?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      plateNumber: _plateCtrl.text.trim().toUpperCase(),
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text.trim()) ?? 2024,
      color: _colorCtrl.text.trim(),
      dailyRate: double.tryParse(_rateCtrl.text.trim()) ?? 100.0,
      currentMileage: int.tryParse(_mileageCtrl.text.trim()) ?? 0,
      status: _status,
    );
    Navigator.pop(context, vehicle);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingVehicle != null;
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: Text(
          isEditing ? 'Edit Vehicle' : 'Add New Vehicle',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _inputField('Plate Number *', _plateCtrl, hint: 'e.g. QAA 4821 C'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _inputField('Brand *', _brandCtrl, hint: 'Perodua')),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _inputField('Model *', _modelCtrl, hint: 'Myvi 1.5')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _inputField('Year *', _yearCtrl,
                      keyboardType: TextInputType.number, numeric: true),
                ),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Color', _colorCtrl, hint: 'Red')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _inputField('Daily Rate (RM) *', _rateCtrl,
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _inputField('Mileage (km)', _mileageCtrl,
                      keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Vehicle Status',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'available', child: Text('Available')),
                DropdownMenuItem(value: 'rented', child: Text('Rented')),
                DropdownMenuItem(
                    value: 'maintenance', child: Text('Maintenance')),
                DropdownMenuItem(value: 'retired', child: Text('Retired')),
              ],
              onChanged: (val) => setState(() => _status = val ?? 'available'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  isEditing ? 'Update Vehicle' : 'Save Vehicle',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
  String label,
  TextEditingController controller, {
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  bool numeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF44545F),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (val) {
            final t = val?.trim() ?? '';
            if (label.contains('*') && t.isEmpty) return 'Required';
            if (numeric && t.isNotEmpty) {
              final n = num.tryParse(t);
              if (n == null || n < 0) return 'Enter a valid number';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
