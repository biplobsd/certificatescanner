import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../models/certificate.dart';
import '../services/extract_certificate_info.dart';
import '../utils/file_size_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? image;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;
  double quality = 50;
  Certificate? certificate;
  String? errorMsg;

  Future<void> pickImage(ImageSource source) async {
    final XFile? picked = await picker.pickImage(source: source);

    setState(() {
      isLoading = true;
    });

    if (picked != null) {
      final memoryImage = await picked.readAsBytes();
      setState(() {
        image = memoryImage;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<Uint8List> comporessImageToList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      quality: quality.round(),
    );
    debugPrint(list.length.toString());
    debugPrint(result.length.toString());
    return result;
  }

  Future<void> compressImage() async {
    setState(() {
      isLoading = true;
    });
    final compressedImage = await comporessImageToList(image!);
    setState(() {
      image = compressedImage;
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploadImage() async {
    errorMsg = null;
    if (image == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      String imageBase64 = base64Encode(image!);

      final certificateInfo =
          await ExtractCertificateInfo.usingOpenAI(imageBase64);

      if (certificateInfo.errorMsg != null) {
        errorMsg = certificateInfo.errorMsg;
      }

      if (certificateInfo.certificate == null) {
        errorMsg = 'Error: Unexpected certificate null';
      }

      certificate = certificateInfo.certificate;
    } catch (e) {
      debugPrint('Error during API call: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteImage() {
    setState(() {
      image = null;
      certificate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (image != null)
                  Column(
                    children: [
                      GestureDetector(
                        onLongPress: () => deleteImage(),
                        child: Image.memory(image!, fit: BoxFit.cover),
                      ),
                      Text(
                          'File size: ${FileSizeCalculator.getFileSize(image!)}')
                    ],
                  ),
                const SizedBox(height: 10),
                if (isLoading)
                  const SizedBox.square(
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () async {
                    await pickImage(ImageSource.camera);
                  },
                  child: const Text("Capture a image"),
                ),
                ListTile(
                  title: FilledButton(
                    onPressed: compressImage,
                    child: const Text("Compress"),
                  ),
                  subtitle: Row(
                    children: [
                      const Text('Quality'),
                      Expanded(
                        child: Slider(
                          value: quality,
                          max: 100,
                          divisions: 100,
                          label: quality.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              quality = value;
                            });
                          },
                        ),
                      ),
                      Text(quality.round().toString())
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: uploadImage,
                  child: const Text("Upload image"),
                ),
                if (errorMsg != null)
                  SizedBox(
                      height: 100,
                      child: Text(
                        errorMsg.toString(),
                        style: const TextStyle(color: Colors.redAccent),
                      )),
                if (certificate != null)
                  Column(
                    children: [
                      ListTile(
                        title: const Text("Examination title"),
                        subtitle:
                            Text(certificate!.examinationTitle ?? 'Not found'),
                      ),
                      ListTile(
                        title: const Text("Group name"),
                        subtitle: Text(certificate!.groupName ?? 'Not found'),
                      ),
                      ListTile(
                        title: const Text("Roll number"),
                        subtitle: Text(certificate!.rollNumber ?? 'Not found'),
                      ),
                      ListTile(
                        title: const Text("Year of passing"),
                        subtitle:
                            Text(certificate!.yearOfPassing ?? 'Not found'),
                      ),
                      ListTile(
                        title: const Text("Result"),
                        subtitle: Text(certificate!.result ?? 'Not found'),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
