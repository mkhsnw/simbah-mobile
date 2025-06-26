import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:simbah/models/transaction_model.dart';
import 'package:simbah/services/transaction_service.dart';

class AdminLaporanPage extends StatefulWidget {
  @override
  _AdminLaporanPageState createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  final TransactionService _transactionService = TransactionService();

  int _selectedYear = DateTime.now().year;
  List<TransactionData> _allTransactions = [];
  List<MonthlyReport> _monthlyReports = [];
  bool _isLoading = false;
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
      final response = await _transactionService.getAllTransactions(
        context: context,
      );

      if (response.success) {
        setState(() {
          _allTransactions = response.data;
          _generateMonthlyReports();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isEmpty
              ? 'Gagal memuat data transaksi'
              : response.message;
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

  void _generateMonthlyReports() {
    // Filter transactions by selected year
    final yearTransactions = _allTransactions.where((transaction) {
      if (transaction.createdAt == null) return false;
      return transaction.createdAt!.year == _selectedYear;
    }).toList();

    // Group by month
    Map<int, List<TransactionData>> monthlyTransactions = {};
    for (var transaction in yearTransactions) {
      final month = transaction.createdAt!.month;
      if (!monthlyTransactions.containsKey(month)) {
        monthlyTransactions[month] = [];
      }
      monthlyTransactions[month]!.add(transaction);
    }

    // Generate monthly reports
    _monthlyReports = [];
    final monthNames = [
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

    for (int month = 1; month <= 12; month++) {
      final monthTransactions = monthlyTransactions[month] ?? [];

      int totalDeposit = 0;
      int totalWithdrawal = 0;
      int transactionCount = monthTransactions.length;

      for (var transaction in monthTransactions) {
        final amount = int.tryParse(transaction.totalAmount) ?? 0;
        if (transaction.type.toLowerCase() == 'deposit') {
          totalDeposit += amount;
        } else if (transaction.type.toLowerCase() == 'withdrawal') {
          totalWithdrawal += amount;
        }
      }

      _monthlyReports.add(
        MonthlyReport(
          monthNames[month - 1],
          totalDeposit,
          totalWithdrawal,
          transactionCount,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Laporan Transaksi',
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
            onPressed: _loadTransactions,
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
              'Memuat data laporan...',
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
              onPressed: _loadTransactions,
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year Selector
          Container(
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
                Icon(Icons.calendar_today, color: Colors.green.shade600),
                SizedBox(width: 12),
                Text(
                  'Tahun: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  underline: SizedBox(),
                  items: _getAvailableYears()
                      .map(
                        (year) => DropdownMenuItem(
                          value: year,
                          child: Text(
                            year.toString(),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                      _generateMonthlyReports();
                    });
                  },
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Laporan Tahunan',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Setoran',
                  _getTotalDeposit(),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Penarikan',
                  _getTotalWithdrawal(),
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
                  '${_getTotalTransactions()} kali',
                  Icons.swap_horiz,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Saldo Bersih',
                  _getNetBalance(),
                  Icons.account_balance_wallet,
                  Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Visual Bar Chart Alternative (Custom)
          Container(
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
                  children: [
                    Icon(Icons.bar_chart, color: Colors.green.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Grafik Transaksi Bulanan $_selectedYear',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // _buildCustomBarChart(),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Top Performing Months
          Container(
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
                  children: [
                    Icon(Icons.star, color: Colors.orange.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Performa Terbaik',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildTopPerformingMonths(),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Monthly Table
          Container(
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
                  children: [
                    Icon(Icons.table_chart, color: Colors.blue.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Detail Bulanan $_selectedYear',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildMonthlyTable(),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Transaction Details by User
          Container(
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
                  children: [
                    Icon(Icons.people, color: Colors.indigo.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Aktivitas User $_selectedYear',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildUserActivitySection(),
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
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCustomBarChart() {
  //   if (_monthlyReports.isEmpty) {
  //     return Container(
  //       height: 150, // Reduced height
  //       child: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
  //             SizedBox(height: 8),
  //             Text(
  //               'Tidak ada data untuk tahun $_selectedYear',
  //               style: TextStyle(color: Colors.grey.shade500),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   // Find max value for scaling
  //   final maxDeposit = _monthlyReports
  //       .map((r) => r.totalDeposit)
  //       .reduce((a, b) => a > b ? a : b);
  //   final maxWithdrawal = _monthlyReports
  //       .map((r) => r.totalWithdrawal)
  //       .reduce((a, b) => a > b ? a : b);
  //   final maxValue = maxDeposit > maxWithdrawal ? maxDeposit : maxWithdrawal;

  //   if (maxValue == 0) {
  //     return Container(
  //       height: 150, // Reduced height
  //       child: Center(
  //         child: Text(
  //           'Tidak ada transaksi untuk tahun $_selectedYear',
  //           style: TextStyle(color: Colors.grey.shade500),
  //         ),
  //       ),
  //     );
  //   }

  //   return Container(
  //     height: 180, // Reduced from 250 to 180
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom
  //       children: _monthlyReports.map((report) {
  //         final depositHeight = maxValue > 0
  //             ? (report.totalDeposit / maxValue) * 120
  //             : 0.0; // Reduced bar height to 120
  //         final withdrawalHeight = maxValue > 0
  //             ? (report.totalWithdrawal / maxValue) * 120
  //             : 0.0;

  //         return Expanded(
  //           child: Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 2),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 // Values on top - made smaller and conditional
  //                 if (report.totalDeposit > 0)
  //                   Text(
  //                     '${(report.totalDeposit / 1000).toInt()}K',
  //                     style: TextStyle(
  //                       fontSize: 8, // Reduced from 10
  //                       color: Colors.green.shade600,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 SizedBox(height: 2), // Reduced spacing
  //                 // Deposit bar
  //                 Container(
  //                   width: double.infinity,
  //                   height: depositHeight,
  //                   decoration: BoxDecoration(
  //                     color: Colors.green.shade400,
  //                     borderRadius: BorderRadius.vertical(
  //                       top: Radius.circular(2), // Smaller radius
  //                     ),
  //                   ),
  //                 ),

  //                 // Small gap between bars
  //                 if (depositHeight > 0 && withdrawalHeight > 0)
  //                   SizedBox(height: 1),

  //                 // Withdrawal bar
  //                 Container(
  //                   width: double.infinity,
  //                   height: withdrawalHeight,
  //                   decoration: BoxDecoration(
  //                     color: Colors.red.shade400,
  //                     borderRadius: BorderRadius.vertical(
  //                       bottom: Radius.circular(2), // Smaller radius
  //                     ),
  //                   ),
  //                 ),

  //                 SizedBox(height: 2), // Reduced spacing
  //                 // Withdrawal value - made smaller and conditional
  //                 if (report.totalWithdrawal > 0)
  //                   Text(
  //                     '${(report.totalWithdrawal / 1000).toInt()}K',
  //                     style: TextStyle(
  //                       fontSize: 8, // Reduced from 10
  //                       color: Colors.red.shade600,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),

  //                 SizedBox(height: 4), // Reduced spacing
  //                 // Month label
  //                 Text(
  //                   report.month,
  //                   style: TextStyle(
  //                     fontSize: 10, // Reduced from 12
  //                     color: Colors.grey.shade600,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  Widget _buildTopPerformingMonths() {
    if (_monthlyReports.isEmpty) {
      return Text('Tidak ada data untuk tahun $_selectedYear');
    }

    // Sort by total deposit + transaction count
    final sortedReports = List<MonthlyReport>.from(_monthlyReports);
    sortedReports.sort(
      (a, b) => (b.totalDeposit + b.transactionCount * 100).compareTo(
        a.totalDeposit + a.transactionCount * 100,
      ),
    );

    // Filter out months with no activity
    final activeReports = sortedReports
        .where((r) => r.transactionCount > 0)
        .toList();

    if (activeReports.isEmpty) {
      return Text('Tidak ada aktivitas untuk tahun $_selectedYear');
    }

    return Column(
      children: activeReports.take(3).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final report = entry.value;
        final icons = [
          Icons.emoji_events,
          Icons.military_tech,
          Icons.workspace_premium,
        ];
        final colors = [Colors.amber, Colors.grey, Colors.orange];

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors[index].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors[index].withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icons[index], color: colors[index], size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${index + 1} ${report.month}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Setoran: Rp ${_formatCurrency(report.totalDeposit)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${report.transactionCount} transaksi',
                style: TextStyle(
                  fontSize: 12,
                  color: colors[index],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyTable() {
    if (_monthlyReports.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.table_chart, size: 48, color: Colors.grey.shade400),
              SizedBox(height: 8),
              Text(
                'Tidak ada data untuk tahun $_selectedYear',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
        columns: [
          DataColumn(
            label: Text('Bulan', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text(
              'Setoran',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Penarikan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Transaksi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Selisih',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: _monthlyReports.map((report) {
          final difference = report.totalDeposit - report.totalWithdrawal;
          final isPositive = difference >= 0;

          return DataRow(
            cells: [
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.month,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  'Rp ${_formatCurrency(report.totalDeposit)}',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Text(
                  'Rp ${_formatCurrency(report.totalWithdrawal)}',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${report.transactionCount}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}Rp ${_formatCurrency(difference.abs())}',
                    style: TextStyle(
                      color: isPositive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserActivitySection() {
    // Group transactions by user for selected year
    final yearTransactions = _allTransactions.where((transaction) {
      if (transaction.createdAt == null) return false;
      return transaction.createdAt!.year == _selectedYear;
    }).toList();

    Map<String, UserActivity> userActivities = {};

    for (var transaction in yearTransactions) {
      final user = transaction.user;
      if (user == null) continue;

      final userId = user.id;
      if (!userActivities.containsKey(userId)) {
        userActivities[userId] = UserActivity(
          userId: userId,
          userName: user.name,
          email: user.email,
          role: user.role,
          totalDeposit: 0,
          totalWithdrawal: 0,
          transactionCount: 0,
        );
      }

      final amount = int.tryParse(transaction.totalAmount) ?? 0;
      if (transaction.type.toLowerCase() == 'deposit') {
        userActivities[userId]!.totalDeposit += amount;
      } else if (transaction.type.toLowerCase() == 'withdrawal') {
        userActivities[userId]!.totalWithdrawal += amount;
      }
      userActivities[userId]!.transactionCount++;
    }

    final sortedUsers = userActivities.values.toList();
    sortedUsers.sort(
      (a, b) => b.transactionCount.compareTo(a.transactionCount),
    );

    if (sortedUsers.isEmpty) {
      return Text('Tidak ada aktivitas user untuk tahun $_selectedYear');
    }

    return Column(
      children: sortedUsers.take(5).map((userActivity) {
        final netAmount =
            userActivity.totalDeposit - userActivity.totalWithdrawal;
        final isPositive = netAmount >= 0;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: userActivity.role == 'ADMIN'
                    ? Colors.purple.shade100
                    : Colors.blue.shade100,
                child: Icon(
                  userActivity.role == 'ADMIN'
                      ? Icons.admin_panel_settings
                      : Icons.person,
                  color: userActivity.role == 'ADMIN'
                      ? Colors.purple.shade600
                      : Colors.blue.shade600,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userActivity.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${userActivity.transactionCount} transaksi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${_formatCurrency(userActivity.totalDeposit)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Rp ${_formatCurrency(userActivity.totalWithdrawal)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<int> _getAvailableYears() {
    final years = _allTransactions
        .where((t) => t.createdAt != null)
        .map((t) => t.createdAt!.year)
        .toSet()
        .toList();

    years.sort((a, b) => b.compareTo(a)); // Sort descending

    // Add current year if not present
    final currentYear = DateTime.now().year;
    if (!years.contains(currentYear)) {
      years.insert(0, currentYear);
    }

    return years.isEmpty ? [currentYear] : years;
  }

  String _getTotalDeposit() {
    final total = _monthlyReports.fold(
      0,
      (sum, report) => sum + report.totalDeposit,
    );
    return 'Rp ${_formatCurrency(total)}';
  }

  String _getTotalWithdrawal() {
    final total = _monthlyReports.fold(
      0,
      (sum, report) => sum + report.totalWithdrawal,
    );
    return 'Rp ${_formatCurrency(total)}';
  }

  String _getTotalTransactions() {
    final total = _monthlyReports.fold(
      0,
      (sum, report) => sum + report.transactionCount,
    );
    return total.toString();
  }

  String _getNetBalance() {
    final totalDeposit = _monthlyReports.fold(
      0,
      (sum, report) => sum + report.totalDeposit,
    );
    final totalWithdrawal = _monthlyReports.fold(
      0,
      (sum, report) => sum + report.totalWithdrawal,
    );
    final net = totalDeposit - totalWithdrawal;
    final isPositive = net >= 0;
    return '${isPositive ? '+' : ''}Rp ${_formatCurrency(net.abs())}';
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(amount);
  }
}

class MonthlyReport {
  final String month;
  final int totalDeposit;
  final int totalWithdrawal;
  final int transactionCount;

  MonthlyReport(
    this.month,
    this.totalDeposit,
    this.totalWithdrawal,
    this.transactionCount,
  );
}

class UserActivity {
  final String userId;
  final String userName;
  final String email;
  final String role;
  int totalDeposit;
  int totalWithdrawal;
  int transactionCount;

  UserActivity({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    required this.totalDeposit,
    required this.totalWithdrawal,
    required this.transactionCount,
  });
}
