// lib/pages/admin/admin_dashboard_page.dart
// filepath: d:\Coding\Freelance\simbah\lib\pages\admin\admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/utils/auth_manager.dart';
import 'package:simbah/utils/token.dart';

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Dashboard Admin',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthManager.handleUnauthorized(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            Text('Kelola sistem bank sampah dengan mudah', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            SizedBox(height: 32),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Transaksi',
                    'Kelola setoran & penarikan',
                    Icons.swap_horiz,
                    Colors.blue,
                    '/admin/transactions',
                  ),
                  _buildMenuCard(context, 'Pengguna', 'Manajemen data user', Icons.people, Colors.purple, '/admin/users'),
                  // ✅ Menu Baru untuk Withdraw Request
                  _buildMenuCard(
                    context,
                    'Request Penarikan',
                    'Kelola permintaan penarikan',
                    Icons.account_balance_wallet,
                    Colors.teal,
                    '/admin/withdraw-requests',
                  ),
                  _buildMenuCard(
                    context,
                    'Laporan',
                    'Laporan transaksi tahunan',
                    Icons.bar_chart,
                    Colors.orange,
                    '/admin/reports',
                  ),
                  _buildMenuCard(
                    context,
                    'Jenis Sampah',
                    'Kelola jenis & harga sampah',
                    Icons.recycling,
                    Colors.green,
                    '/admin/waste-types',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
