import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/admin_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String? adminId;
  final String? kantinId;

  AdminState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.adminId,
    this.kantinId,
  });
}

class AdminCubit extends Cubit<AdminState> {
  final AdminAuthService _adminAuthService = AdminAuthService();

  AdminCubit() : super(AdminState());

  Future<void> login(String email, String password) async {
    emit(AdminState(isLoading: true));
    try {
      final user = await _adminAuthService.signInAdmin(email, password);
      if (user != null) {
        // Ambil data admin dari Firestore
        final doc = await _adminAuthService.getAdminData(user.uid);
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['role'] == 'admin') {
          emit(
            AdminState(
              isSuccess: true,
              adminId: user.uid,
              kantinId: data['kantinId'],
            ),
          );
        } else {
          emit(AdminState(error: "Akun ini bukan admin."));
        }
      } else {
        emit(AdminState(error: "Login gagal"));
      }
    } catch (e) {
      emit(AdminState(error: "Login gagal: ${e.toString()}"));
    }
  }
}
