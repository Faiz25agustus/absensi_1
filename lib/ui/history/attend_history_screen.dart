import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection('attendance');
  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('students');

  void _editData(String docId, Map<String, dynamic> currentData) {
    TextEditingController nameController =
        TextEditingController(text: currentData['name']);
    TextEditingController addressController =
        TextEditingController(text: currentData['address']);
    TextEditingController descriptionController =
        TextEditingController(text: currentData['description']);
    TextEditingController datetimeController =
        TextEditingController(text: currentData['datetime']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Data"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: datetimeController, decoration: const InputDecoration(labelText: "Datetime")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await attendanceCollection.doc(docId).update({
                'name': nameController.text,
                'address': addressController.text,
                'description': descriptionController.text,
                'datetime': datetimeController.text,
              });
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Save", style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Data"),
        content: const Text("Are you sure want to delete this data?"),
        actions: [
          TextButton(
            onPressed: () async {
              await attendanceCollection.doc(docId).delete();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 26, 0, 143),
        centerTitle: true,
        title: const Text(
          "Attendance History Menu",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: attendanceCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!.docs;
            return data.isNotEmpty
                ? ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var docId = data[index].id;
                      var attendanceData = data[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    attendanceData['name'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 19),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Name: ${attendanceData['name']}", style: const TextStyle(fontSize: 14)),
                                    Text("Address: ${attendanceData['address']}", style: const TextStyle(fontSize: 14)),
                                    Text("Description: ${attendanceData['description']}", style: const TextStyle(fontSize: 14)),
                                    Text("Timestamp: ${attendanceData['datetime']}", style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () => _editData(docId, attendanceData),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteData(docId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text("Ups, there is no data!", style: TextStyle(fontSize: 20)));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
