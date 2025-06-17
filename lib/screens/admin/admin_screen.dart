import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../services/database_service.dart';
import '../../widgets/admin_bar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _editUsernameController = TextEditingController();
  final _editPhoneNumberController = TextEditingController();
  final _editPasswordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  static const String _adminPhoneNumber = '0912345678';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      _users = await _databaseService.getAllUsers();
    } catch (e) {
      _showErrorSnackBar('ተጠቃሚዎችን መመዝገብ አልተቻለም');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final username = _usernameController.text.trim();
      final phoneNumber = _phoneNumberController.text.trim();
      final password = _passwordController.text.trim();
      if (username.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
        throw Exception('ሁሉም መረጃዎች ያስፈልጋሉ');
      }
      if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
        throw Exception('ስልክ ቁጥር ትክክለኛ መሆን አለበት (ለምሳሌ: 0912345678)');
      }
      if (phoneNumber == _adminPhoneNumber) {
        throw Exception('ይህ ስልክ ቁጥር ለአስተዳዳሪ ተጠብቆ ስለሆነ መጠቀም አይቻልም');
      }
      await _databaseService.addUser(username, phoneNumber, password);
      _usernameController.clear();
      _phoneNumberController.clear();
      _passwordController.clear();
      await _loadUsers();
    } catch (e) {
      _showErrorSnackBar('ተጠቃሚ መመዝገብ አልተቻለም');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _databaseService.deleteUser(id);
      await _loadUsers();
    } catch (e) {
      _showErrorSnackBar('ተጠቃሚ መሰረዝ አልተቻለም');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUser(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final username = _editUsernameController.text.trim();
      final phoneNumber = _editPhoneNumberController.text.trim();
      final password = _editPasswordController.text.trim();
      if (username.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
        throw Exception('ሁሉም መረጃዎች ያስፈልጋሉ');
      }
      if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
        throw Exception('ስልክ ቁጥር ትክክለኛ መሆን አለበት (ለምሳሌ: 0912345678)');
      }
      if (phoneNumber == _adminPhoneNumber) {
        throw Exception('ይህ ስልክ ቁጥር ለአስተዳዳሪ ተጠብቆ ስለሆነ መጠቀም አይቻልም');
      }
      await _databaseService.updateUser(id, username, phoneNumber, password);
      _editUsernameController.clear();
      _editPhoneNumberController.clear();
      _editPasswordController.clear();
      Navigator.pop(context);
      await _loadUsers();
    } catch (e) {
      _showErrorSnackBar('ተጠቃሚ ማስተካከል አልተቻለም');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditDialog(Map<String, dynamic> user) {
    _editUsernameController.text = user['username'];
    _editPhoneNumberController.text = user['phone_number'] ?? '';
    _editPasswordController.text = user['password'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Update User', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editUsernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'ስም',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            TextField(
              controller: _editPhoneNumberController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'ስልክ ቁጥር',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            TextField(
              controller: _editPasswordController,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'የይለፍ ቃል',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => _updateUser(user['id']),
            child: const Text('Update', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text(
          'ተጠቃሚ "${user['username']}" መሰረዝ ይፈልጋሉ?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              _deleteUser(user['id']);
              Navigator.pop(context);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final username = appState.getCurrentUsername() ?? "Guest";
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red.withOpacity(0.15),
                    Colors.red.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red.withOpacity(0.15),
                    Colors.red.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.4, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icon/appicon.png',
                        height: 50,
                        width: 50,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'IUC Park - $username',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                          labelText: 'የተጠቃሚ ስም',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneNumberController,
                        style: const TextStyle(color: Colors.black87),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone, color: Colors.grey.shade600),
                          labelText: 'ስልክ ቁጥር',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
                          labelText: 'የይለፍ ቃል',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Add User',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.red))
                      : _users.isEmpty
                          ? const Center(
                              child: Text('Users not found', style: TextStyle(color: Colors.black87)))
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: cardPadding),
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                return Card(
                                  color: Colors.grey[100],
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                      user['username'],
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'ስልክ: ${user['phone_number']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showEditDialog(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _showDeleteDialog(user),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBar(
        parentContext: context,
        activeScreen: ActiveScreen.admin,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _editUsernameController.dispose();
    _editPhoneNumberController.dispose();
    _editPasswordController.dispose();
    super.dispose();
  }
}