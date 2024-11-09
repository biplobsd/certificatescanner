# Certificate scanner with GPT API

Using OpenAI or Gemini to extract certificate information using OpenAI function calling. 

## Configuratio
n
You need to fist get your OpenAI and Google Console vertex AI for Gemini API credentials. And store your credentials in to the `lib/keys/api_key.dart` file. Example below
```dart
const openAiApiKey = r“sk-proj-*****”; // Your OpenAI API Secret key
const serviceAccountJsonString = r"""<Service_Account_JSON>""";
```

### OpenAI

First get your OpenAI Api key from the OpenAI developer dashboard. Goto https://platform.openai.com/settings/profile then navigate to API Keys option and “create new secret key” from the green button. Then store the api key in the `api_key.dart` file mentioned in the configuration section.

### Vertex AI for Gemini API

Here are the step to configure Vertex AI for Gemini API access below -

- Create a project
- Go to APIs and services option from the left navigation bar
- Now click on the  ‘Enable apis and services’ to enable `Vertex AI API`
- Now goto `APIs and services`>Credentials> and `create credentials`>`Service Account`
- After then select the service account your are right now created and goto `keys` tab and `add key>create key as json type’
- Now give permission to your service account email for accessing gemini api. Copy your service account email address then goto  IAM>`Grant Access`> Fill `New principals` as your service account email. And set roll as 1. Vertex AI administrator, 2. Vertex AI Colab Service Agent, 3. Vertex AI Custom Code Service Agent, 4. Vertex AI Extension Service Agent
- Done

Now open service account keys json file and copy all and assistant  to the serviceAccountJsonString variable in `api_key.dart` file, mentioned in the configuration section.

## Usage

Open the project in the IDE and run the project as usual.
First tab to `Capture a image` then tab `Compress` and finally upload for detection.
You can also choose OpenAI or Gemini for detection.

## Screenshorts

![image](https://github.com/user-attachments/assets/112d3e5e-0dce-422a-a9fd-8879ab81eb73)

![image](https://github.com/user-attachments/assets/60f458e1-c609-4c3b-87fe-b11c07409702)


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
