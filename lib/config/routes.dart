import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/pages/admin/admin.user.dart';
import 'package:simbah/pages/admin/admin_dashboard_page.dart';
import 'package:simbah/pages/admin/admin_laporan.dart';
import 'package:simbah/pages/admin/admin_transaction_page.dart';
import 'package:simbah/pages/admin/admin_waste.dart';
import 'package:simbah/pages/login_page.dart';
import 'package:simbah/pages/register_page.dart';
import 'package:simbah/pages/splash_page.dart';
import 'package:simbah/pages/user/home_page.dart';
import 'package:simbah/services/user_service.dart';
import 'package:simbah/utils/token.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => DashboardPage()),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => AdminDashboardPage(),
    ),
    GoRoute(
      path: '/admin/reports',
      builder: (context, state) => AdminLaporanPage(),
    ),
    GoRoute(
      path: '/admin/waste-types',
      builder: (context, state) => AdminWasteTypePage(),
    ),
    GoRoute(path: '/admin/users', builder: (context, state) => AdminUserPage()),
    GoRoute(
      path: '/admin/transactions',
      builder: (context, state) => AdminTransaksiPage(),
    ),
  ],
  redirect: (context, state) async {
    final currentPath = state.uri.toString();

    // Skip redirect for splash screen
    if (currentPath == '/splash') {
      return null;
    }

    // Check if user is logged in
    final isLoggedIn = await _checkAuthStatus();

    if (!isLoggedIn) {
      // Not logged in, redirect to login
      if (currentPath != '/login') {
        return '/login';
      }
    } else {
      // User is logged in, check role and redirect appropriately
      final userRole = await _getUserRole();

      if (currentPath == '/login' || currentPath == '/splash') {
        // Redirect based on role
        if (userRole == 'ADMIN') {
          return '/admin/dashboard';
        } else {
          return '/home';
        }
      }

      // Validate current route matches user role
      if (userRole == 'ADMIN' && !currentPath.startsWith('/admin')) {
        return '/admin/dashboard';
      } else if (userRole == 'USER' && currentPath.startsWith('/admin')) {
        return '/home';
      }
    }

    return null; // No redirect needed
  },

  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
  ),
);

Future<bool> _checkAuthStatus() async {
  try {
    final token = await AuthManager.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Validate token by making a request
    final userService = UserService();
    final response = await userService.getUserInfo();
    return response.success;
  } catch (e) {
    print('Auth check failed: $e');
    return false;
  }
}

Future<String?> _getUserRole() async {
  try {
    final userService = UserService();
    final response = await userService.getUserInfo();
    if (response.success && response.data != null) {
      return response.data!.role;
    }
    return null;
  } catch (e) {
    print('Get user role failed: $e');
    return null;
  }
}
