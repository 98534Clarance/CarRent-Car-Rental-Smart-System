import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/vehicle_list_detail_screen.dart';
import 'screens/add_edit_vehicle_screen.dart';
import 'screens/booking_calendar_screen.dart';
import 'screens/scan_customer_screen.dart';
import 'screens/handover_log_screen.dart';

void main() {
  runApp(const CarRentApp());
}

class CarRentApp extends StatelessWidget {
  const CarRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarRent — Black Mamba Enterprise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgSurface,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final UserRole initialRole;
  const MainNavigationShell({super.key, required this.initialRole});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _tabIndex = 0;
  late UserRole _role;

  final List<Vehicle> _vehicles = [
    Vehicle(
      id: '1',
      plateNumber: 'QAA 1111',
      brand: 'Perodua',
      model: 'Myvi 1.5 AV',
      year: 2023,
      color: 'Granite Grey',
      dailyRate: 120,
      currentMileage: 31420,
      status: 'available',
    ),
    Vehicle(
      id: '2',
      plateNumber: 'QAA 2222',
      brand: 'Honda',
      model: 'City RS',
      year: 2022,
      color: 'Platinum White',
      dailyRate: 180,
      currentMileage: 48905,
      status: 'rented',
    ),
    Vehicle(
      id: '3',
      plateNumber: 'QAA 3333',
      brand: 'Toyota',
      model: 'Vios 1.5G',
      year: 2020,
      color: 'Attitude Black',
      dailyRate: 170,
      currentMileage: 76310,
      status: 'maintenance',
    ),
    Vehicle(
      id: '4',
      plateNumber: 'QAA 4444',
      brand: 'Perodua',
      model: 'Axia SE',
      year: 2024,
      color: 'Coral Blue',
      dailyRate: 100,
      currentMileage: 12080,
      status: 'available',
    ),
  ];

  final List<BookingItem> _bookings = [
    BookingItem(
      id: 'b1',
      customerName: 'Ahmad Faiz bin Hassan',
      vehiclePlate: 'QAA 1111',
      vehicleName: 'Perodua Myvi',
      pickupDate: DateTime(2026, 12, 10, 10, 0),
      returnDate: DateTime(2026, 12, 13, 10, 0),
      totalPrice: 360.00,
      status: 'confirmed',
      assignedRunner: 'Akmal',
    ),
    BookingItem(
      id: 'b2',
      customerName: 'Nurul Izzah binti Halim',
      vehiclePlate: 'QAA 2222',
      vehicleName: 'Honda City',
      pickupDate: DateTime(2026, 12, 9, 14, 0),
      returnDate: DateTime(2026, 12, 11, 16, 30),
      totalPrice: 360.00,
      status: 'active',
      assignedRunner: 'Akmal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  Future<void> _openAddOrEditVehicle([Vehicle? existing]) async {
    final result = await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditVehicleScreen(existingVehicle: existing),
      ),
    );
    if (result != null) {
      setState(() {
        final idx = _vehicles.indexWhere((v) => v.id == result.id);
        if (idx >= 0) {
          _vehicles[idx] = result;
        } else {
          _vehicles.insert(0, result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeDashboardScreen(
        role: _role,
        vehicles: _vehicles,
        bookings: _bookings,
        onToggleRole: () => setState(() {
          _role = _role == UserRole.owner ? UserRole.runner : UserRole.owner;
        }),
        onNavigateTab: (idx) => setState(() => _tabIndex = idx),
        onOpenAddVehicle: () => _openAddOrEditVehicle(),
      ),
      VehicleListDetailScreen(
        role: _role,
        vehicles: _vehicles,
        onAddVehicle: () => _openAddOrEditVehicle(),
        onEditVehicle: (v) => _openAddOrEditVehicle(v),
        onDeleteVehicle: (id) =>
            setState(() => _vehicles.removeWhere((v) => v.id == id)),
      ),
      BookingCalendarScreen(
        bookings: _bookings,
        vehicles: _vehicles,
        onAddBooking: (b) => setState(() => _bookings.insert(0, b)),
      ),
      const ScanCustomerScreen(),
      const HandoverLogScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.navPill,
        selectedIndex: _tabIndex,
        onDestinationSelected: (idx) => setState(() => _tabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Fleet',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Handover',
          ),
        ],
      ),
    );
  }
}
