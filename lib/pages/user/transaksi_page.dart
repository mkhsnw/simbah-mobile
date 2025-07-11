import 'package:flutter/material.dart';
import 'package:simbah/models/transaction_model.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:intl/intl.dart';

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionData> _transactions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final transactionModel = await _transactionService.getTransactions();

      if (transactionModel.success) {
        setState(() {
          _transactions = transactionModel.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = transactionModel.message.isEmpty ? 'Gagal memuat data transaksi' : transactionModel.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
      print('Error loading transactions: $e'); // Debug
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Tanggal tidak tersedia';
    }
    try {
      // Konversi ke waktu lokal dan format
      final localDate = date.toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(localDate);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Format tanggal tidak valid';
    }
  }

  String _formatCurrency(String amount) {
    final amountInt = int.tryParse(amount) ?? 0;
    return amountInt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String _getTransactionDescription(TransactionData transaction) {
    try {
      if (transaction.items != null && (transaction.items ?? []).isNotEmpty) {
        return transaction.items!
            .map((item) {
              final name = item.wasteCategory.name;
              final weight = item.weightInKg;
              final subtotal = item.subtotal;
              return '- $name: ${weight}kg (Rp${_formatCurrency(subtotal)})';
            })
            .join('\n');
      }
      return transaction.description.isNotEmpty ? transaction.description : 'Transaksi ${transaction.type}';
    } catch (e) {
      return 'Deskripsi tidak tersedia';
    }
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : _buildTransactionList(),
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
          Text('Memuat riwayat transaksi...', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
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
            onPressed: _loadTransactions,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text('Belum ada transaksi', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: Colors.green.shade600,
      child: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          bool isDebit = transaction.type.toLowerCase() == 'deposit';

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDebit ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDebit ? Icons.add : Icons.remove,
                    color: isDebit ? Colors.green.shade600 : Colors.red.shade600,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDebit ? 'Setoran' : 'Penarikan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getTransactionDescription(transaction),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 4),
                      Text(_formatDate(transaction.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isDebit ? '+' : '-'}Rp ${_formatCurrency(transaction.totalAmount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDebit ? Colors.green.shade600 : Colors.red.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'Berhasil',
                        style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w500),
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
