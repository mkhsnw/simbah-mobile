// lib/pages/user/withdraw_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/models/user_model.dart';
import 'package:simbah/models/withdraw_model.dart';
import 'package:simbah/pages/user/withdraw_history_page.dart';
import 'package:simbah/services/user_service.dart';
import 'package:simbah/services/withdraw_request_service.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:simbah/utils/token.dart';

class WithdrawPage extends StatefulWidget {
  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final WithdrawRequestService _withdrawService = WithdrawRequestService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late TabController _tabController;
  DataUser? _userData;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _userService.getUserInfo();
      if (response.success && response.data != null) {
        setState(() {
          _userData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isEmpty
              ? 'Gagal memuat data user'
              : response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        context.go('/login');
      } else {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Kelola Saldo'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.attach_money), text: 'Request Penarikan'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat Request'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : TabBarView(
              controller: _tabController,
              children: [_buildRequestTab(), WithdrawHistoryTab()],
            ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Balance Header
          _buildBalanceHeader(),
          SizedBox(height: 24),
          // Withdraw Request Form
          _buildWithdrawForm(),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade600, Colors.green.shade400],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Tersedia',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _userData?.formattedBalance ?? 'Rp 0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Bank Sampah ${_userData?.name ?? ''}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawForm() {
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green.shade600),
              SizedBox(width: 8),
              Text(
                'Request Penarikan Saldo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Amount Field
          Text(
            'Jumlah Penarikan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah (min. Rp 50.000)',
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green.shade600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          SizedBox(height: 20),

          // Description Field
          Text(
            'Keterangan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Masukkan keterangan (opsional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green.shade600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          SizedBox(height: 24),

          // Info Box
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Syarat & Ketentuan:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Minimal penarikan Rp 50.000\n'
                        '• Maksimal penarikan Rp 1.000.000/hari\n'
                        '• Proses 1-2 hari kerja\n'
                        '• Wajib membawa KTP saat pengambilan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitWithdrawRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Memproses...'),
                      ],
                    )
                  : Text(
                      'Ajukan Request Penarikan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadUserData,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Integrasikan dengan API Service
  Future<void> _submitWithdrawRequest() async {
    final amountText = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    // Validation
    if (amountText.isEmpty) {
      _showSnackBar('Jumlah penarikan tidak boleh kosong', Colors.red);
      return;
    }

    final amount = int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount < 50000) {
      _showSnackBar('Jumlah penarikan minimal Rp 50.000', Colors.red);
      return;
    }

    // if (amount > (_userData?.balance ?? 0)) {
    //   _showSnackBar('Saldo tidak mencukupi', Colors.red);
    //   return;
    // }

    if (amount > 1000000) {
      _showSnackBar('Jumlah penarikan maksimal Rp 1.000.000', Colors.red);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // ✅ Call real API service
      final response = await _withdrawService.createWithdrawRequest(
        amount,
        description.isEmpty ? 'Penarikan saldo' : description,
      );

      _showSnackBar(
        'Request penarikan berhasil diajukan. Menunggu persetujuan admin.',
        Colors.green,
      );

      // Clear form
      _amountController.clear();
      _descriptionController.clear();

      // Refresh user data and switch to history tab
      await _loadUserData();
      _tabController.animateTo(1); // Switch to history tab
    } catch (e) {
      if (e is UnauthorizedException) {
        context.go('/login');
      } else {
        _showSnackBar('Gagal mengajukan request: ${e.toString()}', Colors.red);
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
