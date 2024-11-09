import 'dart:typed_data';

import 'package:google_vision/google_vision.dart';

import '../keys/api_key.dart';

class GoogleVisionApi {
  late GoogleVision googleVision;

  Future<void> init() async {
    googleVision = await GoogleVision.withJwt(serviceAccountJsonString);
  }

  Future<Map<String, dynamic>?> sendImageToApi(Uint8List image) async {
    final texts = await googleVision.documentTextDetection(
      JsonImage.fromBuffer(image.buffer),
    );

    if (texts != null) {
      return texts.toJson();
    }

    return null;
  }
}
