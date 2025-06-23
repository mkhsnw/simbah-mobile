import 'package:flutter/material.dart';
import 'package:simbah/models/transaction_model.dart';
import 'package:simbah/services/transaction_service.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final TransactionService _transactionService = TransactionService();
  ReportData? _reportData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final reportModel = await _transactionService.getReport(context: context);

      if (reportModel.success) {
        setState(() {
          _reportData = reportModel.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = reportModel.message.isEmpty
              ? 'Gagal memuat data laporan'
              : reportModel.message;
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

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReportData,
          ),
        ],
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
              _getCurrentMonthYear(),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),

            // Content berdasarkan state
            Expanded(
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : _buildReportContent(),
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
            'Memuat data laporan...',
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
            onPressed: _loadReportData,
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

  Widget _buildReportContent() {
    if (_reportData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Data laporan tidak tersedia',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Setoran',
                  _formatCurrency(_reportData!.totalDeposit),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Penarikan',
                  _formatCurrency(_reportData!.totalWithdraw),
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
                  '${_reportData!.totalTransaction} kali',
                  Icons.swap_horiz,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Sampah Terkumpul',
                  _formatWeight(_reportData!.totalWasteWeight),
                  Icons.recycling,
                  Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Additional info cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Saldo Saat Ini',
                  _formatCurrency(_reportData!.currentBalance),
                  Icons.account_balance_wallet,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Rata-rata Setoran',
                  _formatCurrency(_reportData!.averageDepositAmount),
                  Icons.bar_chart,
                  Colors.teal,
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
                        SizedBox(height: 4),
                        Text(
                          'Total ${_reportData!.depositCount} setoran dan ${_reportData!.withdrawalCount} penarikan',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
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
