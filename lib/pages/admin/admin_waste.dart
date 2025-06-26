import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/models/waste_mode.dart';
import 'package:simbah/services/waste_service.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:intl/intl.dart';

class AdminWasteTypePage extends StatefulWidget {
  @override
  _AdminWasteTypePageState createState() => _AdminWasteTypePageState();
}

class _AdminWasteTypePageState extends State<AdminWasteTypePage> {
  final WasteService _wasteService = WasteService();
  List<WasteData> _wasteTypes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWasteTypes();
  }

  Future<void> _loadWasteTypes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final wasteModel = await _wasteService.getWasteData(context: context);

      if (wasteModel.success) {
        setState(() {
          _wasteTypes = wasteModel.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = wasteModel.message.isEmpty
              ? 'Gagal memuat data jenis sampah'
              : wasteModel.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        // Auth error will be handled by service
        return;
      }
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Jenis & Harga Sampah',
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
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadWasteTypes,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddWasteTypeDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green.shade600),
            SizedBox(height: 16),
            Text(
              'Memuat data jenis sampah...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
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
              onPressed: _loadWasteTypes,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
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

    if (_wasteTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.recycling, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Belum ada jenis sampah',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tambahkan jenis sampah pertama Anda',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddWasteTypeDialog,
              icon: Icon(Icons.add),
              label: Text('Tambah Jenis Sampah'),
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

    return RefreshIndicator(
      onRefresh: _loadWasteTypes,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _wasteTypes.length,
        itemBuilder: (context, index) {
          final wasteType = _wasteTypes[index];
          return _buildWasteTypeCard(wasteType);
        },
      ),
    );
  }

  Widget _buildWasteTypeCard(WasteData wasteType) {
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
                  wasteType.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp ${_formatCurrency(int.tryParse(wasteType.pricePerKg) ?? 0)}/kg',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showEditWasteTypeDialog(wasteType),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, size: 20, color: Colors.blue),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteWasteType(wasteType),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddWasteTypeDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Tambah Jenis Sampah'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Jenis Sampah',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Harga per Kg',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
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
                      if (nameController.text.isNotEmpty &&
                          priceController.text.isNotEmpty) {
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          print(
                            'Creating waste type: ${nameController.text}, ${priceController.text}',
                          );

                          final response = await _wasteService.createWasteType(
                            name: nameController.text,
                            pricePerKg: priceController.text,
                            context: context,
                          );

                          print('Create response success: ${response.success}');
                          print('Create response message: ${response.message}');

                          if (response.success) {
                            Navigator.pop(context);
                            _showSnackBar(
                              'Jenis sampah berhasil ditambahkan',
                              Colors.green,
                            );
                            _loadWasteTypes();
                          } else {
                            _showSnackBar(
                              response.message.isNotEmpty
                                  ? response.message
                                  : 'Gagal menambahkan jenis sampah',
                              Colors.red,
                            );
                          }
                        } catch (e) {
                          print('Create waste error: $e');
                          _showSnackBar(
                            'Gagal menambahkan jenis sampah: ${e.toString()}',
                            Colors.red,
                          );
                        } finally {
                          setDialogState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        _showSnackBar(
                          'Mohon isi semua field yang diperlukan',
                          Colors.orange,
                        );
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

  void _showEditWasteTypeDialog(WasteData wasteType) {
    final nameController = TextEditingController(text: wasteType.name);
    final priceController = TextEditingController(text: wasteType.pricePerKg);
    bool isLoading = false;

    print('wasteType.id: ${wasteType.id}');

    if (wasteType.id == null) {
      _showSnackBar('ID jenis sampah tidak ditemukan', Colors.red);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Jenis Sampah'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Jenis Sampah',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Harga per Kg',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
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
                      if (nameController.text.isNotEmpty &&
                          priceController.text.isNotEmpty &&
                          wasteType.id != null) {
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          print('Updating waste type ID: ${wasteType.id}');
                          print('New name: ${nameController.text}');
                          print('New price: ${priceController.text}');

                          final response = await _wasteService.updateWasteType(
                            id: wasteType.id!.toString(),
                            name: nameController.text,
                            pricePerKg: priceController.text,
                            context: context,
                          );

                          print('Update response success: ${response.success}');
                          print('Update response message: ${response.message}');

                          if (response.success) {
                            Navigator.pop(context);
                            _showSnackBar(
                              'Jenis sampah berhasil diupdate',
                              Colors.green,
                            );
                            _loadWasteTypes();
                          } else {
                            _showSnackBar(
                              response.message.isNotEmpty
                                  ? response.message
                                  : 'Gagal mengupdate jenis sampah',
                              Colors.red,
                            );
                          }
                        } catch (e) {
                          print('Update waste error: $e');
                          _showSnackBar(
                            'Gagal mengupdate jenis sampah: ${e.toString()}',
                            Colors.red,
                          );
                        } finally {
                          setDialogState(() {
                            isLoading = false;
                          });
                        }
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
                  : Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteWasteType(WasteData wasteType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Jenis Sampah'),
        content: Text('Apakah Anda yakin ingin menghapus "${wasteType.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (wasteType.id != null) {
                Navigator.pop(context);

                try {
                  print('Deleting waste type ID: ${wasteType.id}');

                  final response = await _wasteService.deleteWasteType(
                    id: wasteType.id!.toString(),
                    context: context,
                  );

                  print('Delete response success: ${response.success}');
                  print('Delete response message: ${response.message}');

                  if (response.success) {
                    _showSnackBar(
                      'Jenis sampah berhasil dihapus',
                      Colors.green,
                    );
                    _loadWasteTypes();
                  } else {
                    _showSnackBar(
                      response.message.isNotEmpty
                          ? response.message
                          : 'Gagal menghapus jenis sampah',
                      Colors.red,
                    );
                  }
                } catch (e) {
                  print('Delete waste error: $e');
                  _showSnackBar(
                    'Gagal menghapus jenis sampah: ${e.toString()}',
                    Colors.red,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
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

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(amount);
  }
}
