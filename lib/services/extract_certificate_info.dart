import 'dart:convert';

import 'package:certificatescanner/models/certificate_info.dart';
import 'package:certificatescanner/services/gemini_api.dart';
import 'package:certificatescanner/utils/open_ai_function_calling.dart';
import 'package:flutter/foundation.dart';

import 'google_vision_api.dart';
import 'openai_api.dart';

class ExtractCertificateInfo {
  static Future<void> usingGoogleVision(Uint8List image) async {
    final googleVisionApi = GoogleVisionApi();
    await googleVisionApi.init();
    final result = await googleVisionApi.sendImageToApi(image);
    debugPrint(result.toString());
  }

  static Future<CertificateInfo> usingGemini({
    required Uint8List image,
    required String apiKey,
  }) async {
    try {
      String imageBase64 = base64Encode(image);
      var result = await GeminiApi()
          .sendImageToApi(apiKey: apiKey, imageBase64: imageBase64);

      debugPrint('API Response:  ${jsonEncode(result)}');
      return OpenAiFunctionCalling.getCertificateInfoFromOpenAiResponse(result);
    } on Exception catch (e) {
      return CertificateInfo(errorMsg: e.toString());
    }
  }

  static Future<CertificateInfo> usingOpenAI(Uint8List image) async {
    try {
      String imageBase64 = base64Encode(image);
      var result = await OpenAIApi().sendImageToApi(imageBase64);

      debugPrint('API Response:  ${jsonEncode(result)}');
      return OpenAiFunctionCalling.getCertificateInfoFromOpenAiResponse(result);
    } on Exception catch (e) {
      return CertificateInfo(errorMsg: e.toString());
    }
  }
}
