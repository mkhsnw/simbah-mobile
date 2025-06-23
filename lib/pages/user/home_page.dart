import 'package:flutter/material.dart';
import 'package:simbah/pages/user/info_rekening_page.dart';
import 'package:simbah/pages/user/kurs_sampah_page.dart';
import 'package:simbah/pages/user/laporan_page.dart';
import 'package:simbah/pages/user/transaksi_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    InfoRekeningPage(),
    KursSampahPage(),
    TransaksiPage(),
    LaporanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green.shade600,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Info Rekening',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money),
              label: 'Kurs Sampah',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_outlined),
              activeIcon: Icon(Icons.swap_horiz),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Laporan',
            ),
          ],
        ),
      ),
    );
  }
}
