import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addOrder(Map<String, dynamic> order) async {
    await _db.collection('orders').add(order);
  }

  /// Delete all orders for given userId. Uses a batch delete.
  Future<void> deleteOrdersForUser(String userId) async {
    final snapshot = await _db.collection('orders').where('userId', isEqualTo: userId).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<QuerySnapshot> getOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
