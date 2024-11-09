import 'package:dio/dio.dart';

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

class GeminiApi {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> sendImageToApi({
    required String apiKey,
    required String imageBase64,
    String projectId = "certificate-scanning",
    String location = 'us-central1',
    String modelName = "google/gemini-1.5-flash",
  }) async {
    final getSchema = OpenAiFunctionCalling.getSchema(
      apiKey: apiKey,
      modelName: modelName,
      imageBase64: imageBase64,
    );
    final response = await dio.post(
      "https://$location-aiplatform.googleapis.com/v1beta1/projects/$projectId/locations/$location/endpoints/openapi/chat/completions",
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
