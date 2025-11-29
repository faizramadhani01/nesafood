import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USER: Membuat Pesanan Baru ---
  Future<void> addOrder(Map<String, dynamic> order) async {
    try {
      await _db.collection('orders').add(order);
    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  // --- ADMIN: Mengubah Status Pesanan ---
  // Status: pending -> cooking -> ready -> completed
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  // --- ADMIN: Ambil Semua Pesanan (Real-time) ---
  // Bisa difilter berdasarkan kantinId jika nanti sudah multi-kantin
  Stream<QuerySnapshot> getOrdersByKantin(String kantinId) {
    return _db
        .collection('orders')
        // .where('kantinId', isEqualTo: kantinId) // Aktifkan jika sudah pakai ID Kantin
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // --- USER: Lihat Riwayat Pesanan Sendiri (Real-time) ---
  Stream<QuerySnapshot> getOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // --- USER/ADMIN: Hapus Data (Opsional) ---
  Future<void> deleteOrdersForUser(String userId) async {
    try {
      final snapshot = await _db.collection('orders').where('userId', isEqualTo: userId).get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }
}