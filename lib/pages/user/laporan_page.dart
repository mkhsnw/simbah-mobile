import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LaporanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Laporan',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan Bulanan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Juni 2025',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Setoran',
                    'Rp 125.000',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Penarikan',
                    'Rp 50.000',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Transaksi',
                    '15 kali',
                    Icons.swap_horiz,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Sampah Terkumpul',
                    '45 kg',
                    Icons.recycling,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Chart placeholder
            Container(
              height: 200,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grafik Setoran Sampah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Grafik akan ditampilkan di sini',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
