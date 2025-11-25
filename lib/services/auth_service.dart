import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===============================
  // 🔥 LOGIN GOOGLE KHUSUS WEB
  // ===============================
  Future<User?> signInWithGoogle() async {
    try {
      // Provider khusus untuk login Google di Web
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');

      // Sign in menggunakan POPUP (WAJIB untuk Web)
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Cek apakah user sudah ada di Firestore
        final DocumentSnapshot userDoc = await _db
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Jika user baru → buat data otomatis
          await _db.collection('users').doc(user.uid).set({
            'email': user.email,
            'nama': user.displayName ?? 'Google User',
            'role': 'user',
            'kantinId': null,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        return user;
      }

      return null;
    } catch (e) {
      print("Error Google Sign In WEB: $e");
      rethrow;
    }
  }

  // ===============================
  // 🔥 LOGIN EMAIL & PASSWORD
  // ===============================

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // ===============================
  // 🔥 REGISTER EMAIL
  // ===============================

  Future<User?> signUpUser(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'nama': name,
      'role': 'user',
      'kantinId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential.user;
  }

  // ===============================
  // 🔥 SIGN OUT
  // ===============================

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ===============================
  // 🔥 GET USER DATA
  // ===============================

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }
}
