import 'dart:convert';

import 'package:certificatescanner/models/certificate.dart';
import 'package:certificatescanner/models/certificate_info.dart';
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

  static Future<CertificateInfo> usingOpenAI(Uint8List image) async {
    try {
      String imageBase64 = base64Encode(image);
      var result = await OpenAIApi().sendImageToApi(imageBase64);

      debugPrint('API Response:  ${jsonEncode(result)}');
      var message = result['choices'][0]['message'];
      var content = message['content'];

      if (content != null) {
        return CertificateInfo(errorMsg: content);
      }

      var toolCalls = message['tool_calls'];
      if (toolCalls == null || toolCalls.isEmpty) {
        const errorMsg = 'No tool calls found in the response.';
        debugPrint(errorMsg);
        return CertificateInfo(errorMsg: errorMsg);
      }

      var arguments = jsonDecode(toolCalls[0]['function']['arguments']);
      List<dynamic> certificateData = arguments['certificate'] ?? [];

      if (certificateData.isEmpty) {
        const errorMsg = 'No certificate data found in the response.';
        debugPrint(errorMsg);
        return CertificateInfo(errorMsg: errorMsg);
      }

      debugPrint(certificateData.toString());

      return CertificateInfo(
        certificate: Certificate.fromJson(certificateData[0]),
      );
    } on Exception catch (e) {
      return CertificateInfo(errorMsg: e.toString());
    }
  }
}
