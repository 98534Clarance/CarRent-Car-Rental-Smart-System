import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeDashboardScreen extends StatelessWidget {
  final UserRole role;
  final List<Vehicle> vehicles;
  final List<BookingItem> bookings;
  final VoidCallback onToggleRole;
  final ValueChanged<int> onNavigateTab;
  final VoidCallback onOpenAddVehicle;

  const HomeDashboardScreen({
    super.key,
    required this.role,
    required this.vehicles,
    required this.bookings,
    required this.onToggleRole,
    required this.onNavigateTab,
    required this.onOpenAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = role == UserRole.owner;
    final availableCount =
        vehicles.where((v) => v.status == 'available').length;
    final rentedCount = vehicles.where((v) => v.status == 'rented').length;
    final maintCount = vehicles.where((v) => v.status == 'maintenance').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    isOwner ? 'Black Mamba Enterprise' : 'Runner Operations',
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.textSub),
                  ),
                ],
              ),
              ActionChip(
                label: Text(
                  isOwner ? 'Owner ⇄' : 'Runner ⇄',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isOwner ? AppColors.availText : AppColors.rentedText,
                  ),
                ),
                backgroundColor:
                    isOwner ? AppColors.availBg : AppColors.rentedBg,
                onPressed: onToggleRole,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Owner-only Revenue Banner (BR-05)
          if (isOwner) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Revenue (Owner View)',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'RM 24,850.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.trending_up,
                          color: AppColors.accentAmber, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Active deposits held: RM 2,400.00',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.navPill),
              ),
              child: const Text(
                'BR-05 Runner Mode: Revenue metrics and vehicle pricing edits are restricted to Owner accounts.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Fleet Status Summary Row
          const Text(
            'Fleet Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statBox('Available', '$availableCount', AppColors.availBg,
                  AppColors.availText),
              const SizedBox(width: 10),
              _statBox('Rented', '$rentedCount', AppColors.rentedBg,
                  AppColors.rentedText),
              const SizedBox(width: 10),
              _statBox('Service', '$maintCount', AppColors.maintAmberBg,
                  AppColors.maintAmberText),
            ],
          ),
          const SizedBox(height: 18),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('Booking Calendar'),
                  onPressed: () => onNavigateTab(2),
                ),
              ),
              if (isOwner) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Vehicle'),
                    onPressed: onOpenAddVehicle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Today's Schedule Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Handovers",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => onNavigateTab(2),
                child: const Text('View Calendar →'),
              ),
            ],
          ),
          ...bookings.take(2).map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.vehiclePlate} · ${b.vehicleName}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customer: ${b.customerName}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSub),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.availBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          b.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.availText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _statBox(String label, String count, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
