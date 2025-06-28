import 'package:flutter/material.dart';
import 'package:simbah/models/waste_mode.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:simbah/services/waste_service.dart';
import 'package:simbah/utils/exception_manager.dart';

class KursSampahPage extends StatefulWidget {
  @override
  _KursSampahPageState createState() => _KursSampahPageState();
}

class _KursSampahPageState extends State<KursSampahPage> {
  final WasteService _wasteService = WasteService();
  List<WasteData> _wasteData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _noDataFound = false; // Add flag for no data state

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _noDataFound = false;
    });

    try {
      final wasteModel = await _wasteService.getWasteData(context: context);

      if (wasteModel.success) {
        setState(() {
          _wasteData = wasteModel.data;
          _isLoading = false;
          _noDataFound = wasteModel.data.isEmpty;
        });
      } else {
        // Jika success false tapi tidak exception
        setState(() {
          _noDataFound = true;
          _errorMessage = '';
          _isLoading = false;
          _wasteData = [];
        });
      }
    } on NoDataException catch (e) {
      // Handle no data case
      setState(() {
        _noDataFound = true;
        _errorMessage = '';
        _isLoading = false;
        _wasteData = [];
      });
    } on UnauthorizedException catch (e) {
      // Handle unauthorized
      setState(() {
        _errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        _isLoading = false;
        _noDataFound = false;
      });
    } catch (e) {
      // Handle other errors
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
        _noDataFound = false;
      });
    }
  }

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
            tooltip: 'Refresh Data',
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
                  : _noDataFound || _wasteData.isEmpty
                  ? _buildNoDataWidget()
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
            'Gagal Memuat Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          SizedBox(height: 24),
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

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Data Sampah Tidak Ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Belum ada data kurs sampah yang tersedia saat ini. Silakan coba lagi nanti atau hubungi admin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _loadWasteData,
                icon: Icon(Icons.refresh),
                label: Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade600,
                  side: BorderSide(color: Colors.green.shade600),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Option to contact admin or navigate somewhere
                  _showContactAdminDialog();
                },
                icon: Icon(Icons.support_agent),
                label: Text('Hubungi Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWasteList() {
    return RefreshIndicator(
      onRefresh: _loadWasteData,
      color: Colors.green.shade600,
      child: ListView.builder(
        physics:
            AlwaysScrollableScrollPhysics(), // Allow pull to refresh even with few items
        itemCount: _wasteData.length,
        itemBuilder: (context, index) {
          final item = _wasteData[index];

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
                        'Per kilogram',
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

  void _showContactAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.support_agent, color: Colors.green.shade600),
            SizedBox(width: 8),
            Text('Hubungi Admin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jika Anda membutuhkan bantuan atau informasi lebih lanjut tentang kurs sampah, silakan hubungi admin melalui:',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: Colors.grey.shade600, size: 20),
                SizedBox(width: 8),
                Text('admin@simbah.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
                SizedBox(width: 8),
                Text('+62 123 456 789'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
