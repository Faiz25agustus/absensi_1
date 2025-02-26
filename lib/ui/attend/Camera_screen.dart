import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart'; 
import 'package:attedance_app/ui/attend/attend_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  late FaceDetector faceDetector;
  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
        enableLandmarks: true,
      ),
    );
    loadCamera();
  }

  @override
  void dispose() {
    faceDetector.close(); // Menutup faceDetector untuk mencegah memory leak
    controller?.dispose(); // Menutup kamera agar tidak ada kebocoran memori
    super.dispose();
  }

  Future<void> loadCamera() async {
    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      final frontCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );

      controller = CameraController(frontCamera, ResolutionPreset.veryHigh);

      try {
        await controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        debugPrint('Error initializing camera: $e');
      }
    } else {
      showSnackBar("Ups, kamera tidak ditemukan!", Icons.camera_enhance_outlined);
    }
  }

  void showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.blueGrey,
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 26, 0, 143),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          "Capture a selfie image",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: controller == null
                ? const Center(child: Text("Ups, kamera error!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                : !controller!.value.isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : CameraPreview(controller!),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Lottie.asset("assets/raw/face_id_ring.json", fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Make sure you're in a well-lit area so your face is clearly visible.",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ClipOval(
                      child: Material(
                        color: Colors.blueAccent,
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: captureAndProcessImage,
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.camera_enhance_outlined, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> captureAndProcessImage() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) {
      showSnackBar("Please allow the permission first!", Icons.location_on_outlined);
      return;
    }

    try {
      if (controller != null && controller!.value.isInitialized) {
        controller!.setFlashMode(FlashMode.off);
        image = await controller!.takePicture();

        if (image != null) {
          showLoaderDialog();
          final inputImage = InputImage.fromFilePath(image!.path);

          if (Platform.isAndroid) {
            await processImage(inputImage);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AttendScreen(image: image)));
          }
        }
      }
    } catch (e) {
      showSnackBar("Ups, $e", Icons.error_outline);
    }
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;

    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;

    if (mounted) {
      Navigator.of(context).pop(true);
      if (faces.isNotEmpty) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendScreen(image: image)));
      } else {
        showSnackBar("Ups, make sure that your face is clearly visible!", Icons.face_retouching_natural_outlined);
      }
    }
  }

  void showLoaderDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent)),
              Container(margin: const EdgeInsets.only(left: 20), child: const Text("Checking the data...")),
            ],
          ),
        );
      },
    );
  }
}

handleLocationPermission() {
}
