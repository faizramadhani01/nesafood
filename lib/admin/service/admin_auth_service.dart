import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register admin (dengan kantinId)
  Future<User?> signUpAdmin(
    String email,
    String password,
    String kantinId,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('account').doc(credential.user!.uid).set({
      'email': email,
      'role': 'admin',
      'kantinId': kantinId,
    });
    return credential.user;
  }

  // Login admin
  Future<User?> signInAdmin(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Ambil data admin dari Firestore
  Future<DocumentSnapshot> getAdminData(String uid) async {
    return await _db.collection('account').doc(uid).get();
  }
}
