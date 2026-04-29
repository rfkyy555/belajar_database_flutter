import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _users = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() async {
    final data = await _dbHelper.getUsers();
    setState(() {
      _users = data;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingUser = _users.firstWhere((element) => element['id'] == id);
      _nameController.text = existingUser['name'];
      _ageController.text = existingUser['age'].toString();
    } else {
      _nameController.clear();
      _ageController.clear();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              id == null ? 'Tambah User' : 'Edit User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Age'),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _dbHelper.insertUser({
                      'name': _nameController.text,
                      'age': int.tryParse(_ageController.text) ?? 0,
                    });
                  } else {
                    await _dbHelper.updateUser({
                      'id': id,
                      'name': _nameController.text,
                      'age': int.tryParse(_ageController.text) ?? 0,
                    });
                  }
                  _nameController.clear();
                  _ageController.clear();
                  if (mounted) Navigator.of(context).pop();
                  _refreshUsers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(id == null ? 'TAMBAH' : 'UPDATE'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.cancel, color: Colors.deepPurple, size: 30),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.deepPurple)),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteUser(id);
              if (mounted) Navigator.of(ctx).pop();
              _refreshUsers();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        title: const Text('List User Data', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(_users[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Umur: ${_users[index]['age']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () => _showForm(_users[index]['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black87),
                  onPressed: () => _confirmDelete(_users[index]['id']),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: const Color(0xFFDCD6F7),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}