import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../admin/service/admin_auth_service.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess; // Sukses Login User
  final bool isAdminSuccess; // Sukses Login Admin
  final String? error;
  final String? userId;
  final String? kantinId; // Data khusus admin

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

  // --- LOGIN GOOGLE (BARU) ---
  Future<void> loginGoogle() async {
    emit(LoginState(isLoading: true));
    try {
      // Panggil logika pintar di AuthService
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        // Sukses! (Entah itu user baru atau lama, AuthService sudah mengurusnya)
        emit(LoginState(isSuccess: true, userId: user.uid));
      } else {
        // User membatalkan login (klik silang di popup)
        emit(LoginState(isLoading: false));
      }
    } catch (e) {
      emit(LoginState(error: "Gagal Login Google: ${e.toString()}"));
    }
  }

  // --- LOGIN USER (EMAIL MANUAL) ---
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
        emit(LoginState(error: "Error Auth: ${e.message ?? e.code}"));
      }
    } catch (e) {
      emit(LoginState(error: "Terjadi kesalahan: ${e.toString()}"));
    }
  }

  // --- LOGIN ADMIN (MANUAL) ---
  Future<void> loginAdmin(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _adminAuthService.signInAdmin(email, password);
      if (user != null) {
        // Validasi Role Admin
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
      emit(LoginState(error: "Error Auth: ${e.message ?? e.code}"));
    } catch (e) {
      emit(LoginState(error: "Error Data: ${e.toString()}"));
    }
  }

  // --- REGISTER USER (MANUAL) ---
  Future<void> register(String email, String password, String name) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signUpUser(email, password, name);
      if (user != null) {
        emit(LoginState(isSuccess: true, userId: user.uid));
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
