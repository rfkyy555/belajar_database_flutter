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
      debugShowCheckedModeBanner: false,
      title: 'User Database App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
        fontFamily: 'Arial',
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
      final existingUser =
          _users.firstWhere((element) => element['id'] == id);

      _nameController.text = existingUser['name'];
      _ageController.text = existingUser['age'].toString();
    } else {
      _nameController.clear();
      _ageController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              id == null ? "Tambah User" : "Edit User",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Umur",
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty ||
                      _ageController.text.isEmpty) {
                    return;
                  }

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

                  if (mounted) Navigator.pop(context);

                  _refreshUsers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  id == null ? "Tambah Data" : "Update Data",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Hapus Data"),
        content: const Text(
          "Apakah yakin ingin menghapus data ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.deleteUser(id);

              if (mounted) Navigator.pop(context);

              _refreshUsers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Database",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 5,
      ),

      body: _users.isEmpty
          ? const Center(
              child: Text(
                "Belum ada data user",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),

                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text(
                        _users[index]['name'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),

                    title: Text(
                      _users[index]['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "Umur: ${_users[index]['age']} Tahun",
                      ),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () =>
                              _showForm(_users[index]['id']),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _confirmDelete(_users[index]['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}