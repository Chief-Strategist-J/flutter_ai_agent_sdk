# Quick Start Guide

Get up and running with Flutter AI Agent SDK in minutes!

## Prerequisites

Before you begin, ensure you have:

- **Flutter SDK**: Version 3.10.0 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **API Keys**: For your chosen LLM provider(s)

## 1. Installation

Add the SDK to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ai_agent_sdk:
    path: ../flutter_ai_agent_sdk  # For local development
    # OR
    # git: https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk.git
```

Install dependencies:

```bash
flutter pub get
```

## 2. Platform Setup

### iOS Setup

Add permissions to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice features.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to understand your voice commands.</string>
```

### Android Setup

Add permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Add speech service configuration:

```xml
<queries>
  <intent>
    <action android:name="android.speech.RecognitionService" />
  </intent>
</queries>
```

## 3. Create Your First Agent

Here's a complete example to get you started:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceAgentExample(),
    );
  }
}

class VoiceAgentExample extends StatefulWidget {
  @override
  _VoiceAgentExampleState createState() => _VoiceAgentExampleState();
}

class _VoiceAgentExampleState extends State<VoiceAgentExample> {
  late VoiceAgent _agent;
  late AgentSession _session;
  bool _isListening = false;
  String _response = '';

  @override
  void initState() {
    super.initState();
    _initializeAgent();
  }

  Future<void> _initializeAgent() async {
    // 1. Create LLM Provider (replace with your API key)
    final llmProvider = OpenAIProvider(
      apiKey: 'your-openai-api-key',
      model: 'gpt-4-turbo-preview',
    );

    // 2. Configure Agent
    final config = AgentConfig(
      name: 'Assistant',
      instructions: 'You are a helpful AI assistant.',
      llmProvider: llmProvider,
      sttService: NativeSTTService(),
      ttsService: NativeTTSService(),
      turnDetection: TurnDetectionConfig(
        mode: TurnDetectionMode.vad,
        silenceThreshold: Duration(milliseconds: 700),
      ),
    );

    // 3. Create Agent
    _agent = VoiceAgent(config: config);
    _session = await _agent.createSession();

    // 4. Listen to events
    _session.events.listen((event) {
      if (event is MessageReceivedEvent) {
        setState(() {
          _response = event.message.content ?? '';
        });
      }
    });
  }

  Future<void> _toggleListening() async {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      await _session.startListening();
    } else {
      await _session.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Agent Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _response.isEmpty ? 'Say something!' : 'Assistant: $_response',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 4. Test Your Setup

Run the app and try speaking to your AI assistant!

```bash
flutter run
```

## What's Next?

Now that you have a basic agent working, explore these features:

- **[Custom Tools](./advanced-features/custom-tools.md)** - Add function calling capabilities
- **[Memory Management](./core-concepts/memory.md)** - Implement conversation memory
- **[Multiple LLM Providers](./llm-integration/providers.md)** - Use different AI models
- **[Advanced Voice Features](./voice-features/)** - Fine-tune voice interaction

## Troubleshooting

### Common Issues

**Microphone Permission Denied**
- Check platform-specific permissions are added correctly
- Ensure user grants permission when prompted

**API Key Issues**
- Verify your API key is valid and has proper permissions
- Check rate limits and quotas for your LLM provider

**Voice Recognition Not Working**
- Ensure device microphone is working
- Check internet connection for cloud-based services
- Verify speech recognition service is available on the platform

### Getting Help

- Check the [Issues](../../issues) page for common problems
- Join our [Discussions](../../discussions) for community support
- Email us at [chief.stategist.j@gmail.com](mailto:chief.stategist.j@gmail.com) for direct support
