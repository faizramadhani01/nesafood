import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final double totalPrice;
  final DateTime orderDate;
  final String status;
  final String menuName; // Nama menu utama untuk display
  final int quantity;    // Total qty untuk display
  final double price;    // Harga satuan (display)
  final List<dynamic> items; // Detail semua item

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    required this.menuName,
    required this.quantity,
    required this.price,
    required this.items,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    // 1. Ambil list items dengan aman
    final List<dynamic> itemsList = map['items'] ?? [];

    // 2. SAFETY CHECK: Cek apakah items kosong?
    String displayMenuName = 'Pesanan Tanpa Item';
    int displayQty = 0;
    double displayPrice = 0;

    if (itemsList.isNotEmpty) {
      // Jika ada item, ambil data dari item pertama sebagai representasi
      final firstItem = itemsList[0];
      displayMenuName = firstItem['menu_name'] ?? 'Unknown Menu';
      displayQty = firstItem['quantity'] ?? 0;
      displayPrice = (firstItem['price'] ?? 0).toDouble();
    }

    // 3. Return object Order yang aman
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      orderDate: map['orderDate'] != null
          ? DateTime.parse(map['orderDate'])
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      menuName: displayMenuName, 
      quantity: displayQty,
      price: displayPrice,
      items: itemsList,
    );
  }

  // Helper untuk mengubah object kembali ke Map (untuk simpan ke DB)
  Map<String, dynamic> toMap({String? userId}) {
    return {
      'userId': userId ?? this.userId,
      'userName': userName,
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'items': items,
    };
  }

  // Helper UI: Warna Status
  Color getStatusColor() {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'cooking': return Colors.blue;
      case 'ready': return Colors.green;
      case 'completed': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.black;
    }
  }

  // Helper UI: Label Status
  String getStatusLabel() {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'cooking': return 'Dimasak';
      case 'ready': return 'Siap Diambil';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }
}