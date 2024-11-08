import 'package:dio/dio.dart';

import 'api_key.dart';

/*

Examination title
group name
roll no
year of passing
result

*/

class OpenAIApi {
  final Dio dio = Dio();
  final String apiKey = openAiApiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<Map<String, dynamic>> sendImageToApi(String imageBase64) async {
    final response = await dio.post(
      apiUrl,
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      }),
      data: {
        "model": "gpt-4-turbo",
        "messages": [
          {
            "role": "system",
            "content": [
              {
                "type": "text",
                "text":
                    "You are a tool that extracts structured data from Bangladeshi certificates. For Higher Secondary Certificate (HSC) or Secondary School Certificate (SSC). Your goal is to output data in strict JSON format according to the provided schema."
              }
            ]
          },
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {"url": "data:image/png;base64,$imageBase64"}
              }
            ]
          }
        ],
        "temperature": 0,
        "max_tokens": 256,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
        "tools": [
          {
            "type": "function",
            "function": {
              "name": "extract_certificate_info",
              "description":
                  "Extracts information from a Bangladeshi HSC or SSC certificate image",
              "parameters": {
                "type": "object",
                "properties": {
                  "certificate": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "examination_title": {
                          "type": "string",
                          "enum": ["HSC", "SSC"],
                          "description":
                              "The title of the examination. It could be Higher Secondary Certificate (HSC) or Secondary School Certificate (SSC)."
                        },
                        "group_name": {
                          "type": "string",
                          "description":
                              "The group name of the examination. It could be science, humanities, Commerce."
                        },
                        "roll_number": {
                          "type": "string",
                          "description": "The student role number."
                        },
                        "year_of_passing": {
                          "type": "string",
                          "description": "The passing year for examination."
                        },
                        "result": {
                          "type": "string",
                          "description":
                              "Examination result, It could be GPA floating number"
                        },
                      },
                      "required": [
                        "examination_title",
                        "group_name",
                        "roll_number",
                        "year_of_passing",
                        "result"
                      ],
                      "additionalProperties": false
                    }
                  }
                },
                "required": ["certificate"],
                "additionalProperties": false
              },
              "strict": true
            }
          }
        ],
        "response_format": {"type": "json_object"}
      },
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to extract certificate information');
    }
  }
}
