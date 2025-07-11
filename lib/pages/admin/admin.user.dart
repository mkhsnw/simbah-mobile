import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simbah/models/user_model.dart';
import 'package:simbah/services/auth_service.dart';
import 'package:simbah/services/user_service.dart';
import 'package:simbah/services/transaction_service.dart';

enum UserRole { USER, ADMIN }

class AdminUserPage extends StatefulWidget {
  @override
  _AdminUserPageState createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  final UserService _userService = UserService();
  List<DataUser> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _userService.getAllUsers(context: context);

      if (response.success) {
        setState(() {
          _users = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isEmpty ? 'Gagal memuat data user' : response.message;
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
          'Manajemen User',
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
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddUserDialog,
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
            Text('Memuat data user...', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
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
              onPressed: _loadUsers,
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

    if (_users.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'Belum ada user terdaftar',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text('Tambahkan user pertama Anda', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddUserDialog,
            icon: Icon(Icons.add),
            label: Text('Tambah User'),
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

  Widget _buildUserCard(DataUser user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: user.role == 'ADMIN' ? Colors.purple.shade100 : Colors.green.shade100,
                child: Icon(
                  user.role == 'ADMIN' ? Icons.admin_panel_settings : Icons.person,
                  color: user.role == 'ADMIN' ? Colors.purple.shade600 : Colors.green.shade600,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.role == 'ADMIN' ? Colors.purple.shade100 : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 10,
                              color: user.role == 'ADMIN' ? Colors.purple.shade700 : Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    Text(
                      user.formattedBalance,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No. Nasabah', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    Text(
                      user.rekening,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditUserDialog(user),
                icon: Icon(Icons.edit, size: 16),
                label: Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
              SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteUser(user),
                icon: Icon(Icons.delete, size: 16),
                label: Text('Hapus'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.USER;
    bool isPasswordVisible = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.person_add, color: Colors.green.shade600),
              SizedBox(width: 8),
              Text('Tambah User'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setDialogState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              role == UserRole.ADMIN ? Icons.admin_panel_settings : Icons.person,
                              size: 16,
                              color: role == UserRole.ADMIN ? Colors.purple.shade600 : Colors.blue.shade600,
                            ),
                            SizedBox(width: 8),
                            Text(role.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: isLoading ? null : () => Navigator.pop(context), child: Text('Batal')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Fix: Gunakan hanya 3 parameter atau update method untuk 4 parameter
                      if (_validateUserForm(
                        nameController.text,
                        emailController.text,
                        passwordController.text,
                        '', // kosong untuk auto-generate rekening
                      )) {
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          await AuthService().register(
                            emailController.text,
                            passwordController.text,
                            nameController.text,
                            selectedRole.name,
                          );

                          Navigator.pop(context);
                          _showSnackBar('User berhasil ditambahkan', Colors.green);
                          _loadUsers();
                        } catch (e) {
                          _showSnackBar('Gagal menambahkan user: ${e.toString()}', Colors.red);
                        } finally {
                          setDialogState(() {
                            isLoading = false;
                          });
                        }
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

  void _showEditUserDialog(DataUser user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final rekeningController = TextEditingController(text: user.rekening);
    UserRole selectedRole = UserRole.values.firstWhere((role) => role.name == user.role, orElse: () => UserRole.USER);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text('Edit User'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              role == UserRole.ADMIN ? Icons.admin_panel_settings : Icons.person,
                              size: 16,
                              color: role == UserRole.ADMIN ? Colors.purple.shade600 : Colors.blue.shade600,
                            ),
                            SizedBox(width: 8),
                            Text(role.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: isLoading ? null : () => Navigator.pop(context), child: Text('Batal')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // FIX: Pass user.id instead of rekeningController.text
                      if (_validateEditForm(
                        nameController.text,
                        emailController.text,
                        user.id, // ✅ Use user.id, not rekeningController.text
                      )) {
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          final response = await _userService.updateUser(
                            user.id,
                            nameController.text.trim(),
                            emailController.text.trim().toLowerCase(),
                            selectedRole.name,
                          );

                          if (response.success) {
                            Navigator.pop(context);
                            _showSnackBar('User berhasil diupdate', Colors.green);
                            _loadUsers(); // Refresh data
                          } else {
                            _showSnackBar(response.message, Colors.red);
                          }
                        } catch (e) {
                          _showSnackBar('Gagal mengupdate user: ${e.toString()}', Colors.red);
                        } finally {
                          setDialogState(() {
                            isLoading = false;
                          });
                        }
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

  void _deleteUser(DataUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            SizedBox(width: 8),
            Text('Hapus User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus user berikut?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${user.name}', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('Email: ${user.email}'),
                  Text('Role: ${user.role}'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Tindakan ini tidak dapat dibatalkan!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await _userService.deleteUser(user.id, context);
                _showSnackBar('User berhasil dihapus', Colors.green);
                _loadUsers(); // Refresh data
              } catch (e) {
                _showSnackBar('Gagal menghapus user: ${e.toString()}', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bool _validateUserForm(String name, String email, String password, String rekening) {
    if (name.trim().isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', Colors.red);
      return false;
    }

    if (email.trim().isEmpty || !_isValidEmail(email)) {
      _showSnackBar('Email tidak valid', Colors.red);
      return false;
    }

    if (password.trim().isEmpty || password.length < 6) {
      _showSnackBar('Password minimal 6 karakter', Colors.red);
      return false;
    }

    // Check if email already exists
    if (_users.any((user) => user.email.toLowerCase() == email.trim().toLowerCase())) {
      _showSnackBar('Email sudah terdaftar', Colors.red);
      return false;
    }

    return true;
  }

  bool _validateEditForm(String name, String email, String userId) {
    if (name.trim().isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', Colors.red);
      return false;
    }

    if (email.trim().isEmpty || !_isValidEmail(email)) {
      _showSnackBar('Email tidak valid', Colors.red);
      return false;
    }

    // Check if email already exists (excluding current user)
    if (_users.any((user) => user.email.toLowerCase() == email.trim().toLowerCase() && user.id != userId)) {
      _showSnackBar('Email sudah terdaftar', Colors.red);
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor, duration: Duration(seconds: 3)));
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
