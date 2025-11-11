import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String? userId;

  LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.userId,
  });
}

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService = AuthService();

  LoginCubit() : super(LoginState());

  Future<void> login(String email, String password) async {
    emit(LoginState(isLoading: true));
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        emit(LoginState(isSuccess: true, userId: user.uid));
      } else {
        emit(LoginState(error: "Username atau password salah"));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        emit(LoginState(error: "Username atau password salah"));
      } else {
        emit(LoginState(error: "Terjadi kesalahan. Silakan coba lagi."));
      }
    } catch (e) {
      emit(LoginState(error: "Terjadi kesalahan. Silakan coba lagi."));
    }
  }

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
