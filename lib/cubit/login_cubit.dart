import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../admin/service/admin_auth_service.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess; // State sukses untuk User Biasa
  final bool isAdminSuccess; // State sukses untuk Admin
  final String? error;
  final String? userId;
  final String? fullName;
  final String? kantinId; // Data khusus admin

  LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isAdminSuccess = false,
    this.error,
    this.userId,
    this.fullName,
    this.kantinId,
  });
}

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService = AuthService();
  final AdminAuthService _adminAuthService = AdminAuthService();

  LoginCubit() : super(LoginState());

  // ==================================================
  // 1. LOGIN USER BIASA (LOGIKA BARU: TANPA CEK ROLE)
  // ==================================================
  Future<void> login(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      // Coba login ke Firebase Auth
      final user = await _authService.signIn(email, password);

      if (user != null) {
        // Jika berhasil login Auth, ambil data user dari Firestore untuk mendapatkan nama lengkap
        String? name;
        try {
          final doc = await _authService.getUserData(user.uid);
          final data = doc.data() as Map<String, dynamic>?;
          name = data != null ? (data['nama'] as String?) : null;
        } catch (_) {
          name = user.displayName;
        }

        // Jika berhasil login Auth, langsung dianggap SUKSES dan sertakan fullName bila ada.
        emit(LoginState(isSuccess: true, userId: user.uid, fullName: name));
      } else {
        emit(LoginState(error: "Login gagal."));
      }
    } on FirebaseAuthException catch (e) {
      // Penanganan Error Khas Firebase
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        emit(LoginState(error: "Email atau password salah"));
      } else if (e.code == 'invalid-email') {
        emit(LoginState(error: "Format email tidak valid"));
      } else {
        emit(LoginState(error: "Error Auth: ${e.message ?? e.code}"));
      }
    } catch (e) {
      emit(LoginState(error: "Terjadi kesalahan: ${e.toString()}"));
    }
  }

  Future<void> loginAdmin(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      // 1. Login Auth
      final user = await _adminAuthService.signInAdmin(email, password);

      if (user != null) {
        // 2. Ambil data admin untuk validasi Role & ambil KantinID
        final doc = await _adminAuthService.getAdminData(user.uid);
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null && data['role'] == 'admin') {
          // Jika role benar 'admin', baru sukses
          emit(
            LoginState(
              isAdminSuccess: true,
              userId: user.uid,
              kantinId: data['kantinId'],
            ),
          );
        } else {
          emit(LoginState(error: "Akun ini bukan akun Admin."));
        }
      } else {
        emit(LoginState(error: "Login admin gagal."));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        emit(LoginState(error: "Email atau password admin salah"));
      } else {
        emit(LoginState(error: "Error Auth: ${e.message ?? e.code}"));
      }
    } catch (e) {
      emit(LoginState(error: "Error Data: ${e.toString()}"));
    }
  }

  // ==================================================
  // 3. REGISTER USER
  // ==================================================
  Future<void> register(String email, String password, String name) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signUpUser(email, password, name);
      if (user != null) {
        // Register sukses langsung masuk
        emit(LoginState(isSuccess: true, userId: user.uid, fullName: name));
      } else {
        emit(LoginState(error: "Registrasi gagal"));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(LoginState(error: "Email sudah terdaftar."));
      } else if (e.code == 'weak-password') {
        emit(LoginState(error: "Password terlalu lemah."));
      } else {
        emit(LoginState(error: "Register Error: ${e.message}"));
      }
    } catch (e) {
      emit(LoginState(error: "Registrasi gagal: ${e.toString()}"));
    }
  }
}
