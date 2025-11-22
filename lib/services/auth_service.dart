import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // --- TAMBAHAN BARU ---
  // Fungsi untuk mengambil data user dari koleksi 'users'
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }
  // --- BATAS TAMBAHAN ---

  Future<User?> signUpUser(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'nama': name,
      'role': 'user',
      'kantinId': null, // User biasa tidak punya kantinId
    });
    return credential.user;
  }
}
