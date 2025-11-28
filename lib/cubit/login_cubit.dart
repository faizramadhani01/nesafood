import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../admin/service/admin_auth_service.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final bool isNewUser;
  final User? googleUser;
  final bool isAdminSuccess;
  final String? error;
  final String? userId;
  final String? kantinId;

  LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isNewUser = false,
    this.googleUser,
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

  // --- LOGIN GOOGLE ---
  Future<void> loginGoogle() async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signInWithGoogle();
      
      if (user != null) {
        final isRegistered = await _authService.isUserRegistered(user.uid);

        if (isRegistered) {
          emit(LoginState(isSuccess: true, userId: user.uid));
        } else {
          emit(LoginState(isNewUser: true, googleUser: user));
        }
      } else {
        emit(LoginState(isLoading: false));
      }
    } catch (e) {
      emit(LoginState(error: "Gagal Login Google: ${e.toString()}"));
    }
  }

  // --- LOGIN MANUAL (DENGAN CEK ERROR VERIFIKASI) ---
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
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        emit(LoginState(error: "Email atau password salah"));
      } 
      // Tangkap error verifikasi
      else if (e.code == 'email-not-verified') {
        emit(LoginState(error: e.message));
      } 
      else {
        emit(LoginState(error: "Error Auth: ${e.message}"));
      }
    } catch (e) {
      emit(LoginState(error: "Error: ${e.toString()}"));
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
          emit(LoginState(isAdminSuccess: true, userId: user.uid, kantinId: data['kantinId']));
        } else {
          emit(LoginState(error: "Akun ini bukan admin."));
        }
      }
    } catch (e) {
      emit(LoginState(error: "Gagal Login Admin: ${e.toString()}"));
    }
  }
}