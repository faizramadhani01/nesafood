import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- REGISTER MANUAL (DENGAN VERIFIKASI) ---
  Future<User?> signUpUser(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 1. Simpan data user
    await _db.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'nama': name,
      'role': 'user',
      'kantinId': null,
      'phone': '',
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await credential.user!.updateDisplayName(name);

    // 2. KIRIM EMAIL VERIFIKASI (WAJIB)
    if (credential.user != null && !credential.user!.emailVerified) {
      await credential.user!.sendEmailVerification();
    }

    return credential.user;
  }

  // --- LOGIN MANUAL ---
  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message:
              'Email kamu belum diverifikasi. Cek inbox emailmu untuk verifikasi.',
        );
      }
    }

    return credential.user;
  }

  // --- LOGIN GOOGLE ---
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception("Gagal login dengan Google. Silakan coba lagi nanti.");
    }
  }

  // --- CEK STATUS USER ---
  Future<bool> isUserRegistered(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  // --- FINALISASI DATA GOOGLE ---
  Future<void> finalizeRegistration({
    required String uid,
    required String email,
    required String name,
    required String phone,
    required String password,
    String? photoUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'nama': name,
      'phone': phone,
      'role': 'user',
      'kantinId': null,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (password.isNotEmpty) {
      await _auth.currentUser?.updatePassword(password);
    }

    await _auth.currentUser?.updateDisplayName(name);
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // --- GET USER DATA ---
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // --- UPDATE PROFILE ---
  Future<void> updateUserProfile(String uid, String name, String phone) async {
    await _db.collection('users').doc(uid).update({
      'nama': name,
      'phone': phone,
    });
    await _auth.currentUser?.updateDisplayName(name);
  }

  // --- UPLOAD FOTO ---
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images').child('$uid.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await _db.collection('users').doc(uid).update({'photoUrl': url});
    await _auth.currentUser?.updatePhotoURL(url);
    return url;
  }
}
