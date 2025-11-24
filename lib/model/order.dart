import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String menuName;
  final double price;
  int quantity;
  double totalPrice;
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

  /// Update the quantity by [delta] (use negative to decrease).
  /// Quantity will not go below 1.
  void updateQuantity(int delta) {
    final newQty = quantity + delta;
    if (newQty < 1) return;
    quantity = newQty;
    totalPrice = price * quantity;
  }

  /// Set quantity to an absolute value (min 1) and recalc total.
  void setQuantity(int q) {
    final newQty = q < 1 ? 1 : q;
    quantity = newQty;
    totalPrice = price * quantity;
  }

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

  Map<String, dynamic> toMap({required String userId}) {
    return {
      'userId': userId,
      'menuName': menuName,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
      'menuImage': menuImage,
    };
  }

  static Order fromMap(Map<String, dynamic> map, String id) {
    final od = map['orderDate'];
    DateTime dt;
    if (od is Timestamp) {
      dt = od.toDate();
    } else if (od is String) {
      dt = DateTime.tryParse(od) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }
    return Order(
      id: id,
      menuName: map['menuName'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : 1,
      totalPrice: (map['totalPrice'] is num) ? (map['totalPrice'] as num).toDouble() : 0.0,
      orderDate: dt,
      status: map['status'] ?? 'paid',
      menuImage: map['menuImage'] ?? '',
    );
  }
}
