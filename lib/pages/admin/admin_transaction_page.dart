import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:simbah/models/user_model.dart';
import 'package:simbah/models/waste_mode.dart';
import 'package:simbah/models/transaction_model.dart';
import 'package:simbah/services/user_service.dart';
import 'package:simbah/services/waste_service.dart';
import 'package:simbah/services/transaction_service.dart';

class AdminTransaksiPage extends StatefulWidget {
  @override
  _AdminTransaksiPageState createState() => _AdminTransaksiPageState();
}

class _AdminTransaksiPageState extends State<AdminTransaksiPage> {
  final UserService _userService = UserService();
  final WasteService _wasteService = WasteService();
  final TransactionService _transactionService = TransactionService();

  List<DataUser> _users = [];
  List<WasteData> _wasteTypes = [];
  List<TransactionData> _transactions = [];

  bool _isLoadingUsers = false;
  bool _isLoadingWastes = false;
  bool _isLoadingTransactions = false;

  String _selectedFilter = 'Semua';
  bool _isLoading = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadWasteTypes();
    _loadTransactions();
  }

  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Create Excel workbook dengan try-catch
      Excel? excel;
      try {
        excel = Excel.createExcel();
      } catch (e) {
        print('Excel creation error: $e');
        throw Exception('Gagal membuat file Excel: ${e.toString()}');
      }

      if (excel == null) {
        throw Exception('Gagal menginisialisasi Excel');
      }

      // Remove default sheet safely
      try {
        if (excel.sheets.containsKey('Sheet1')) {
          excel.delete('Sheet1');
        }
      } catch (e) {
        print('Warning: Could not delete Sheet1: $e');
      }

      // Create transaction sheet
      Sheet transactionSheet = excel['Laporan Transaksi'];

      // Add headers with proper styling
      List<String> headers = [
        'No',
        'ID Transaksi',
        'Tanggal',
        'Nama User',
        'Email User',
        'Tipe Transaksi',
        'Total Amount',
        'Deskripsi',
        'Items Detail',
        'Total Berat (kg)',
      ];

      // Set headers with error handling
      for (int i = 0; i < headers.length; i++) {
        try {
          var cell = transactionSheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          );
          cell.value = TextCellValue(headers[i]);

          // Apply styling with try-catch
          try {
            cell.cellStyle = CellStyle(
              bold: true,
              backgroundColorHex: ExcelColor.green300,
              fontColorHex: ExcelColor.black,
            );
          } catch (e) {
            print('Warning: Could not apply cell style: $e');
          }
        } catch (e) {
          print('Error setting header cell $i: $e');
        }
      }

      // Add data rows
      List<TransactionData> dataToExport = _selectedFilter == 'Semua'
          ? _transactions
          : _getFilteredTransactions();

      for (int i = 0; i < dataToExport.length; i++) {
        TransactionData transaction = dataToExport[i];
        int rowIndex = i + 1;

        // Get user name and email
        String userName = 'Unknown User';
        String userEmail = 'Unknown Email';
        try {
          final user = _users.firstWhere((u) => u.id == transaction.userId);
          userName = user.name;
          userEmail = user.email;
        } catch (e) {
          // Keep default values
        }

        // Format items detail
        String itemsDetail = '';
        double totalWeight = 0;

        if (transaction.items != null && transaction.items!.isNotEmpty) {
          List<String> itemStrings = [];
          for (var item in transaction.items!) {
            double weight = double.tryParse(item.weightInKg) ?? 0;
            totalWeight += weight;

            String wasteName = 'Unknown Waste';
            if (item.wasteCategory != null) {
              wasteName = item.wasteCategory!.name;
            }

            itemStrings.add(
              '$wasteName (${item.weightInKg} kg - Rp ${item.subtotal})',
            );
          }
          itemsDetail = itemStrings.join('; ');
        }

        // Add data to cells with error handling
        List<dynamic> rowData = [
          i + 1,
          transaction.id,
          _formatDate(transaction.createdAt),
          userName,
          userEmail,
          transaction.type,
          'Rp ${_formatCurrency(transaction.totalAmount)}',
          transaction.description ?? '',
          itemsDetail,
          totalWeight,
        ];

        for (int j = 0; j < rowData.length; j++) {
          try {
            var cell = transactionSheet.cell(
              CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
            );

            // Set value based on type
            if (rowData[j] is int) {
              cell.value = IntCellValue(rowData[j]);
            } else if (rowData[j] is double) {
              cell.value = DoubleCellValue(rowData[j]);
            } else {
              cell.value = TextCellValue(rowData[j].toString());
            }

            // Alternate row colors
            if (i % 2 == 1) {
              try {
                cell.cellStyle = CellStyle(
                  backgroundColorHex: ExcelColor.grey100,
                );
              } catch (e) {
                print('Warning: Could not apply row color: $e');
              }
            }
          } catch (e) {
            print('Error setting data cell [$i][$j]: $e');
          }
        }
      }

      // Create summary sheet
      try {
        Sheet summarySheet = excel['Ringkasan'];

        // Add summary data
        summarySheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(
          'RINGKASAN TRANSAKSI',
        );
        summarySheet.cell(CellIndex.indexByString("A3")).value = TextCellValue(
          'Filter Data',
        );
        summarySheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(
          _selectedFilter,
        );
        summarySheet.cell(CellIndex.indexByString("A4")).value = TextCellValue(
          'Total Transaksi',
        );
        summarySheet.cell(CellIndex.indexByString("B4")).value = IntCellValue(
          dataToExport.length,
        );
        summarySheet.cell(CellIndex.indexByString("A5")).value = TextCellValue(
          'Tanggal Export',
        );
        summarySheet.cell(CellIndex.indexByString("B5")).value = TextCellValue(
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        );

        // Calculate totals
        int totalDeposit = 0;
        int totalWithdrawal = 0;

        for (var transaction in dataToExport) {
          int amount = int.tryParse(transaction.totalAmount) ?? 0;
          if (transaction.type == 'DEPOSIT') {
            totalDeposit += amount;
          } else if (transaction.type == 'WITHDRAWAL') {
            totalWithdrawal += amount;
          }
        }

        summarySheet.cell(CellIndex.indexByString("A7")).value = TextCellValue(
          'DETAIL FINANCIALS',
        );
        summarySheet.cell(CellIndex.indexByString("A8")).value = TextCellValue(
          'Total Setoran',
        );
        summarySheet.cell(CellIndex.indexByString("B8")).value = TextCellValue(
          'Rp ${_formatCurrency(totalDeposit)}',
        );
        summarySheet.cell(CellIndex.indexByString("A9")).value = TextCellValue(
          'Total Penarikan',
        );
        summarySheet.cell(CellIndex.indexByString("B9")).value = TextCellValue(
          'Rp ${_formatCurrency(totalWithdrawal)}',
        );
        summarySheet.cell(CellIndex.indexByString("A10")).value = TextCellValue(
          'Saldo Bersih',
        );
        summarySheet.cell(CellIndex.indexByString("B10")).value = TextCellValue(
          'Rp ${_formatCurrency(totalDeposit - totalWithdrawal)}',
        );
      } catch (e) {
        print('Warning: Could not create summary sheet: $e');
      }

      // Set column widths with error handling
      try {
        for (int col = 0; col < headers.length; col++) {
          transactionSheet.setColumnWidth(col, 20);
        }
      } catch (e) {
        print('Warning: Could not set column widths: $e');
      }

      // Generate filename
      String fileName =
          'Laporan_Transaksi_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.xlsx';

      // Encode Excel to bytes
      List<int>? bytes;
      try {
        bytes = excel.encode();
      } catch (e) {
        print('Excel encode error: $e');
        throw Exception('Gagal mengkonversi Excel: ${e.toString()}');
      }

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Gagal menghasilkan data Excel');
      }

      // Use FilePicker to save file
      String? outputFile;
      try {
        outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Simpan Laporan Excel',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
          bytes: Uint8List.fromList(bytes),
        );
      } catch (e) {
        print('FilePicker error: $e');
        // Fallback to manual save
        await _saveFileManually(bytes, fileName);
        return;
      }

      if (outputFile != null) {
        _showSnackBar('File berhasil disimpan: $fileName', Colors.green);
        // _showOpenFileDialog(outputFile);
      } else {
        _showSnackBar('Export dibatalkan', Colors.orange);
      }
    } catch (e) {
      print('Export error: $e');
      _showSnackBar('Gagal export file: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // Fallback method untuk save manual
  Future<void> _saveFileManually(List<int> bytes, String fileName) async {
    try {
      // Try to save to Downloads directory
      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final file = File('${downloadsDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          _showSnackBar(
            'File berhasil disimpan di Downloads: $fileName',
            Colors.green,
          );
          return;
        }
      }

      // Fallback to app documents directory
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      _showSnackBar('File berhasil disimpan: ${file.path}', Colors.green);
    } catch (e) {
      print('Manual save error: $e');
      _showSnackBar('Gagal menyimpan file: ${e.toString()}', Colors.red);
    }
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
      final response = await _transactionService.getAllTransactions(
        context: context,
      );
      if (response.success) {
        setState(() {
          // Convert dari List<Map<String, dynamic>> ke List<TransactionData>
          _transactions = response.data.cast<TransactionData>();
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
          'Transaksi',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: Colors.white),
            onPressed: _isLoading ? null : _exportToExcel,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddTransactionDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Filter: ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: ['Semua', 'DEPOSIT', 'WITHDRAWAL']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
                SizedBox(width: 16),
                if (_isExporting)
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Exporting...',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                Spacer(),
                Text(
                  'Total: ${_getFilteredTransactions().length} transaksi',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
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
                        Text(
                          'Memuat transaksi...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
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
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
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
    return _transactions
        .where((t) => t.type.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
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
    String weightText = '';
    if (isDeposit &&
        transaction.items != null &&
        transaction.items!.isNotEmpty) {
      try {
        final weight = transaction.items!.first.weightInKg;
        weightText = 'Berat: ${weight} kg';
      } catch (e) {
        // Fallback jika weightInKg tidak ada
        try {
          final weight = transaction.items!.first.weightInKg;
          weightText = 'Berat: ${weight} kg';
        } catch (e2) {
          weightText = '';
        }
      }
    }

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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction.description ?? 'No description',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                if (weightText.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    weightText,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
                SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
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
                  color: isDeposit
                      ? Colors.green.shade600
                      : Colors.red.shade600,
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
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.edit, size: 16, color: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteTransaction(transaction.id),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: _isLoadingUsers
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
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
                            overflow:
                                TextOverflow.ellipsis, // Handle long names
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
                                      orElse: () => DataUser(
                                        id: '',
                                        name: '',
                                        email: '',
                                        balance: '0',
                                        rekening: '',
                                        role: 'USER',
                                      ),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      isExpanded: true,
                      items: ['DEPOSIT', 'WITHDRAWAL']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
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
                      DropdownButtonFormField<String>(
                        value: selectedWasteId,
                        decoration: InputDecoration(
                          labelText: 'Jenis Sampah',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: _isLoadingWastes
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('Memuat jenis sampah...'),
                                  ),
                                ],
                              )
                            : Text('Pilih Jenis Sampah'),
                        isExpanded: true, // Key fix untuk mencegah overflow
                        items: _wasteTypes.map((waste) {
                          return DropdownMenuItem<String>(
                            value: waste.id,
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                '${waste.name} (Rp ${waste.pricePerKg}/kg)',
                                overflow:
                                    TextOverflow.ellipsis, // Handle long text
                                maxLines: 1,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: _isLoadingWastes
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedWasteId = value;
                                  final selectedWaste = _wasteTypes.firstWhere(
                                    (waste) => waste.id == value,
                                    orElse: () => WasteData(
                                      id: '',
                                      name: '',
                                      pricePerKg: '0',
                                    ),
                                  );
                                  selectedWasteName = selectedWaste.name;

                                  if (weightController.text.isNotEmpty) {
                                    final weight =
                                        double.tryParse(
                                          weightController.text,
                                        ) ??
                                        0;
                                    final pricePerKg =
                                        double.tryParse(
                                          selectedWaste.pricePerKg,
                                        ) ??
                                        0;
                                    final totalAmount = (weight * pricePerKg)
                                        .round();
                                    amountController.text = totalAmount
                                        .toString();
                                  }
                                });
                              },
                        validator: (value) {
                          if (selectedType == 'DEPOSIT' &&
                              (value == null || value.isEmpty)) {
                            return 'Pilih jenis sampah terlebih dahulu';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Weight Field
                      TextFormField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Berat (kg)',
                          border: OutlineInputBorder(),
                          suffixText: 'kg',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (selectedType == 'DEPOSIT' &&
                              (value == null || value.isEmpty)) {
                            return 'Berat harus diisi';
                          }
                          if (selectedType == 'DEPOSIT') {
                            final weight = double.tryParse(value!);
                            if (weight == null || weight <= 0) {
                              return 'Berat harus lebih dari 0';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (selectedWasteId != null && value.isNotEmpty) {
                            final weight = double.tryParse(value) ?? 0;
                            final selectedWaste = _wasteTypes.firstWhere(
                              (waste) => waste.id == selectedWasteId,
                              orElse: () =>
                                  WasteData(id: '', name: '', pricePerKg: '0'),
                            );
                            final pricePerKg =
                                double.tryParse(selectedWaste.pricePerKg) ?? 0;
                            final totalAmount = (weight * pricePerKg).round();
                            setDialogState(() {
                              amountController.text = totalAmount.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                    ],

                    // Amount Field
                    if (selectedType == 'WITHDRAWAL') ...[
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Penarikan',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                          helperText: 'Minimal Rp 50.000',
                          helperStyle: TextStyle(color: Colors.grey.shade600),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah harus diisi';
                          }

                          final amount = int.tryParse(
                            value.replaceAll(RegExp(r'[^0-9]'), ''),
                          );
                          if (amount == null) {
                            return 'Masukkan jumlah yang valid';
                          }

                          if (amount < 50000) {
                            return 'Minimal penarikan Rp 50.000';
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi harus diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Batal'),
            ),
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
                          await _transactionService.createTransactionDeposit(
                            type: selectedType,
                            userId: selectedUserId!,
                            description: descriptionController.text.trim(),
                            items: [
                              {
                                'wasteCategoryId': int.tryParse(
                                  selectedWasteId!,
                                ),
                                'weightInKg':
                                    double.tryParse(weightController.text) ?? 0,
                              },
                            ],
                            context: context,
                          );
                        } else {
                          final amount =
                              int.tryParse(
                                amountController.text.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                ),
                              ) ??
                              0;

                          if (amount < 50000) {
                            _showSnackBar(
                              'Minimal penarikan adalah Rp 50.000',
                              Colors.red,
                            );
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
                        _showSnackBar(
                          'Transaksi berhasil ditambahkan',
                          Colors.green,
                        );
                        _loadTransactions();
                      } catch (e) {
                        _showSnackBar(
                          'Gagal menambahkan transaksi: ${e.toString()}',
                          Colors.red,
                        );
                      } finally {
                        setDialogState(() {
                          isLoading = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
              ),
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
    final descriptionController = TextEditingController(
      text: transaction.description ?? '',
    );
    final weightController = TextEditingController();
    String selectedType = transaction.type;
    String? selectedUserId = transaction.userId;
    String? selectedWasteId;
    String selectedUserName = '';
    String selectedWasteName = '';
    bool isLoading = false;

    // Pre-fill data for editing
    amountController.text = transaction.totalAmount;

    // For deposit transactions, try to get weight from items
    if (transaction.type == 'DEPOSIT' &&
        transaction.items != null &&
        transaction.items!.isNotEmpty) {
      weightController.text = transaction.items!.first.weightInKg;
      if (transaction.items!.first.wasteCategory != null) {
        selectedWasteId = transaction.items!.first.wasteCategory!.id.toString();
        selectedWasteName = transaction.items!.first.wasteCategory!.name;
      }
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
                        return DropdownMenuItem<String>(
                          value: user.id,
                          child: Text(user.name),
                        );
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
                      items: ['DEPOSIT', 'WITHDRAWAL']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: null, // Disabled
                    ),
                    SizedBox(height: 16),

                    // Waste Type Dropdown (only for DEPOSIT)
                    if (selectedType == 'DEPOSIT') ...[
                      DropdownButtonFormField<String>(
                        value: selectedWasteId,
                        decoration: InputDecoration(
                          labelText: 'Jenis Sampah',
                          border: OutlineInputBorder(),
                        ),
                        hint: _isLoadingWastes
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Memuat jenis sampah...'),
                                ],
                              )
                            : Text('Pilih Jenis Sampah'),
                        isExpanded: true,
                        items: _wasteTypes.map((waste) {
                          return DropdownMenuItem<String>(
                            value: waste.id,
                            child: Text(
                              '${waste.name} (Rp ${waste.pricePerKg}/kg)',
                            ),
                          );
                        }).toList(),
                        onChanged: _isLoadingWastes
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedWasteId = value;
                                  final selectedWaste = _wasteTypes.firstWhere(
                                    (waste) => waste.id == value,
                                    orElse: () => WasteData(
                                      id: '',
                                      name: '',
                                      pricePerKg: '0',
                                    ),
                                  );
                                  selectedWasteName = selectedWaste.name;

                                  // Auto calculate amount when weight is entered
                                  if (weightController.text.isNotEmpty) {
                                    final weight =
                                        double.tryParse(
                                          weightController.text,
                                        ) ??
                                        0;
                                    final pricePerKg =
                                        double.tryParse(
                                          selectedWaste.pricePerKg,
                                        ) ??
                                        0;
                                    final totalAmount = (weight * pricePerKg)
                                        .round();
                                    amountController.text = totalAmount
                                        .toString();
                                  }
                                });
                              },
                        validator: (value) {
                          if (selectedType == 'DEPOSIT' &&
                              (value == null || value.isEmpty)) {
                            return 'Pilih jenis sampah terlebih dahulu';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Weight Field
                      TextFormField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Berat (kg)',
                          border: OutlineInputBorder(),
                          suffixText: 'kg',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (selectedType == 'DEPOSIT' &&
                              (value == null || value.isEmpty)) {
                            return 'Berat harus diisi';
                          }
                          if (selectedType == 'DEPOSIT') {
                            final weight = double.tryParse(value!);
                            if (weight == null || weight <= 0) {
                              return 'Berat harus lebih dari 0';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (selectedWasteId != null && value.isNotEmpty) {
                            final weight = double.tryParse(value) ?? 0;
                            final selectedWaste = _wasteTypes.firstWhere(
                              (waste) => waste.id == selectedWasteId,
                              orElse: () =>
                                  WasteData(id: '', name: '', pricePerKg: '0'),
                            );
                            final pricePerKg =
                                double.tryParse(selectedWaste.pricePerKg) ?? 0;
                            final totalAmount = (weight * pricePerKg).round();
                            setDialogState(() {
                              amountController.text = totalAmount.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                    ],

                    // Amount Field
                    if (selectedType == 'WITHDRAWAL') ...[
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Penarikan',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                          helperText: 'Minimal Rp 50.000',
                          helperStyle: TextStyle(color: Colors.grey.shade600),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah harus diisi';
                          }

                          final amount = int.tryParse(
                            value.replaceAll(RegExp(r'[^0-9]'), ''),
                          );
                          if (amount == null) {
                            return 'Masukkan jumlah yang valid';
                          }

                          if (amount < 50000) {
                            return 'Minimal penarikan Rp 50.000';
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
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi harus diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Batal'),
            ),
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
                            [
                              {
                                'wasteCategoryId': int.tryParse(
                                  selectedWasteId!,
                                ),
                                'weightInKg':
                                    double.tryParse(weightController.text) ?? 0,
                              },
                            ],
                            transaction.id,
                          );
                        } else {
                          // Additional validation untuk withdrawal amount
                          final amount =
                              int.tryParse(
                                amountController.text.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                ),
                              ) ??
                              0;

                          if (amount < 50000) {
                            _showSnackBar(
                              'Minimal penarikan adalah Rp 50.000',
                              Colors.red,
                            );
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
                        _showSnackBar(
                          'Transaksi berhasil diperbarui',
                          Colors.green,
                        );
                        _loadTransactions();
                      } catch (e) {
                        _showSnackBar(
                          'Gagal memperbarui transaksi: ${e.toString()}',
                          Colors.red,
                        );
                      } finally {
                        setDialogState(() {
                          isLoading = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
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
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Batal'),
          ),
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
                _showSnackBar(
                  'Gagal menghapus transaksi: ${e.toString()}',
                  Colors.red,
                );
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
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade600,
                  ),
                ),
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
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
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

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(amountInt);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
