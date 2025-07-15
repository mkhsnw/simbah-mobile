import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:simbah/models/user_model.dart';
import 'package:simbah/models/waste_mode.dart';
import 'package:simbah/models/transaction_model.dart';
import 'package:simbah/services/user_service.dart';
import 'package:simbah/services/waste_service.dart';
import 'package:simbah/services/transaction_service.dart';

class AdminDetailMonthly extends StatefulWidget {
  const AdminDetailMonthly({required this.qp, super.key});
  final Map<String, String> qp;
  @override
  _AdminDetailMonthlyState createState() => _AdminDetailMonthlyState();
}

class _AdminDetailMonthlyState extends State<AdminDetailMonthly> {
  final UserService _userService = UserService();
  final WasteService _wasteService = WasteService();
  final TransactionService _transactionService = TransactionService();

  List<DataUser> _users = [];
  List<WasteData> _wasteTypes = [];
  List<TransactionData> _transactions = [];
  List<Map<String, dynamic>> depositItems = [
    {'wasteId': null, 'weight': null},
  ];
  final Map<String, int> monthMap = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };

  bool _isLoadingUsers = false;
  bool _isLoadingWastes = false;
  bool _isLoadingTransactions = false;

  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadWasteTypes();
    _loadTransactions();
  }

  int calculateTotalAmount() {
    int total = 0;
    for (var item in depositItems) {
      final waste = _wasteTypes.firstWhere(
        (w) => w.id == item['wasteId'],
        orElse: () => WasteData(id: '', name: '', pricePerKg: '0'),
      );
      final pricePerKg = double.tryParse(waste.pricePerKg) ?? 0;
      final weight = item['weight'] ?? 0;
      total += (pricePerKg * weight).round();
    }
    return total;
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final response = await _userService.getAllUsers(context: context);
      if (response.success) {
        setState(() {
          _users = response.data;
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _isLoadingUsers = false;
        });
        print('Error loading users: ${response.message}');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        return;
      }
      setState(() {
        _isLoadingUsers = false;
      });
      print('Error loading users: $e');
    }
  }

  Future<void> _loadWasteTypes() async {
    setState(() {
      _isLoadingWastes = true;
    });

    try {
      final response = await _wasteService.getWasteData(context: context);
      if (response.success) {
        setState(() {
          _wasteTypes = response.data;
          _isLoadingWastes = false;
        });
      } else {
        setState(() {
          _isLoadingWastes = false;
        });
        print('Error loading waste types: ${response.message}');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        return;
      }
      setState(() {
        _isLoadingWastes = false;
      });
      print('Error loading waste types: $e');
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final response = await _transactionService.getAllTransactions(context: context);
      if (response.success) {
        setState(() {
          // Convert dari List<Map<String, dynamic>> ke List<TransactionData>
          final raw = response.data.cast<TransactionData>();
          _transactions = raw.where((tx) {
            if (tx.updatedAt == null) return false;
            return tx.updatedAt!.month == monthMap["${widget.qp['month']}"] &&
                tx.updatedAt!.year.toString() == widget.qp['year'];
          }).toList();
          _transactions.sort((a, b) => a.user!.name.length.compareTo(b.user!.name.length));
          _isLoadingTransactions = false;
        });
      } else {
        setState(() {
          _isLoadingTransactions = false;
        });
        print('Error loading transactions: ${response.message}');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        return;
      }
      setState(() {
        _isLoadingTransactions = false;
      });
      print('Error loading transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Transaksi ${widget.qp["month"]} ${widget.qp['year']}',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin/reports'),
        ),
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: ['Semua', 'DEPOSIT', 'WITHDRAWAL'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
                SizedBox(width: 16),
                Spacer(),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: _isLoadingTransactions
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.green.shade600),
                        SizedBox(height: 16),
                        Text('Memuat transaksi...', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  )
                : _getFilteredTransactions().isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshTransactions,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _getFilteredTransactions().length,
                      itemBuilder: (context, index) {
                        final transaction = _getFilteredTransactions()[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'Tidak ada transaksi',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            _selectedFilter == 'Semua'
                ? 'Belum ada transaksi yang tersedia'
                : 'Tidak ada transaksi ${_selectedFilter.toLowerCase()}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTransactionDialog,
            icon: Icon(Icons.add),
            label: Text('Tambah Transaksi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshTransactions() async {
    await _loadUsers();
    await _loadWasteTypes();
    await _loadTransactions();
  }

  List<TransactionData> _getFilteredTransactions() {
    if (_selectedFilter == 'Semua') return _transactions;
    return _transactions.where((t) => t.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  Widget _buildTransactionCard(TransactionData transaction) {
    bool isDeposit = transaction.type == "DEPOSIT";

    // Get user name from user ID
    String userName = 'Unknown User';
    try {
      final user = _users.firstWhere((u) => u.id == transaction.userId);
      userName = user.name;
    } catch (e) {
      userName = 'Unknown User';
    }

    // Handle weight display safely
    String itemSummaryText = '';
    if (isDeposit && transaction.items != null && transaction.items!.isNotEmpty) {
      itemSummaryText = transaction.items!
          .map((item) {
            final name = item.wasteCategory?.name ?? 'Jenis tidak diketahui';
            final weight = item.weightInKg ?? '0';
            final subtotal = item.subtotal;
            return '- $name: ${weight}kg (Rp${_formatCurrency(subtotal)})';
          })
          .join('\n');
    }

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
              color: isDeposit ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDeposit ? Icons.add : Icons.remove,
              color: isDeposit ? Colors.green.shade600 : Colors.red.shade600,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                ),
                if (transaction.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(transaction.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
                if (itemSummaryText.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(itemSummaryText, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
                SizedBox(height: 4),
                Text(_formatDate(transaction.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDeposit ? '+' : '-'}Rp ${_formatCurrency(transaction.totalAmount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDeposit ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showEditTransactionDialog(transaction),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Icon(Icons.edit, size: 16, color: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteTransaction(transaction.id),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Icon(Icons.delete, size: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    final _formKey = GlobalKey<FormState>(); // Tambahkan form key
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final weightController = TextEditingController();
    String selectedType = 'DEPOSIT';
    String? selectedUserId;
    String? selectedWasteId;
    String selectedUserName = '';
    String selectedWasteName = '';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Tambah Transaksi'),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0), // Custom padding
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9, // Responsive width
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, // Max height
              maxWidth: 500, // Maximum width untuk tablet/desktop
            ),
            child: Form(
              // Wrap dengan Form
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedUserId,
                      decoration: InputDecoration(
                        labelText: 'Nama User',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: _isLoadingUsers
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 8),
                                Flexible(child: Text('Memuat user...')),
                              ],
                            )
                          : Text('Pilih User'),
                      isExpanded: true, // Mencegah overflow
                      items: _users.map((user) {
                        return DropdownMenuItem<String>(
                          value: user.id,
                          child: Text(
                            user.name,
                            overflow: TextOverflow.ellipsis, // Handle long names
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoadingUsers
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedUserId = value;
                                selectedUserName = _users
                                    .firstWhere(
                                      (user) => user.id == value,
                                      orElse: () =>
                                          DataUser(id: '', name: '', email: '', balance: '0', rekening: '', role: 'USER'),
                                    )
                                    .name;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih user terlebih dahulu';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Transaction Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tipe Transaksi',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                      items: ['DEPOSIT', 'WITHDRAWAL'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                          selectedWasteId = null;
                          selectedWasteName = '';
                          weightController.clear();
                          amountController.clear();
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Waste Type Dropdown (only for setoran)
                    if (selectedType == 'DEPOSIT') ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: depositItems.length,
                        itemBuilder: (context, index) {
                          final item = depositItems[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: item['wasteId'],
                                      decoration: InputDecoration(labelText: 'Jenis Sampah', border: OutlineInputBorder()),
                                      isExpanded: true,
                                      items: _wasteTypes.map((waste) {
                                        return DropdownMenuItem<String>(
                                          value: waste.id,
                                          child: Text('${waste.name} (Rp ${waste.pricePerKg}/kg)'),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setDialogState(() {
                                          depositItems[index]['wasteId'] = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Pilih jenis sampah';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  if (depositItems.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        setDialogState(() {
                                          depositItems.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(labelText: 'Berat (kg)', border: OutlineInputBorder()),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  setDialogState(() {
                                    depositItems[index]['weight'] = double.tryParse(value);
                                    amountController.text = calculateTotalAmount().toString();
                                  });
                                },
                                validator: (value) {
                                  final weight = double.tryParse(value ?? '');
                                  if (weight == null || weight <= 0) {
                                    return 'Berat harus lebih dari 0';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              depositItems.add({'wasteId': null, 'weight': null});
                            });
                          },
                          icon: Icon(Icons.add),
                          label: Text('Tambah Jenis Sampah'),
                        ),
                      ),
                    ],
                    SizedBox(height: 24),

                    // Amount Field
                    if (selectedType == 'WITHDRAWAL') ...[
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Penarikan',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                          helperText: 'Minimal Rp 1.000',
                          helperStyle: TextStyle(color: Colors.grey.shade600),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah harus diisi';
                          }

                          final amount = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                          if (amount == null) {
                            return 'Masukkan jumlah yang valid';
                          }

                          if (amount < 1000) {
                            return 'Minimal penarikan Rp 1.000';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                    ] else ...[
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Total Pendapatan',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                          enabled: false,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                    ],

                    // Description Field
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      maxLines: 2,
                      // validator: (value) {
                      //   if (value == null || value.trim().isEmpty) {
                      //     return 'Deskripsi harus diisi';
                      //   }
                      //   return null;
                      // },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: isLoading ? null : () => Navigator.pop(context), child: Text('Batal')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                      });

                      try {
                        if (selectedType == 'DEPOSIT') {
                          // {'wasteCategoryId': int.tryParse(item['wasteId']), 'weightInKg': item['weight']},
                          await _transactionService.createTransactionDeposit(
                            type: selectedType,
                            userId: selectedUserId!,
                            description: descriptionController.text.trim(),
                            items: depositItems
                                .map(
                                  (item) => {'wasteCategoryId': int.tryParse(item['wasteId']), 'weightInKg': item['weight']},
                                )
                                .toList(),
                            context: context,
                          );
                        } else {
                          final amount = int.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

                          if (amount < 1000) {
                            _showSnackBar('Minimal penarikan adalah Rp 1.000', Colors.red);
                            setDialogState(() {
                              isLoading = false;
                            });
                            return;
                          }

                          await _transactionService.createTransactionWithdraw(
                            type: selectedType,
                            userId: selectedUserId!,
                            amount: amount,
                            description: descriptionController.text.trim(),
                            context: context,
                          );
                        }

                        Navigator.pop(context);
                        _showSnackBar('Transaksi berhasil ditambahkan', Colors.green);
                        _loadTransactions();
                      } catch (e) {
                        _showSnackBar('Gagal menambahkan transaksi: ${e.toString()}', Colors.red);
                      } finally {
                        setDialogState(() {
                          isLoading = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(TransactionData transaction) {
    final _formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController(text: transaction.description ?? '');
    String selectedType = transaction.type;
    String? selectedUserId = transaction.userId;
    String selectedUserName = '';
    String selectedWasteName = '';
    bool isLoading = false;

    // Pre-fill data for editing
    amountController.text = transaction.totalAmount;

    List<Map<String, dynamic>> depositItems =
        transaction.items?.map((item) {
          return {'wasteId': item.wasteCategory?.id.toString(), 'weight': double.tryParse(item.weightInKg)};
        }).toList() ??
        [];

    // For deposit transactions, try to get weight from items
    // if (transaction.type == 'DEPOSIT' && transaction.items != null && transaction.items!.isNotEmpty) {
    //   weightController.text = transaction.items!.first.weightInKg;
    //   if (transaction.items!.first.wasteCategory != null) {
    //     selectedWasteId = transaction.items!.first.wasteCategory!.id.toString();
    //     selectedWasteName = transaction.items!.first.wasteCategory!.name;
    //   }
    // }
    void _updateAmountController(List<Map<String, dynamic>> items, void Function(void Function()) setDialogState) {
      int total = 0;
      for (var item in items) {
        final waste = _wasteTypes.firstWhere(
          (w) => w.id == item['wasteId'],
          orElse: () => WasteData(id: '', name: '', pricePerKg: '0'),
        );
        final price = double.tryParse(waste.pricePerKg) ?? 0;
        final weight = item['weight'] ?? 0;
        total += (price * weight).round();
      }
      setDialogState(() {
        amountController.text = total.toString();
      });
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Transaksi'),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User Dropdown (Read-only for edit)
                    DropdownButtonFormField<String>(
                      value: selectedUserId,
                      decoration: InputDecoration(
                        labelText: 'Nama User',
                        border: OutlineInputBorder(),
                        enabled: false, // Disable user change in edit mode
                      ),
                      hint: Text('User tidak dapat diubah'),
                      items: _users.map((user) {
                        return DropdownMenuItem<String>(value: user.id, child: Text(user.name));
                      }).toList(),
                      onChanged: null, // Disabled
                    ),
                    SizedBox(height: 16),

                    // Transaction Type (Read-only for edit)
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tipe Transaksi',
                        border: OutlineInputBorder(),
                        enabled: false, // Disable type change in edit mode
                      ),
                      items: ['DEPOSIT', 'WITHDRAWAL'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: null, // Disabled
                    ),
                    SizedBox(height: 16),

                    // Waste Type Dropdown (only for DEPOSIT)
                    if (selectedType == 'DEPOSIT') ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: depositItems.length,
                        itemBuilder: (context, index) {
                          final item = depositItems[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: item['wasteId'],
                                      decoration: InputDecoration(labelText: 'Jenis Sampah', border: OutlineInputBorder()),
                                      isExpanded: true,
                                      items: _wasteTypes.map((waste) {
                                        return DropdownMenuItem<String>(
                                          value: waste.id,
                                          child: Text('${waste.name} (Rp ${waste.pricePerKg}/kg)'),
                                        );
                                      }).toList(),
                                      onChanged: _isLoadingWastes
                                          ? null
                                          : (value) {
                                              setDialogState(() {
                                                depositItems[index]['wasteId'] = value;
                                                _updateAmountController(depositItems, setDialogState);
                                              });
                                            },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Pilih jenis sampah';
                                        return null;
                                      },
                                    ),
                                  ),
                                  if (depositItems.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        setDialogState(() {
                                          depositItems.removeAt(index);
                                          _updateAmountController(depositItems, setDialogState);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                initialValue: item['weight']?.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Berat (kg)',
                                  border: OutlineInputBorder(),
                                  suffixText: 'kg',
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  setDialogState(() {
                                    depositItems[index]['weight'] = double.tryParse(value);
                                    _updateAmountController(depositItems, setDialogState);
                                  });
                                },
                                validator: (value) {
                                  final weight = double.tryParse(value ?? '');
                                  if (weight == null || weight <= 0) return 'Berat harus lebih dari 0';
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              depositItems.add({'wasteId': null, 'weight': null});
                            });
                          },
                          icon: Icon(Icons.add),
                          label: Text('Tambah Jenis Sampah'),
                        ),
                      ),
                    ],

                    // Amount Field
                    if (selectedType == 'WITHDRAWAL') ...[
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Penarikan',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                          helperText: 'Minimal Rp 1.000',
                          helperStyle: TextStyle(color: Colors.grey.shade600),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah harus diisi';
                          }

                          final amount = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                          if (amount == null) {
                            return 'Masukkan jumlah yang valid';
                          }

                          if (amount < 1000) {
                            return 'Minimal penarikan Rp 1.000';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                    ] else ...[
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Total Pendapatan',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                          enabled: false,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                    ],

                    // Description Field
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                      maxLines: 2,
                      // validator: (value) {
                      //   if (value == null || value.trim().isEmpty) {
                      //     return 'Deskripsi harus diisi';
                      //   }
                      //   return null;
                      // },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: isLoading ? null : () => Navigator.pop(context), child: Text('Batal')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                      });

                      try {
                        if (selectedType == 'DEPOSIT') {
                          await _transactionService.editTransactionDeposit(
                            selectedUserId!,
                            descriptionController.text.trim(),
                            depositItems
                                .map(
                                  (item) => {'wasteCategoryId': int.tryParse(item['wasteId']), 'weightInKg': item['weight']},
                                )
                                .toList(),
                            transaction.id,
                          );
                        } else {
                          // Additional validation untuk withdrawal amount
                          final amount = int.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

                          if (amount < 1000) {
                            _showSnackBar('Minimal penarikan adalah Rp 1.000', Colors.red);
                            setDialogState(() {
                              isLoading = false;
                            });
                            return;
                          }

                          await _transactionService.editTransactionWithdraw(
                            selectedUserId!,
                            amount,
                            descriptionController.text.trim(),
                            transaction.id,
                          );
                        }

                        Navigator.pop(context);
                        _showSnackBar('Transaksi berhasil diperbarui', Colors.green);
                        _loadTransactions();
                      } catch (e) {
                        _showSnackBar('Gagal memperbarui transaksi: ${e.toString()}', Colors.red);
                      } finally {
                        setDialogState(() {
                          isLoading = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTransaction(String id) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
            SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.of(dialogContext).pop();

              // Show loading overlay
              _showDeleteLoadingDialog();

              try {
                // FIX: Use proper service method call
                await _transactionService.deleteTransaction(id);

                // Close loading dialog
                _hideLoadingDialog();

                // Show success and refresh
                _showSnackBar('Transaksi berhasil dihapus', Colors.green);
                await _loadTransactions();
              } catch (e) {
                print('Delete transaction error: $e');

                // Close loading dialog
                _hideLoadingDialog();

                // Show error
                _showSnackBar('Gagal menghapus transaksi: ${e.toString()}', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper methods for loading dialog
  bool _isShowingLoadingDialog = false;

  void _showDeleteLoadingDialog() {
    if (_isShowingLoadingDialog) return;

    _isShowingLoadingDialog = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600)),
                SizedBox(width: 20),
                Text('Menghapus transaksi...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (!_isShowingLoadingDialog) return;

    _isShowingLoadingDialog = false;
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showExportMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur export Excel sedang dalam pengembangan'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
        action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor, duration: Duration(seconds: 3)));
  }

  String _formatCurrency(dynamic amount) {
    int amountInt = 0;

    if (amount is String) {
      amountInt = int.tryParse(amount) ?? 0;
    } else if (amount is int) {
      amountInt = amount;
    } else if (amount is double) {
      amountInt = amount.round();
    }

    return NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(amountInt);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
