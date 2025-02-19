import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:attedance_app/ui/home_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          // Add your own Firebase project configuration from google-services.json
          apiKey: 'AIzaSyD1jYylSh2rTzFO0DgpbrllxKZ3PhxRcrk', // api_key
          appId:
              '1:733162330357:android:93a1d6e4df835854fb8dbc', // mobilesdk_app_id
          messagingSenderId: '243811762198', // project_number
          projectId: 'absensi1-42425' // project_id
          ),
    );
    // Firebase connection success
    print("Firebase Terhubung ke:");
    print("API Key: ${Firebase.app().options.apiKey}");
    print("Project ID: ${Firebase.app().options.projectId}");
  } catch (e) {
    // Firebase connection failed
    print("Firebase gagal terhubung: $e");
  }
  // runApp(const HomeScreen());
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  // Main App
  const TestApp({super.key}); // Constructor of TestApp clas

  @override // can give information about about your missing override code
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove debug banner
      home: const HomeScreen(), // HomeScreen class
    );
  }
}

