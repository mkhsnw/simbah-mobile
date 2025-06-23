import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TransaksiPage extends StatelessWidget {
  final List<Map<String, dynamic>> transaksi = [
    {
      'tanggal': '23/06/2025',
      'jenis': 'Setoran',
      'deskripsi': 'Botol Plastik - 5 kg',
      'nominal': 12500,
      'status': 'Berhasil',
    },
    {
      'tanggal': '22/06/2025',
      'jenis': 'Penarikan',
      'deskripsi': 'Penarikan Saldo',
      'nominal': -50000,
      'status': 'Berhasil',
    },
    {
      'tanggal': '20/06/2025',
      'jenis': 'Setoran',
      'deskripsi': 'Kertas - 8 kg',
      'nominal': 12000,
      'status': 'Berhasil',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Transaksi',
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
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: transaksi.length,
                itemBuilder: (context, index) {
                  final item = transaksi[index];
                  bool isDebit = item['nominal'] > 0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
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
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDebit
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDebit ? Icons.add : Icons.remove,
                            color: isDebit
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['jenis'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['deskripsi'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['tanggal'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isDebit ? '+' : ''}Rp ${item['nominal'].abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDebit
                                    ? Colors.green.shade600
                                    : Colors.red.shade600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
