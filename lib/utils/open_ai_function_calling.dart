import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/certificate.dart';
import '../models/certificate_info.dart';

class OpenAISchema {
  Map<String, dynamic> headers;
  Map<String, dynamic> data;
  OpenAISchema({
    required this.headers,
    required this.data,
  });
}

class OpenAiFunctionCalling {
  static CertificateInfo getCertificateInfoFromOpenAiResponse(
      Map<String, dynamic> result) {
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
  }

  static OpenAISchema getSchema(
      {required String apiKey,
      required String modelName,
      required String imageBase64}) {
    return OpenAISchema(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      data: {
        "model": modelName,
        "messages": [
          {
            "role": "system",
            "content": [
              {
                "type": "text",
                "text":
                    "You are a tool that extracts structured data from Bangladeshi certificates. For Higher Secondary Certificate (HSC) or Secondary School Certificate (SSC)."
              }
            ]
          },
          {
            "role": "user",
            "content": [
              {"type": "text", "text": "Certificate image"},
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/png;base64,$imageBase64",
                }
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
        "tool_config": {
          "function_calling_config": {"mode": "ANY"}
        }
      },
    );
  }
}
