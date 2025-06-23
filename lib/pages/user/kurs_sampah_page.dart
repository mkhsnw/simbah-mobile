import 'package:flutter/material.dart';
import 'package:simbah/models/waste_mode.dart';
import 'package:simbah/services/waste_service.dart';

class KursSampahPage extends StatefulWidget {
  @override
  _KursSampahPageState createState() => _KursSampahPageState();
}

class _KursSampahPageState extends State<KursSampahPage> {
  final WasteService _wasteService = WasteService();
  List<WasteData> _wasteData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Icon mapping untuk setiap jenis sampah
  final Map<String, IconData> _wasteIcons = {
    'botol plastik': Icons.local_drink,
    'plastik': Icons.local_drink,
    'kertas': Icons.description,
    'kardus': Icons.inventory_2,
    'kaleng': Icons.coffee,
    'besi': Icons.build,
    'kaca': Icons.wine_bar,
    'aluminium': Icons.hardware,
    'default': Icons.recycling,
  };

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final wasteModel = await _wasteService.getWasteData();

      if (wasteModel.success) {
        setState(() {
          _wasteData = wasteModel.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = wasteModel.message.isEmpty
              ? 'Gagal memuat data kurs sampah'
              : wasteModel.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  // IconData _getIconForWaste(String wasteName) {
  //   final lowerName = wasteName.toLowerCase();

  //   // Cari icon berdasarkan kata kunci dalam nama
  //   for (String key in _wasteIcons.keys) {
  //     if (lowerName.contains(key)) {
  //       return _wasteIcons[key]!;
  //     }
  //   }

  //   return _wasteIcons['default']!;
  // }

  String _formatPrice(String price) {
    final priceInt = int.tryParse(price) ?? 0;
    return 'Rp ${priceInt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadWasteData,
          ),
        ],
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
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : _buildWasteList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green.shade600),
          SizedBox(height: 16),
          Text(
            'Memuat data kurs sampah...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadWasteData,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteList() {
    if (_wasteData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Belum ada data kurs sampah',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWasteData,
      color: Colors.green.shade600,
      child: ListView.builder(
        itemCount: _wasteData.length,
        itemBuilder: (context, index) {
          final item = _wasteData[index];
          // final icon = _getIconForWaste(item.name);

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
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.recycling,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Per kg',
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
                      _formatPrice(item.pricePerKg),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                    Text(
                      '/kg',
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
    );
  }
}
