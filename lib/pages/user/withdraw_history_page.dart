import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/models/withdraw_model.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:simbah/services/withdraw_request_service.dart';

class WithdrawHistoryTab extends StatefulWidget {
  @override
  State<WithdrawHistoryTab> createState() => _WithdrawHistoryTabState();
}

class _WithdrawHistoryTabState extends State<WithdrawHistoryTab> {
  final WithdrawRequestService _withdrawService = WithdrawRequestService();
  List<WithdrawData> _withdrawHistory = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWithdrawHistory();
  }

  Future<void> _loadWithdrawHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _withdrawService.getWithdrawRequests();
      setState(() {
        _withdrawHistory = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (e is UnauthorizedException) {
        context.go('login');
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat riwayat: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadWithdrawHistory,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _withdrawHistory.isEmpty
          ? _buildEmptyWidget()
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _withdrawHistory.length,
              itemBuilder: (context, index) {
                final item = _withdrawHistory[index];
                return _buildWithdrawHistoryCard(item);
              },
            ),
    );
  }

  Widget _buildWithdrawHistoryCard(WithdrawData item) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    bool canCancel = false;

    switch (item.status.toUpperCase()) {
      case 'APPROVED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Disetujui';
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Ditolak';
        break;
      case 'CANCELLED':
        statusColor = Colors.grey;
        statusIcon = Icons.remove_circle;
        statusText = 'Dibatalkan';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Menunggu';
        canCancel = true;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp ${_formatCurrency(int.parse(item.amount))}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Description
            if (item.description.isNotEmpty) ...[
              Text(
                'Keterangan:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                item.description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              SizedBox(height: 12),
            ],

            // Dates
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                SizedBox(width: 4),
                Text(
                  'Diajukan: ${_formatDate(item.requestedAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.update, size: 16, color: Colors.grey.shade500),
                SizedBox(width: 4),
                Text(
                  'Update: ${_formatDate(item.updatedAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),

            // Cancel Button for pending requests
            if (canCancel) ...[
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showCancelDialog(item),
                  icon: Icon(Icons.cancel_outlined, size: 16),
                  label: Text('Batalkan'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat penarikan',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            'Request penarikan Anda akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadWithdrawHistory,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(WithdrawData item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade600),
            SizedBox(width: 8),
            Text('Batalkan Request'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan request penarikan sebesar Rp ${_formatCurrency(int.parse(item.amount))}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              _cancelRequest(item.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      await _withdrawService.cancelUserRequest(requestId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request berhasil dibatalkan'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh history
      _loadWithdrawHistory();
    } catch (e) {
      if (e is UnauthorizedException) {
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
