import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../keys/api_key.dart';
import '../utils/open_ai_function_calling.dart';

/*

Examination title
group name
roll no
year of passing
result


"gpt-4-turbo"

*/

class OpenAIApi {
  final Dio dio = Dio();
  final String apiKey = openAiApiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<Map<String, dynamic>> sendImageToApi(String imageBase64) async {
    final getSchema = OpenAiFunctionCalling.getSchema(
      apiKey: apiKey,
      modelName: "gpt-4-turbo",
      imageBase64: imageBase64,
    );
    final response = await dio.post(
      apiUrl,
      options: Options(headers: getSchema.headers),
      data: getSchema.data,
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to extract certificate information');
    }
  }
}
