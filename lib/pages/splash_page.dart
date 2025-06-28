import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/services/user_service.dart';
import 'package:simbah/utils/token.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigasi ke halaman login setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      _checkAuthAndRedirect();
    });
  }

  Future<void> _checkAuthAndRedirect() async {
    // Show splash for at least 2 seconds
    await Future.delayed(Duration(seconds: 2));
    
    try {
      final token = await AuthManager.getToken();
      
      if (token == null || token.isEmpty) {
        // No token, go to login
        if (mounted) {
          context.go('/login');
        }
        return;
      }
      
      // Validate token and get user info
      final userService = UserService();
      final response = await userService.getUserInfo();
      
      if (response.success && response.data != null) {
        // Token valid, redirect based on role
        if (mounted) {
          if (response.data!.role == 'ADMIN') {
            context.go('/admin/dashboard');
          } else {
            context.go('/home');
          }
        }
      } else {
        // Token invalid, clear and go to login
        await AuthManager.clearToken();
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      print('Splash auth check error: $e');
      // Error occurred, clear token and go to login
      await AuthManager.clearToken();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Menggunakan gradient yang sama dengan halaman login untuk konsistensi
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFF0F8F0)],
          ),
        ),
        child: Center(
          // Animasi untuk memunculkan konten secara perlahan (fade-in)
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, double opacity, child) {
              return Opacity(opacity: opacity, child: child);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.recycling,
                    size: 50,
                    color: Colors.green.shade700,
                  ),
                ),
                // Judul Aplikasi
                Text(
                  'SIMBAH',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  'Sistem Informasi Bank Sampah',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
