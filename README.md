# Flutter AI Agent SDK

A high-performance, extensible AI Agent SDK for Flutter with voice interaction, LLM integration, and tool execution capabilities.

## ✨ Features

- 🎙️ **Voice Interaction**: Built-in STT/TTS with native platform support
- 🤖 **Multiple LLM Providers**: OpenAI, Anthropic, and custom providers
- 🛠️ **Tool/Function Calling**: Execute custom functions from AI responses
- 💾 **Conversation Memory**: Short-term and long-term memory management
- 🔄 **Streaming Support**: Real-time response streaming
- 🎯 **Turn Detection**: VAD, push-to-talk, and hybrid modes
- 📦 **Pure Dart**: No platform-specific code required
- ⚡ **High Performance**: Optimized for mobile devices

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ai_agent_sdk:
    path: ../flutter_ai_agent_sdk
```

## 📖 Quick Start

### 1. Create an LLM Provider

```dart
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

final llmProvider = OpenAIProvider(
  apiKey: 'your-api-key',
  model: 'gpt-4-turbo-preview',
);
```

### 2. Configure Your Agent

```dart
final config = AgentConfig(
  name: 'My Assistant',
  instructions: 'You are a helpful AI assistant.',
  llmProvider: llmProvider,
  sttService: NativeSTTService(),
  ttsService: NativeTTSService(),
  turnDetection: TurnDetectionConfig(
    mode: TurnDetectionMode.vad,
    silenceThreshold: Duration(milliseconds: 700),
  ),
  tools: [
    // Add your custom tools here
  ],
);
```

### 3. Create and Use Agent

```dart
final agent = VoiceAgent(config: config);
final session = await agent.createSession();

// Send text message
await session.sendMessage('Hello!');

// Start voice interaction
await session.startListening();

// Listen to events
session.events.listen((event) {
  if (event is MessageReceivedEvent) {
    print('Assistant: ${event.message.content}');
  }
});

// Listen to state changes
session.state.listen((status) {
  print('State: ${status.state}');
});
```

## 🛠️ Creating Custom Tools

```dart
final weatherTool = FunctionTool(
  name: 'get_weather',
  description: 'Get current weather for a location',
  parameters: {
    'type': 'object',
    'properties': {
      'location': {'type': 'string', 'description': 'City name'},
      'unit': {'type': 'string', 'enum': ['celsius', 'fahrenheit']},
    },
    'required': ['location'],
  },
  function: (args) async {
    final location = args['location'];
    final unit = args['unit'] ?? 'celsius';
    
    // Your weather API call here
    return {
      'temperature': 22,
      'condition': 'sunny',
      'location': location,
      'unit': unit,
    };
  },
);
```

## 🏗️ Architecture

```
flutter_ai_agent_sdk/
├── lib/
│   ├── src/
│   │   ├── core/           # Core agent logic
│   │   │   ├── agents/     # VoiceAgent, config
│   │   │   ├── sessions/   # Session management
│   │   │   ├── events/     # Event system
│   │   │   └── models/     # Data models
│   │   ├── voice/          # Voice processing
│   │   │   ├── stt/        # Speech-to-text
│   │   │   ├── tts/        # Text-to-speech
│   │   │   ├── vad/        # Voice activity detection
│   │   │   └── audio/      # Audio utilities
│   │   ├── llm/            # LLM integration
│   │   │   ├── providers/  # Provider implementations
│   │   │   ├── chat/       # Chat context
│   │   │   └── streaming/  # Stream processing
│   │   ├── tools/          # Tool execution
│   │   ├── memory/         # Memory management
│   │   └── utils/          # Utilities
│   └── flutter_ai_agent_sdk.dart
├── example/                # Example app
└── test/                   # Tests
```

## 🔌 Supported LLM Providers

### OpenAI
```dart
OpenAIProvider(
  apiKey: 'sk-...',
  model: 'gpt-4-turbo-preview',
)
```

### Anthropic
```dart
AnthropicProvider(
  apiKey: 'sk-ant-...',
  model: 'claude-3-sonnet-20240229',
)
```

### Custom Provider
```dart
class MyCustomProvider extends LLMProvider {
  @override
  String get name => 'MyProvider';
  
  @override
  Future<LLMResponse> generate({
    required List<Message> messages,
    List<Tool>? tools,
    Map<String, dynamic>? parameters,
  }) async {
    // Your implementation
  }
  
  @override
  Stream<LLMResponse> generateStream({
    required List<Message> messages,
    List<Tool>? tools,
    Map<String, dynamic>? parameters,
  }) async* {
    // Your streaming implementation
  }
}
```

## 🎯 Turn Detection Modes

- **VAD** (Voice Activity Detection): Automatic speech detection
- **Push-to-Talk**: Manual button control
- **Server VAD**: Server-side detection (e.g., OpenAI Realtime)
- **Hybrid**: Combined VAD + silence detection

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- ✅ Web (limited voice features)
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🧪 Testing

```bash
flutter test
```

## 📄 License

MIT License

## 🤝 Contributing

Contributions welcome! Please read CONTRIBUTING.md first.

## 📞 Support

- Documentation: [link]
- Issues: [GitHub Issues]
- Discord: [link]
