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

  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
  ),
);
