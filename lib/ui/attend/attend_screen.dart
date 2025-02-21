import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendaftaran Mahasiswa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AttendScreen(),
    );
  }
}

class AttendScreen extends StatefulWidget {
  @override
  _StudentRegistrationState createState() => _StudentRegistrationState();
}

class _StudentRegistrationState extends State<AttendScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedJurusan;
  String? selectedGender;
  DateTime? selectedDate;

  bool isLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void registerStudent() async {
    if (nameController.text.isEmpty ||
        nimController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedJurusan == null ||
        selectedGender == null ||
        selectedDate == null) {
      showSnackbar('Harap isi semua kolom!', Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    try {
      await firestore.collection('students').add({
        'name': nameController.text,
        'nim': nimController.text,
        'jurusan': selectedJurusan,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'gender': selectedGender,
        'birthdate': selectedDate!.toIso8601String(),
      });
      showSnackbar('Pendaftaran berhasil!', Colors.green);
      clearFields();
    } catch (e) {
      showSnackbar('Pendaftaran gagal!', Colors.red);
    }
    setState(() => isLoading = false);
  }

  void clearFields() {
    setState(() {
      nameController.clear();
      nimController.clear();
      emailController.clear();
      phoneController.clear();
      addressController.clear();
      selectedJurusan = null;
      selectedGender = null;
      selectedDate = null;
    });
  }

  void pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pendaftaran Mahasiswa'),
        centerTitle: true,
        leading: Icon(Icons.school),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nimController,
              decoration: InputDecoration(
                labelText: 'NIM',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedJurusan,
              hint: Text('Pilih Jurusan'),
              items: [
                'Informatika',
                'Sistem Informasi',
                'Teknik Elektro',
                'Teknik Mesin',
                'Psikologi',
              ]
                  .map((jurusan) =>
                      DropdownMenuItem(value: jurusan, child: Text(jurusan)))
                  .toList(),
              onChanged: (value) => setState(() => selectedJurusan = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // **Nomor Telepon**
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // **Alamat Lengkap**
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // **Tanggal Lahir**
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate == null
                      ? 'Pilih Tanggal'
                      : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}',
                ),
              ),
            ),
            SizedBox(height: 16),

            // **Jenis Kelamin**
            DropdownButtonFormField<String>(
              value: selectedGender,
              hint: Text('Pilih Jenis Kelamin'),
              items: ['Laki-laki', 'Perempuan']
                  .map((gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: (value) => setState(() => selectedGender = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 16),

            if (isLoading) Center(child: CircularProgressIndicator()),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: registerStudent,
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  child: Text('Daftar', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: clearFields,
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  child: Text('Hapus Form', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
