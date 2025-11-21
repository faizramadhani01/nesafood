import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'cubit/login_cubit.dart';
import 'theme.dart';
import 'admin/login_admin_screen.dart';

enum LoginType { user, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginType _loginType = LoginType.user;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            final user = emailController.text.trim();
            context.go('/home', extra: user);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/image.png', fit: BoxFit.cover),
                Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width < 600
                              ? MediaQuery.of(context).size.width * 0.9
                              : 500,
                          padding: EdgeInsets.symmetric(
                            vertical: 9.h,
                            horizontal: 6.w,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ).withOpacity(0.60),
                            borderRadius: BorderRadius.circular(3.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              // Pilihan login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ChoiceChip(
                                    label: Text('User'),
                                    selected: _loginType == LoginType.user,
                                    onSelected: (_) => setState(
                                      () => _loginType = LoginType.user,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  ChoiceChip(
                                    label: Text('Admin'),
                                    selected: _loginType == LoginType.admin,
                                    onSelected: (_) => setState(
                                      () => _loginType = LoginType.admin,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              // Email field
                              TextField(
                                controller: emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.12),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 2.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              // Password field
                              TextField(
                                controller: passwordController,
                                obscureText: !showPassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.12),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 2.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.5.h),
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () async {
                                          if (_loginType == LoginType.user) {
                                            context.read<LoginCubit>().login(
                                              emailController.text,
                                              passwordController.text,
                                            );
                                          } else {
                                            // Navigasi ke login admin
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const AdminLoginScreen(),
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: NesaColors.terracotta,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.w),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2.h,
                                    ),
                                  ),
                                  child: state.isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        )
                                      : Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              // Forgot Password & Sign Up
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot Password ?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.go('/signin');
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // OR LOGIN WITH
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white38,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                    ),
                                    child: Text(
                                      'OR LOGIN WITH',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      'assets/google.png',
                                      width: 3.w,
                                      height: 6.w,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      'assets/facebook.png',
                                      width: 3.w,
                                      height: 6.w,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
