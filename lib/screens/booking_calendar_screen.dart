import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
String _fmt(DateTime d) => '${d.day} ${_monthNames[d.month - 1]}';

/// True if the booking covers [day], comparing full dates (works across months).
bool _coversDay(BookingItem b, DateTime day) {
  final d = _dateOnly(day);
  return !d.isBefore(_dateOnly(b.pickupDate)) &&
      !d.isAfter(_dateOnly(b.returnDate));
}

/// True if [start]..[end] overlaps an existing booking for the same plate.
bool _hasConflict(List<BookingItem> bookings, String plate, DateTime start,
    DateTime end) {
  return bookings.any((b) =>
      b.vehiclePlate == plate &&
      b.status != 'completed' &&
      start.isBefore(b.returnDate) &&
      end.isAfter(b.pickupDate));
}

class BookingCalendarScreen extends StatefulWidget {
  final List<BookingItem> bookings;
  final List<Vehicle> vehicles;
  final ValueChanged<BookingItem> onAddBooking;

  const BookingCalendarScreen({
    super.key,
    required this.bookings,
    required this.vehicles,
    required this.onAddBooking,
  });

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  DateTime _selectedDate = DateTime(2026, 12, 10);
  final List<DateTime> _days =
      List.generate(7, (i) => DateTime(2026, 12, 8 + i));

  Future<void> _openNewBookingDialog() async {
    final bookable = widget.vehicles
        .where((v) => v.status != 'maintenance' && v.status != 'retired')
        .toList();

    if (bookable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No vehicles are available to book.')),
      );
      return;
    }

    final result = await showDialog<BookingItem>(
      context: context,
      builder: (_) => _NewBookingDialog(
        vehicles: bookable,
        existingBookings: widget.bookings,
        pickupDate: _selectedDate,
      ),
    );
    if (result != null) widget.onAddBooking(result);
  }

  @override
  Widget build(BuildContext context) {
    final dayBookings =
        widget.bookings.where((b) => _coversDay(b, _selectedDate)).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bookings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _openNewBookingDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New booking'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'December 2026 · Fleet Schedule',
            style: TextStyle(fontSize: 14, color: AppColors.textSub),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = _days[i];
                final selected = day == _selectedDate;
                final hasEvents =
                    widget.bookings.any((b) => _coversDay(b, day));

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: Container(
                    width: 54,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            selected ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekdayNames[day.weekday - 1],
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                selected ? Colors.white70 : AppColors.textSub,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasEvents
                                ? (selected
                                    ? AppColors.accentAmber
                                    : AppColors.primary)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scheduled on ${_fmt(_selectedDate)} (${dayBookings.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: dayBookings.isEmpty
                ? Center(
                    child: Text(
                      'All vehicles free on ${_fmt(_selectedDate)}.',
                      style: const TextStyle(color: AppColors.textSub),
                    ),
                  )
                : ListView.separated(
                    itemCount: dayBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) =>
                        _bookingCard(dayBookings[idx]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(BookingItem b) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${b.vehiclePlate} · ${b.vehicleName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rentedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  b.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rentedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${b.customerName}',
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${_fmt(b.pickupDate)} → ${_fmt(b.returnDate)} · Runner: ${b.assignedRunner}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSub),
                ),
              ),
              Text(
                'RM ${b.totalPrice.toStringAsFixed(2)}',
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
    );
  }
}

class _NewBookingDialog extends StatefulWidget {
  final List<Vehicle> vehicles; // must be non-empty
  final List<BookingItem> existingBookings;
  final DateTime pickupDate;

  const _NewBookingDialog({
    required this.vehicles,
    required this.existingBookings,
    required this.pickupDate,
  });

  @override
  State<_NewBookingDialog> createState() => _NewBookingDialogState();
}

class _NewBookingDialogState extends State<_NewBookingDialog> {
  static const int _days = 3;
  late final TextEditingController _customerCtrl;
  late Vehicle _selectedCar;
  String? _error;

  @override
  void initState() {
    super.initState();
    _customerCtrl = TextEditingController(text: 'Ahmad Faiz bin Hassan');
    _selectedCar = widget.vehicles.first;
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _customerCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter the customer name.');
      return;
    }

    final d = widget.pickupDate;
    final start = DateTime(d.year, d.month, d.day, 10, 0);
    final end = DateTime(d.year, d.month, d.day + _days, 10, 0);

    if (_hasConflict(
        widget.existingBookings, _selectedCar.plateNumber, start, end)) {
      setState(() => _error =
          '${_selectedCar.plateNumber} is already booked during these dates.');
      return;
    }

    Navigator.pop(
      context,
      BookingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: name,
        vehiclePlate: _selectedCar.plateNumber,
        vehicleName: '${_selectedCar.brand} ${_selectedCar.model}',
        pickupDate: start,
        returnDate: end,
        totalPrice: _selectedCar.dailyRate * _days,
        status: 'confirmed',
        assignedRunner: 'Akmal',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Booking (FR-03)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _customerCtrl,
            decoration: const InputDecoration(labelText: 'Customer Name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Vehicle>(
            initialValue: _selectedCar,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Select Vehicle'),
            items: widget.vehicles
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text('${v.plateNumber} · ${v.model}',
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCar = val;
                  _error = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.availBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Pick-up: ${_fmt(widget.pickupDate)} · $_days Days '
              '(RM ${(_selectedCar.dailyRate * _days).toStringAsFixed(0)})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.availText,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.dangerRed,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _save,
          child: const Text('Save booking'),
        ),
      ],
    );
  }
}