import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- EMAIL & PASSWORD ---
  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> signUpUser(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _createUserDocument(credential.user!, name, 'user');
    return credential.user;
  }

  // --- GOOGLE SIGN IN (BARU) ---
  Future<User?> signInWithGoogle() async {
    // 1. Trigger flow autentikasi Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User membatalkan login

    // 2. Dapatkan detail autentikasi dari request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 3. Buat kredensial baru untuk Firebase
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in ke Firebase dengan kredensial tersebut
    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    final User? user = userCredential.user;

    // 5. Cek apakah data user sudah ada di Firestore, jika belum, buat baru
    if (user != null) {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _createUserDocument(
          user,
          user.displayName ?? 'Google User',
          'user',
        );
      }
    }

    return user;
  }

  // Helper untuk simpan data ke Firestore
  Future<void> _createUserDocument(User user, String name, String role) async {
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'nama': name,
      'role': role,
      'kantinId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Ambil data user
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // Sign Out (Penting untuk Google agar bisa ganti akun)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
