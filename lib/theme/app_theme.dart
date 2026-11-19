import 'package:flutter/material.dart';

enum UserRole { owner, runner }

class AppColors {
  static const Color primary = Color(0xFF0E4D64);
  static const Color primaryLight = Color(0xFFEAF3F6);
  static const Color navPill = Color(0xFFCFE3EA);
  static const Color accentAmber = Color(0xFFF2A900);
  static const Color bgSurface = Color(0xFFF6F7F5);
  static const Color textDark = Color(0xFF1B2630);
  static const Color textSub = Color(0xFF5A6A75);
  static const Color border = Color(0xFFB7C2C9);
  static const Color cardBorder = Color(0xFFE1E6E8);

  static const Color availGreen = Color(0xFF2E7D4F);
  static const Color availBg = Color(0xFFDDF0E4);
  static const Color availText = Color(0xFF1D5A37);

  static const Color rentedBlue = Color(0xFF2B5FAE);
  static const Color rentedBg = Color(0xFFDCE7F7);
  static const Color rentedText = Color(0xFF1F4684);

  static const Color maintAmberBg = Color(0xFFFCEBC2);
  static const Color maintAmberText = Color(0xFF7A5300);

  static const Color dangerRed = Color(0xFFC0392B);
  static const Color dangerBg = Color(0xFFFDF2F2);
}

class Vehicle {
  final String id;
  String plateNumber;
  String brand;
  String model;
  int year;
  String color;
  double dailyRate;
  int currentMileage;
  String status; // 'available', 'rented', 'maintenance', 'retired'

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.dailyRate,
    required this.currentMileage,
    required this.status,
  });
}

class BookingItem {
  final String id;
  final String customerName;
  final String vehiclePlate;
  final String vehicleName;
  final DateTime pickupDate;
  final DateTime returnDate;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'active', 'completed'
  final String assignedRunner;

  BookingItem({
    required this.id,
    required this.customerName,
    required this.vehiclePlate,
    required this.vehicleName,
    required this.pickupDate,
    required this.returnDate,
    required this.totalPrice,
    required this.status,
    required this.assignedRunner,
  });
}
