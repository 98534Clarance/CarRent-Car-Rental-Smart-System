import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VehicleListDetailScreen extends StatefulWidget {
  final UserRole role;
  final List<Vehicle> vehicles;
  final VoidCallback onAddVehicle;
  final ValueChanged<Vehicle> onEditVehicle;
  final ValueChanged<String> onDeleteVehicle;

  const VehicleListDetailScreen({
    super.key,
    required this.role,
    required this.vehicles,
    required this.onAddVehicle,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });

  @override
  State<VehicleListDetailScreen> createState() =>
      _VehicleListDetailScreenState();
}

class _VehicleListDetailScreenState extends State<VehicleListDetailScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.role == UserRole.owner;
    final filtered = widget.vehicles.where((v) {
      final matchesFilter =
          _selectedFilter == 'all' || v.status == _selectedFilter;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = v.plateNumber.toLowerCase().contains(q) ||
          v.brand.toLowerCase().contains(q) ||
          v.model.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fleet',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              if (isOwner)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: widget.onAddVehicle,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add car'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search plate number or model...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All (${widget.vehicles.length})', 'all'),
                const SizedBox(width: 8),
                _filterChip('Available', 'available'),
                const SizedBox(width: 8),
                _filterChip('Rented', 'rented'),
                const SizedBox(width: 8),
                _filterChip('Maintenance', 'maintenance'),
                const SizedBox(width: 8,),
                _filterChip('Retired', 'retired')
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final v = filtered[index];
                return _vehicleCard(v, isOwner);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFE7ECEE),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }

  Widget _vehicleCard(Vehicle v, bool isOwner) {
    Color barColor = AppColors.availGreen;
    Color pillBg = AppColors.availBg;
    Color pillText = AppColors.availText;

    if (v.status == 'rented') {
      barColor = AppColors.rentedBlue;
      pillBg = AppColors.rentedBg;
      pillText = AppColors.rentedText;
    } else if (v.status == 'maintenance') {
      barColor = AppColors.accentAmber;
      pillBg = AppColors.maintAmberBg;
      pillText = AppColors.maintAmberText;
    }else if (v.status == 'retired') {
      barColor = AppColors.textSub;
      pillBg = const Color(0xFFE7ECEE);
      pillText = AppColors.textSub;
    }

    return GestureDetector(
      onTap: () => _showVehicleDetailSheet(v, isOwner),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            v.plateNumber,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              v.status[0].toUpperCase() + v.status.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: pillText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${v.brand} ${v.model} · ${v.year}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSub),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${v.currentMileage} km',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSub),
                          ),
                          Text(
                            'RM ${v.dailyRate.toStringAsFixed(0)} / day',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVehicleDetailSheet(Vehicle v, bool isOwner) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  v.plateNumber,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Chip(label: Text(v.status.toUpperCase())),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${v.brand} ${v.model} (${v.year}) · ${v.color}',
              style: const TextStyle(fontSize: 15, color: AppColors.textSub),
            ),
            const Divider(height: 24),
            _detailRow(
                'Daily Rental Rate', 'RM ${v.dailyRate.toStringAsFixed(2)}'),
            _detailRow('Current Mileage', '${v.currentMileage} km'),
            _detailRow('Access Control',
                isOwner ? 'Owner Full CRUD' : 'Runner Read-Only'),
            const SizedBox(height: 20),
            if (isOwner)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEditVehicle(v);
                      },
                      child: const Text('Edit Vehicle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerRed,
                        side: const BorderSide(color: AppColors.dangerRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDeleteVehicle(v.id);
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Details'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSub)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
