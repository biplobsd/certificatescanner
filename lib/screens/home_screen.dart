import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../models/certificate.dart';
import '../models/certificate_info.dart';
import '../services/extract_certificate_info.dart';
import '../utils/file_size_calculator.dart';
import '../utils/google_get_access_token.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum DropDownOption { openAi, gemini }

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? image;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;
  double quality = 1;
  Certificate? certificate;
  String? errorMsg;
  DropDownOption dropdownValue = DropDownOption.gemini;

  late GoogleGetAccessToken getAccessToken;

  @override
  void initState() {
    super.initState();
    getAccessToken = GoogleGetAccessToken();
    getAccessToken.init();
  }

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
      CertificateInfo? certificateInfo;

      switch (dropdownValue) {
        case DropDownOption.openAi:
          certificateInfo = await ExtractCertificateInfo.usingOpenAI(image!);
          break;
        case DropDownOption.gemini:
          certificateInfo = await ExtractCertificateInfo.usingGemini(
            apiKey: getAccessToken.accessToken.data,
            image: image!,
          );
          break;

        default:
      }

      if (certificateInfo == null) return;

      if (certificateInfo.errorMsg != null) {
        errorMsg = certificateInfo.errorMsg;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg!),
          ),
        );
      }

      if (certificateInfo.certificate == null) {
        errorMsg = 'Error: Unexpected certificate null';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg!),
          ),
        );
      }

      certificate = certificateInfo.certificate;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(certificateInfo.toString()),
        ),
      );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await pickImage(ImageSource.camera);
                      },
                      child: const Text("Capture a image"),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () async {
                        await pickImage(ImageSource.gallery);
                      },
                      child: const Text("Pic a image"),
                    ),
                  ],
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
                DropdownButton<DropDownOption>(
                  value: dropdownValue,
                  onChanged: (DropDownOption? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items: DropDownOption.values
                      .map<DropdownMenuItem<DropDownOption>>((var value) {
                    return DropdownMenuItem<DropDownOption>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
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
