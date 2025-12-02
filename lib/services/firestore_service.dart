import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USER: Membuat Pesanan Baru ---
  Future<void> addOrder(Map<String, dynamic> order) async {
    try {
      await _db.collection('orders').add(order);
    } catch (e) {
      throw Exception('Yah, gagal membuat pesanan. Silakan coba lagi.');
    }
  }

  // --- ADMIN: Mengubah Status Pesanan ---
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      throw Exception(
        'Hmm, gagal memperbarui status pesanan. Silakan coba lagi.',
      );
    }
  }

  // --- ADMIN: Hapus Pesanan Spesifik (FITUR DELETE PER ITEM) ---
  Future<void> deleteOrder(String orderId) async {
    try {
      await _db.collection('orders').doc(orderId).delete();
    } catch (e) {
      throw Exception('Yah, gagal menghapus pesanan. Silakan coba lagi.');
    }
  }

  // --- ADMIN: Ambil Pesanan Real-time ---
  Stream<QuerySnapshot> getOrdersByKantin(String kantinId) {
    return _db
        .collection('orders')
        .where('kantinId', isEqualTo: kantinId)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // --- USER: Lihat Riwayat Sendiri ---
  Stream<QuerySnapshot> getOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // --- USER: Hapus Semua Riwayat ---
  Future<void> deleteOrdersForUser(String userId) async {
    try {
      final snapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
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
