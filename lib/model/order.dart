import 'package:flutter/material.dart';

class Order {
  final String id;
  final String menuName;
  final double price;
  final int quantity;
  final double totalPrice;
  final DateTime orderDate;
  final String status; // 'pending', 'paid', 'completed', 'cancelled'
  final String menuImage;

  Order({
    required this.id,
    required this.menuName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    required this.menuImage,
  });

  // Placeholder untuk contoh data
  static List<Order> getPlaceholderOrders() {
    return [
      Order(
        id: '001',
        menuName: 'Nasi Goreng',
        price: 25000,
        quantity: 2,
        totalPrice: 50000,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        menuImage: 'assets/nasi_goreng.png',
      ),
      Order(
        id: '002',
        menuName: 'Mie Ayam',
        price: 20000,
        quantity: 1,
        totalPrice: 20000,
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'paid',
        menuImage: 'assets/mie_ayam.png',
      ),
      Order(
        id: '003',
        menuName: 'Soto Ayam',
        price: 18000,
        quantity: 3,
        totalPrice: 54000,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'completed',
        menuImage: 'assets/soto_ayam.png',
      ),
      Order(
        id: '004',
        menuName: 'Gado-Gado',
        price: 15000,
        quantity: 2,
        totalPrice: 30000,
        orderDate: DateTime.now(),
        status: 'paid',
        menuImage: 'assets/gado_gado.png',
      ),
    ];
  }

  String getStatusLabel() {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Sudah Dibayar';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFA500); // Orange
      case 'paid':
        return const Color(0xFF4169E1); // Royal Blue
      case 'completed':
        return const Color(0xFF28A745); // Green
      case 'cancelled':
        return const Color(0xFFDC3545); // Red
      default:
        return const Color(0xFF6C757D); // Gray
    }
  }
}
