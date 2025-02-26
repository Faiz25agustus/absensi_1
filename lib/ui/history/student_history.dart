import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentHistoryScreen extends StatefulWidget {
  const StudentHistoryScreen({super.key});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('students');

  void _editStudent(String docId, String currentName, String currentNim, String currentJurusan, String currentEmail) {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController nimController = TextEditingController(text: currentNim);
    TextEditingController jurusanController = TextEditingController(text: currentJurusan);
    TextEditingController emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Data Mahasiswa"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: nimController, decoration: const InputDecoration(labelText: "NIM")),
            TextField(controller: jurusanController, decoration: const InputDecoration(labelText: "Jurusan")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await studentCollection.doc(docId).update({
                'name': nameController.text,
                'nim': nimController.text,
                'jurusan': jurusanController.text,
                'email': emailController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data Mahasiswa"),
        content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () async {
              await studentCollection.doc(docId).delete();
              Navigator.pop(context);
            },
            child: const Text("Ya", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tidak", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History Mahasiswa")),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var students = snapshot.data!.docs;
            return students.isNotEmpty
                ? ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      var docId = students[index].id;
                      var name = students[index]['name'];
                      var nim = students[index]['nim'];
                      var jurusan = students[index]['jurusan'];
                      var email = students[index]['email'];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NIM: $nim"),
                              Text("Jurusan: $jurusan"),
                              Text("Email: $email"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () => _editStudent(docId, name, nim, jurusan, email),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStudent(docId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text("Tidak ada data mahasiswa"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
