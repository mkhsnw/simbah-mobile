import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/models/user_model.dart';
import 'package:simbah/models/withdraw_model.dart';
import 'package:simbah/services/user_service.dart';
import 'package:simbah/services/withdraw_request_service.dart';
import 'package:simbah/services/transaction_service.dart';

class AdminWithdrawRequestsPage extends StatefulWidget {
  @override
  State<AdminWithdrawRequestsPage> createState() =>
      _AdminWithdrawRequestsPageState();
}

class _AdminWithdrawRequestsPageState extends State<AdminWithdrawRequestsPage>
    with SingleTickerProviderStateMixin {
  final WithdrawRequestService _withdrawService = WithdrawRequestService();
  final UserService _userService = UserService();

  late TabController _tabController;
  List<WithdrawData> _allRequests = [];
  List<WithdrawData> _pendingRequests = [];
  List<WithdrawData> _processedRequests = [];

  bool _isLoading = true;
  String _errorMessage = '';
  Set<String> _processingRequests = {};

  // ✅ Cache untuk user data
  final Map<String, DataUser> _userCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWithdrawRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWithdrawRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _withdrawService.getAllAdminWithdrawRequests();

      setState(() {
        _allRequests = response.data;
        _pendingRequests = _allRequests
            .where((req) => req.status.toUpperCase() == 'PENDING')
            .toList();
        _processedRequests = _allRequests
            .where(
              (req) =>
                  req.status.toUpperCase() == 'APPROVED' ||
                  req.status.toUpperCase() == 'REJECTED',
            )
            .toList();
        _isLoading = false;
      });

      // Clear cache saat refresh
      _userCache.clear();
    } catch (e) {
      if (e is UnauthorizedException) {
        context.go('/login');
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Method untuk load user data dengan caching
  Future<DataUser?> _loadUserData(String userId) async {
    // Check cache first
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      final response = await _userService.getUserById(userId);
      if (response.success && response.data != null) {
        // Cache the result
        _userCache[userId] = response.data!;
        return response.data;
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error loading user $userId: $e');
      throw Exception('Failed to load user data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Request Penarikan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadWithdrawRequests,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.pending),
              text: 'Pending (${_pendingRequests.length})',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Diproses (${_processedRequests.length})',
            ),
            Tab(icon: Icon(Icons.list), text: 'Semua (${_allRequests.length})'),
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
              children: [
                _buildRequestList(_pendingRequests, showActions: true),
                _buildRequestList(_processedRequests, showActions: false),
                _buildRequestList(_allRequests, showActions: true),
              ],
            ),
    );
  }

  Widget _buildRequestList(
    List<WithdrawData> requests, {
    required bool showActions,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Tidak ada request penarikan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWithdrawRequests,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request, showActions: showActions);
        },
      ),
    );
  }

  // ✅ FutureBuilder untuk handle async user data loading
  Widget _buildRequestCard(WithdrawData request, {required bool showActions}) {
    return FutureBuilder<DataUser?>(
      future: _loadUserData(request.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(request, snapshot.error.toString());
        }

        final userData = snapshot.data;
        if (userData == null) {
          return _buildErrorCard(request, 'User data not found');
        }

        return _buildActualCard(request, userData, showActions: showActions);
      },
    );
  }

  // ✅ Loading card saat fetch user data
  Widget _buildLoadingCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Memuat data user...',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Error card jika gagal load user data
  Widget _buildErrorCard(WithdrawData request, String error) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade600),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error memuat data user',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Request ID: ${request.id}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            'Jumlah: Rp ${_formatCurrency(int.parse(request.amount))}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            'Status: ${request.status}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.red.shade600, fontSize: 12),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Remove from cache and rebuild
              _userCache.remove(request.userId);
              setState(() {});
            },
            icon: Icon(Icons.refresh, size: 16),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Card sebenarnya dengan data user yang sudah berhasil di-load
  Widget _buildActualCard(
    WithdrawData request,
    DataUser userData, {
    required bool showActions,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (request.status.toUpperCase()) {
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
    }

    final isProcessing = _processingRequests.contains(request.id);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp ${_formatCurrency(int.parse(request.amount))}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      // ✅ Gunakan userData yang sudah di-fetch
                      Text(
                        userData.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
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
            SizedBox(height: 16),

            // ✅ User Info dengan data yang sudah di-fetch
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey.shade600, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rekening: ${userData.rekening}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Email: ${userData.email}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Description
            if (request.description.isNotEmpty) ...[
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
                request.description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              SizedBox(height: 12),
            ],

            // Admin Note (if processed)
            if (request.adminNote != null && request.adminNote!.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Admin:',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      request.adminNote!,
                      style: TextStyle(color: statusColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],

            // Dates
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                SizedBox(width: 4),
                Text(
                  'Diajukan: ${_formatDate(request.requestedAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            if (request.processedAt != null) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.done, size: 16, color: Colors.grey.shade500),
                  SizedBox(width: 4),
                  Text(
                    'Diproses: ${_formatDate(request.processedAt!)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],

            // Action Buttons (only for pending requests)
            if (showActions && request.status.toUpperCase() == 'PENDING') ...[
              SizedBox(height: 16),
              if (isProcessing)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 2),
                        SizedBox(width: 12),
                        Text(
                          'Memproses...',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showProcessDialog(request, userData, 'REJECTED'),
                        icon: Icon(Icons.close, size: 16),
                        label: Text('Tolak'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showProcessDialog(request, userData, 'APPROVED'),
                        icon: Icon(Icons.check, size: 16),
                        label: Text('Setuju'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
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
              onPressed: _loadWithdrawRequests,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Update method untuk menerima userData
  void _showProcessDialog(
    WithdrawData request,
    DataUser userData,
    String action,
  ) {
    final TextEditingController noteController = TextEditingController();
    final bool isApprove = action == 'APPROVED';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle : Icons.cancel,
              color: isApprove ? Colors.green.shade600 : Colors.red.shade600,
            ),
            SizedBox(width: 8),
            Text('${isApprove ? 'Setujui' : 'Tolak'} Request'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah: Rp ${_formatCurrency(int.parse(request.amount))}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    // ✅ Gunakan userData yang sudah di-pass
                    Text(
                      'Pemohon: ${userData.name}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      'Rekening: ${userData.rekening}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      'Email: ${userData.email}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Note Field
              Text(
                'Catatan Admin ${isApprove ? '(opsional)' : '(wajib)'}:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isApprove
                      ? 'Tambahkan catatan jika diperlukan...'
                      : 'Berikan alasan penolakan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isApprove
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!isApprove && noteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Catatan penolakan wajib diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _processRequest(request.id, action, noteController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove
                  ? Colors.green.shade600
                  : Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> _processRequest(
    String requestId,
    String action,
    String note,
  ) async {
    setState(() {
      _processingRequests.add(requestId);
    });

    try {
      await _withdrawService.processRequestAdmin(action, note, requestId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Request berhasil ${action == 'APPROVED' ? 'disetujui' : 'ditolak'}',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      // Refresh data
      await _loadWithdrawRequests();
    } catch (e) {
      if (e is UnauthorizedException) {
        context.go('/login');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Gagal memproses request: ${e.toString()}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingRequests.remove(requestId);
        });
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
