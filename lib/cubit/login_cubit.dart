import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../admin/service/admin_auth_service.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final bool isAdminSuccess;
  final String? error;
  final String? userId;
  final String? kantinId;

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

  // --- LOGIN EMAIL ---
  Future<void> login(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        emit(LoginState(isSuccess: true, userId: user.uid));
      } else {
        emit(LoginState(error: "Login gagal."));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        emit(LoginState(error: "Email atau password salah"));
      } else {
        emit(LoginState(error: "Error Auth: ${e.message}"));
      }
    } catch (e) {
      emit(LoginState(error: "Terjadi kesalahan: ${e.toString()}"));
    }
  }

  // --- LOGIN GOOGLE (BARU) ---
  Future<void> loginGoogle() async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        // Login Google sukses, dianggap sebagai User biasa
        emit(LoginState(isSuccess: true, userId: user.uid));
      } else {
        // User membatalkan login (tekan back saat pilih akun)
        // Kita kembalikan state ke awal (tidak loading, tidak error)
        emit(LoginState(isLoading: false));
      }
    } catch (e) {
      emit(LoginState(error: "Gagal Login Google: ${e.toString()}"));
    }
  }

  // --- LOGIN ADMIN ---
  Future<void> loginAdmin(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _adminAuthService.signInAdmin(email, password);
      if (user != null) {
        final doc = await _adminAuthService.getAdminData(user.uid);
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null && data['role'] == 'admin') {
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
      emit(LoginState(error: "Error Auth: ${e.message}"));
    } catch (e) {
      emit(LoginState(error: "Error Data: ${e.toString()}"));
    }
  }

  // --- REGISTER ---
  Future<void> register(String email, String password, String name) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signUpUser(email, password, name);
      if (user != null) {
        emit(LoginState(isSuccess: true, userId: user.uid));
      } else {
        emit(LoginState(error: "Registrasi gagal"));
      }
    } catch (e) {
      emit(LoginState(error: "Registrasi gagal: ${e.toString()}"));
    }
  }
}
