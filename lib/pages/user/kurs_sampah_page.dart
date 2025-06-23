import 'package:flutter/material.dart';

class KursSampahPage extends StatelessWidget {
  final List<Map<String, dynamic>> kursSampah = [
    {
      'jenis': 'Botol Plastik',
      'harga': 2500,
      'satuan': 'kg',
      'icon': Icons.local_drink,
      'color': Colors.blue,
    },
    {
      'jenis': 'Kertas',
      'harga': 1500,
      'satuan': 'kg',
      'icon': Icons.description,
      'color': Colors.orange,
    },
    {
      'jenis': 'Kardus',
      'harga': 2000,
      'satuan': 'kg',
      'icon': Icons.inventory_2,
      'color': Colors.brown,
    },
    {
      'jenis': 'Kaleng',
      'harga': 3000,
      'satuan': 'kg',
      'icon': Icons.coffee,
      'color': Colors.grey,
    },
    {
      'jenis': 'Besi',
      'harga': 4000,
      'satuan': 'kg',
      'icon': Icons.build,
      'color': Colors.blueGrey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Kurs Sampah',
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
              'Harga Sampah Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Update terakhir: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: kursSampah.length,
                itemBuilder: (context, index) {
                  final item = kursSampah[index];
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
                            color: item['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['color'],
                            size: 24,
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
                                'Per ${item['satuan']}',
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
                              'Rp ${item['harga'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade600,
                              ),
                            ),
                            Text(
                              '/${item['satuan']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
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
