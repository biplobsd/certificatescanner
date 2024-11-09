import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';

import '../keys/api_key.dart';

class GoogleGetAccessToken {
  late AccessToken accessToken;

  Future<void> init() async {
    accessToken = await getAccessToken();
  }

  Future<AccessToken> getAccessToken() async {
    // Define the scopes for your API (adjust according to your needs)
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

    // Create the credentials from the JSON key
    final accountCredentials = ServiceAccountCredentials.fromJson(
        jsonDecode(serviceAccountJsonString));

    // Get an authenticated client
    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);

    // Get the access token
    final accessToken = authClient.credentials.accessToken;

    // Close the client after usage
    authClient.close();

    return accessToken;
  }
}
