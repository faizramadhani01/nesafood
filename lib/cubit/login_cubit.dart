import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../admin/service/admin_auth_service.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess; // Ini untuk user login/register sukses
  final bool isAdminSuccess; // flag untuk admin sukses
  final String? error;
  final String? userId;
  final String? kantinId; // field untuk kantinId

  LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isAdminSuccess = false,
    this.error,
    this.userId,
    this.kantinId,
  });
}

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService = AuthService();
  final AdminAuthService _adminAuthService = AdminAuthService();

  LoginCubit() : super(LoginState());

  // --- FUNGSI UNTUK LOGIN USER BIASA ---
  Future<void> login(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      // 1. Coba login ke Firebase Auth
      final user = await _authService.signIn(email, password);
      if (user != null) {
        // 2. Jika login Auth berhasil, cek ke database Firestore 'users'
        final doc = await _authService.getUserData(user.uid);
        final data = doc.data() as Map<String, dynamic>?;

        // 3. Cek apakah rolenya 'user'
        if (data != null && data['role'] == 'user') {
          // 4. Jika ya, emit state isSuccess (untuk user)
          emit(LoginState(isSuccess: true, userId: user.uid));
        } else {
          // Login berhasil, tapi dia bukan user (mungkin admin)
          emit(LoginState(error: "Akun ini bukan akun user."));
        }
      }
    } on FirebaseAuthException catch (e) {
      // Tangani error login user
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        emit(LoginState(error: "Username atau password salah"));
      } else {
        emit(LoginState(error: "Error Auth: ${e.message ?? e.code}"));
      }
    } catch (e) {
      emit(LoginState(error: "Error Data: ${e.toString()}"));
    }
  }

  // --- FUNGSI UNTUK LOGIN ADMIN ---
  Future<void> loginAdmin(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      // 1. Coba login ke Firebase Auth
      final user = await _adminAuthService.signInAdmin(email, password);
      if (user != null) {
        // 2. Jika login Auth berhasil, cek ke database Firestore 'account'
        final doc = await _adminAuthService.getAdminData(user.uid);
        final data = doc.data() as Map<String, dynamic>?;

        // 3. Cek apakah rolenya 'admin'
        if (data != null && data['role'] == 'admin') {
          // 4. Jika ya, emit state isAdminSuccess dan bawa kantinId
          emit(
            LoginState(
              isAdminSuccess: true, // Gunakan flag admin
              userId: user.uid,
              kantinId: data['kantinId'],
            ),
          );
        } else {
          // Login berhasil, tapi dia bukan admin (mungkin user biasa)
          emit(LoginState(error: "Akun ini bukan admin."));
        }
      }
    } on FirebaseAuthException catch (e) {
      // Tangani error login admin (email tidak ada, password salah)
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        emit(LoginState(error: "Email atau password admin salah"));
      } else {
        emit(LoginState(error: "Error Auth: ${e.message ?? e.code}"));
      }
    } catch (e) {
      // Tangani error lain (misal, tidak ada koneksi, data role tidak ada, dll)
      emit(LoginState(error: "Error Data: ${e.toString()}"));
    }
  }

  // --- FUNGSI UNTUK REGISTRASI USER BIASA ---
  Future<void> register(String email, String password, String name) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signUpUser(email, password, name);
      if (user != null) {
        // Langsung emit success, karena signUpUser sudah otomatis memberi role 'user'
        emit(LoginState(isSuccess: true, userId: user.uid));
      } else {
        emit(LoginState(error: "Registrasi gagal"));
      }
    } catch (e) {
      emit(LoginState(error: "Registrasi gagal: ${e.toString()}"));
    }
  }
}
